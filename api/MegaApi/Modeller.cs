using System.Globalization;
using System.Xml.Linq;

namespace MegaApi;

/// <summary>Hata yanıtı; mobil uygulama "mesaj" alanını kullanıcıya gösterir.</summary>
public record Hata(string Mesaj);

/// <summary>AdresAna tablosundaki bir kayıt (VerDar, VerNo, EpostaAdr, WebAdr sütunları okunur adlarla).</summary>
public class AdresKaydi
{
    public int? Id { get; set; }
    public string Kod { get; set; } = "";
    public string? Ad { get; set; }
    public string? Adres { get; set; }
    public string? Semt { get; set; }
    public string? Sehir { get; set; }
    public string? Ulke { get; set; }
    public string? PostaKodu { get; set; }
    public string? Telefon { get; set; }
    public string? Fax { get; set; }
    public string? VergiDairesi { get; set; }
    public string? VergiNo { get; set; }
    public string? Eposta { get; set; }
    public string? WebSitesi { get; set; }
    public string? Yetkili1 { get; set; }
    public string? Yetkili2 { get; set; }

    /// <summary>Sütunların veritabanındaki (varchar) en fazla uzunlukları.</summary>
    private static readonly (string Ad, Func<AdresKaydi, string?> Deger, int EnFazla)[] Sinirlar =
    [
        ("Kod", a => a.Kod, 20), ("Ad", a => a.Ad, 150), ("Adres", a => a.Adres, 250), ("Semt", a => a.Semt, 20),
        ("Şehir", a => a.Sehir, 20), ("Ülke", a => a.Ulke, 20), ("Posta Kodu", a => a.PostaKodu, 10),
        ("Telefon", a => a.Telefon, 40), ("Fax", a => a.Fax, 20), ("Vergi Dairesi", a => a.VergiDairesi, 25),
        ("Vergi No", a => a.VergiNo, 20), ("Mail", a => a.Eposta, 50), ("Web Sitesi", a => a.WebSitesi, 50),
        ("Yetkili 1", a => a.Yetkili1, 30), ("Yetkili 2", a => a.Yetkili2, 30),
    ];

    /// <summary>Baştaki/sondaki boşlukları siler.</summary>
    public void Temizle()
    {
        Kod = Kod?.Trim() ?? "";
        Ad = Ad?.Trim();
        Adres = Adres?.Trim();
        Semt = Semt?.Trim();
        Sehir = Sehir?.Trim();
        Ulke = Ulke?.Trim();
        PostaKodu = PostaKodu?.Trim();
        Telefon = Telefon?.Trim();
        Fax = Fax?.Trim();
        VergiDairesi = VergiDairesi?.Trim();
        VergiNo = VergiNo?.Trim();
        Eposta = Eposta?.Trim();
        WebSitesi = WebSitesi?.Trim();
        Yetkili1 = Yetkili1?.Trim();
        Yetkili2 = Yetkili2?.Trim();
    }

    /// <summary>Hata varsa mesajını, yoksa null döner.</summary>
    public string? Dogrula()
    {
        if (string.IsNullOrEmpty(Kod)) return "Kod boş bırakılamaz.";
        if (string.IsNullOrEmpty(Ad)) return "Ad boş bırakılamaz.";
        foreach (var (ad, deger, enFazla) in Sinirlar)
        {
            if ((deger(this)?.Length ?? 0) > enFazla) return $"{ad} en fazla {enFazla} karakter olabilir.";
        }
        return null;
    }
}

/// <summary>DovizGecmisi tablosundaki satır (kurlar tabloda metin olarak saklanır).</summary>
public class KurSatiri
{
    public int Id { get; set; }
    public DateTime? Tarih { get; set; }
    public string? DolarKuru { get; set; }
    public string? EuroKuru { get; set; }
    public string? Durum { get; set; }

    /// <summary>
    /// Kurları sayıya çevirerek mobil uygulamaya döner ("48,7384" ve "48.7384" ikisi de okunur).
    /// Tarih, veritabanındaki gibi saat dilimi bilgisi olmadan (yerel saat) gönderilir.
    /// </summary>
    public object Disari() => new
    {
        Id,
        Tarih = Tarih is { } t ? DateTime.SpecifyKind(t, DateTimeKind.Unspecified) : (DateTime?)null,
        Dolar = Sayi(DolarKuru),
        Euro = Sayi(EuroKuru),
        Durum,
    };

    private static decimal? Sayi(string? metin) =>
        decimal.TryParse(metin?.Replace(',', '.'), NumberStyles.Number, CultureInfo.InvariantCulture, out var d) ? d : null;
}

/// <summary>Web sürümündeki (Default.aspx.cs) TCMB kuralları.</summary>
public static class Tcmb
{
    public const string GuncelDurum = "Güncel Bugünün Kuru";
    public const string GecmisDurum = "En Son Açıklanan Geçmiş İş Günü Kuru (15:30 Öncesi / Tatil Modu)";

    /// <summary>Hafta sonu ya da 15:30 öncesinde TCMB o günün kurunu henüz yayımlamamıştır.</summary>
    public static string Durum(DateTime simdi) =>
        simdi.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday || simdi.TimeOfDay < new TimeSpan(15, 30, 0)
            ? GecmisDurum
            : GuncelDurum;

    /// <summary>Efektif satış kuru; yoksa döviz satış kuru.</summary>
    public static decimal? SatisKuru(XDocument xml, string kod)
    {
        var doviz = xml.Root?.Elements("Currency").FirstOrDefault(e => (string?)e.Attribute("Kod") == kod);
        foreach (var etiket in new[] { "BanknoteSelling", "ForexSelling" })
        {
            var metin = doviz?.Element(etiket)?.Value.Trim();
            if (decimal.TryParse(metin, NumberStyles.Number, CultureInfo.InvariantCulture, out var deger)) return deger;
        }
        return null;
    }
}
