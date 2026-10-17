import '../utils/arama.dart' as arama;

/// Bir adres kaydının alanları. Form, tablolar, raporlar ve PDF bu listeyi kullanır.
/// [name], kayıtların cihazda saklandığı JSON anahtarıdır; değiştirilirse eski kayıtlar okunamaz.
/// [name] aynı zamanda API'deki JSON alan adıdır.
enum AdresAlani {
  kod('Kod', 'KOD', 20),
  ad('Ad', 'AD', 150),
  adres('Adres', 'ADRES', 250),
  semt('Semt', 'SEMT / İLÇE', 20),
  sehir('Şehir', 'ŞEHİR', 20),
  ulke('Ülke', 'ÜLKE', 20),
  postaKodu('Posta Kodu', 'POSTA KODU', 10),
  telefon('Telefon', 'TELEFON', 40),
  fax('Fax', 'FAX', 20),
  vergiDairesi('Vergi Dairesi', 'VERGİ DAİRESİ', 25),
  vergiNo('Vergi No', 'VERGİ NO', 20),
  eposta('Mail', 'E-POSTA ADRESİ', 50),
  webSitesi('Web Sitesi', 'WEB SİTESİ', 50),
  yetkili1('Yetkili 1', 'YETKİLİ 1', 30),
  yetkili2('Yetkili 2', 'YETKİLİ 2', 30);

  /// Formdaki etiket.
  final String etiket;

  /// Tablo sütun başlığı.
  final String baslik;

  /// Veritabanındaki (AdresAna) sütunun en fazla karakter sayısı.
  final int enFazla;

  const AdresAlani(this.etiket, this.baslik, this.enFazla);
}

class Adres {
  /// Veritabanındaki ID; henüz kaydedilmemiş kayıtta null.
  final int? id;
  final String kod;
  final String ad;
  final String adres;
  final String semt;
  final String sehir;
  final String ulke;
  final String postaKodu;
  final String telefon;
  final String fax;
  final String vergiDairesi;
  final String vergiNo;
  final String eposta;
  final String webSitesi;
  final String yetkili1;
  final String yetkili2;

  const Adres({
    this.id,
    required this.kod,
    required this.ad,
    this.adres = '',
    this.semt = '',
    this.sehir = '',
    this.ulke = '',
    this.postaKodu = '',
    this.telefon = '',
    this.fax = '',
    this.vergiDairesi = '',
    this.vergiNo = '',
    this.eposta = '',
    this.webSitesi = '',
    this.yetkili1 = '',
    this.yetkili2 = '',
  });

  /// Alan -> değer eşlemesinden kayıt oluşturur; eksik alanlar boş kalır.
  factory Adres.alanlardan(Map<AdresAlani, String> d, {int? id}) {
    String al(AdresAlani a) => d[a] ?? '';
    return Adres(
      id: id,
      kod: al(AdresAlani.kod),
      ad: al(AdresAlani.ad),
      adres: al(AdresAlani.adres),
      semt: al(AdresAlani.semt),
      sehir: al(AdresAlani.sehir),
      ulke: al(AdresAlani.ulke),
      postaKodu: al(AdresAlani.postaKodu),
      telefon: al(AdresAlani.telefon),
      fax: al(AdresAlani.fax),
      vergiDairesi: al(AdresAlani.vergiDairesi),
      vergiNo: al(AdresAlani.vergiNo),
      eposta: al(AdresAlani.eposta),
      webSitesi: al(AdresAlani.webSitesi),
      yetkili1: al(AdresAlani.yetkili1),
      yetkili2: al(AdresAlani.yetkili2),
    );
  }

  /// Veritabanında boş (null) olan alanlar boş metin olarak okunur.
  factory Adres.fromJson(Map<String, dynamic> json) => Adres.alanlardan(
        {for (final a in AdresAlani.values) a: json[a.name] as String? ?? ''},
        id: json['id'] as int?,
      );

  /// Verilen alanın değeri.
  String operator [](AdresAlani alan) => switch (alan) {
        AdresAlani.kod => kod,
        AdresAlani.ad => ad,
        AdresAlani.adres => adres,
        AdresAlani.semt => semt,
        AdresAlani.sehir => sehir,
        AdresAlani.ulke => ulke,
        AdresAlani.postaKodu => postaKodu,
        AdresAlani.telefon => telefon,
        AdresAlani.fax => fax,
        AdresAlani.vergiDairesi => vergiDairesi,
        AdresAlani.vergiNo => vergiNo,
        AdresAlani.eposta => eposta,
        AdresAlani.webSitesi => webSitesi,
        AdresAlani.yetkili1 => yetkili1,
        AdresAlani.yetkili2 => yetkili2,
      };

  /// Herhangi bir alan [metin]i içeriyorsa true döner.
  bool aramayaUyar(String metin) => arama.aramayaUyar(metin, AdresAlani.values.map((a) => this[a]));

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        for (final a in AdresAlani.values) a.name: this[a],
      };
}
