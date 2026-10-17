using System.Globalization;
using System.Xml.Linq;
using Dapper;
using MegaApi;
using Microsoft.Data.SqlClient;

// Mobil uygulama için REST API. Web (MegaWebProje) ve masaüstü (StajProje) sürümleriyle
// aynı SQL Server veritabanını (AdresAna ve DovizGecmisi tabloları) kullanır.
var builder = WebApplication.CreateBuilder(args);

// Flutter web (tarayıcı) başka bir porttan istek attığı için CORS'a izin verilir.
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));
builder.Services.AddHttpClient();

var app = builder.Build();
app.UseCors();

var baglantiMetni = builder.Configuration.GetConnectionString("MegaBaglanti")
    ?? throw new InvalidOperationException("appsettings.json içinde ConnectionStrings:MegaBaglanti tanımlı değil.");
SqlConnection Baglan() => new(baglantiMetni);

// Veritabanına ulaşılamazsa mobil uygulamaya anlaşılır bir mesaj döner.
app.Use(async (context, next) =>
{
    try
    {
        await next();
    }
    catch (SqlException ex)
    {
        app.Logger.LogError(ex, "Veritabanı hatası");
        context.Response.StatusCode = StatusCodes.Status503ServiceUnavailable;
        await context.Response.WriteAsJsonAsync(new Hata("Veritabanına bağlanılamadı: " + ex.Message));
    }
});

app.MapGet("/api/saglik", () => Results.Ok(new { durum = "çalışıyor" }));

// ---------------- Adres kayıtları (AdresAna) ----------------

const string adresSutunlari = """
    ID AS Id, Kod, Ad, Adres, Semt, Sehir, Ulke, PostaKodu, Telefon, Fax,
    VerDar AS VergiDairesi, VerNo AS VergiNo, EpostaAdr AS Eposta, WebAdr AS WebSitesi, Yetkili1, Yetkili2
    """;

// Web sürümündeki İlk/Geri/İleri/Son gezinmesi ID sırasına göre olduğu için liste de ID sırasıyla döner.
app.MapGet("/api/adresler", async () =>
{
    await using var db = Baglan();
    return Results.Ok(await db.QueryAsync<AdresKaydi>($"SELECT {adresSutunlari} FROM AdresAna ORDER BY ID"));
});

app.MapPost("/api/adresler", async (AdresKaydi adres) =>
{
    adres.Temizle();
    if (adres.Dogrula() is { } hata) return Results.BadRequest(new Hata(hata));

    await using var db = Baglan();
    if (await KodKullaniliyor(db, adres.Kod, haricId: null)) return KodCakismasi(adres.Kod);

    adres.Id = await db.ExecuteScalarAsync<int>("""
        INSERT INTO AdresAna (Kod, Ad, Adres, Semt, Sehir, Ulke, PostaKodu, Telefon, Fax, VerDar, VerNo, EpostaAdr, WebAdr, Yetkili1, Yetkili2)
        OUTPUT INSERTED.ID
        VALUES (@Kod, @Ad, @Adres, @Semt, @Sehir, @Ulke, @PostaKodu, @Telefon, @Fax, @VergiDairesi, @VergiNo, @Eposta, @WebSitesi, @Yetkili1, @Yetkili2)
        """, adres);
    return Results.Created($"/api/adresler/{adres.Id}", adres);
});

app.MapPut("/api/adresler/{id:int}", async (int id, AdresKaydi adres) =>
{
    adres.Id = id;
    adres.Temizle();
    if (adres.Dogrula() is { } hata) return Results.BadRequest(new Hata(hata));

    await using var db = Baglan();
    if (await KodKullaniliyor(db, adres.Kod, haricId: id)) return KodCakismasi(adres.Kod);

    var etkilenen = await db.ExecuteAsync("""
        UPDATE AdresAna SET Kod=@Kod, Ad=@Ad, Adres=@Adres, Semt=@Semt, Sehir=@Sehir, Ulke=@Ulke, PostaKodu=@PostaKodu,
            Telefon=@Telefon, Fax=@Fax, VerDar=@VergiDairesi, VerNo=@VergiNo, EpostaAdr=@Eposta, WebAdr=@WebSitesi,
            Yetkili1=@Yetkili1, Yetkili2=@Yetkili2
        WHERE ID=@Id
        """, adres);
    return etkilenen == 0 ? KayitYok(id) : Results.Ok(adres);
});

app.MapDelete("/api/adresler/{id:int}", async (int id) =>
{
    await using var db = Baglan();
    var etkilenen = await db.ExecuteAsync("DELETE FROM AdresAna WHERE ID=@id", new { id });
    return etkilenen == 0 ? KayitYok(id) : Results.NoContent();
});

static async Task<bool> KodKullaniliyor(SqlConnection db, string kod, int? haricId) =>
    await db.ExecuteScalarAsync<int>(
        "SELECT COUNT(*) FROM AdresAna WHERE Kod=@kod AND (@haricId IS NULL OR ID<>@haricId)", new { kod, haricId }) > 0;

static IResult KodCakismasi(string kod) => Results.Conflict(new Hata($"'{kod}' kodu başka bir kayıtta kullanılıyor."));
static IResult KayitYok(int id) => Results.NotFound(new Hata($"{id} numaralı kayıt bulunamadı. Başka bir yerden silinmiş olabilir."));

// ---------------- TCMB döviz arşivi (DovizGecmisi) ----------------

app.MapGet("/api/kurlar", async () =>
{
    await using var db = Baglan();
    var satirlar = await db.QueryAsync<KurSatiri>("SELECT ID AS Id, Tarih, DolarKuru, EuroKuru, Durum FROM DovizGecmisi ORDER BY Tarih DESC");
    return Results.Ok(satirlar.Select(s => s.Disari()));
});

// Web sürümündeki "Güncel Kur Çek" ile aynı: TCMB today.xml'den efektif satış (yoksa döviz satış) kuru alınır,
// durum saate göre belirlenir ve DovizGecmisi tablosuna yazılır.
app.MapPost("/api/kurlar/guncel", async (IHttpClientFactory httpFactory) =>
{
    XDocument xml;
    try
    {
        var http = httpFactory.CreateClient();
        http.Timeout = TimeSpan.FromSeconds(15);
        xml = XDocument.Parse(await http.GetStringAsync("https://www.tcmb.gov.tr/kurlar/today.xml"));
    }
    catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or System.Xml.XmlException)
    {
        return Results.Json(new Hata("TCMB'den kur alınamadı: " + ex.Message), statusCode: StatusCodes.Status502BadGateway);
    }

    var dolar = Tcmb.SatisKuru(xml, "USD");
    var euro = Tcmb.SatisKuru(xml, "EUR");
    if (dolar is null || euro is null)
        return Results.Json(new Hata("TCMB bülteninde dolar veya euro kuru bulunamadı."), statusCode: StatusCodes.Status502BadGateway);

    var simdi = DateTime.Now;
    var satir = new KurSatiri
    {
        Tarih = simdi,
        DolarKuru = dolar.Value.ToString(CultureInfo.InvariantCulture),
        EuroKuru = euro.Value.ToString(CultureInfo.InvariantCulture),
        Durum = Tcmb.Durum(simdi),
    };

    await using var db = Baglan();
    satir.Id = await db.ExecuteScalarAsync<int>(
        "INSERT INTO DovizGecmisi (Tarih, DolarKuru, EuroKuru, Durum) OUTPUT INSERTED.ID VALUES (@Tarih, @DolarKuru, @EuroKuru, @Durum)", satir);
    return Results.Ok(satir.Disari());
});

app.Run();
