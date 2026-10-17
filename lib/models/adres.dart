import '../utils/arama.dart' as arama;

/// Bir adres kaydının alanları. Form, tablolar, raporlar ve PDF bu listeyi kullanır.
/// [name], kayıtların cihazda saklandığı JSON anahtarıdır; değiştirilirse eski kayıtlar okunamaz.
enum AdresAlani {
  kod('Kod', 'KOD'),
  ad('Ad', 'AD'),
  adres('Adres', 'ADRES'),
  semt('Semt', 'SEMT / İLÇE'),
  sehir('Şehir', 'ŞEHİR'),
  ulke('Ülke', 'ÜLKE'),
  postaKodu('Posta Kodu', 'POSTA KODU'),
  telefon('Telefon', 'TELEFON'),
  fax('Fax', 'FAX'),
  vergiDairesi('Vergi Dairesi', 'VERGİ DAİRESİ'),
  vergiNo('Vergi No', 'VERGİ NO'),
  eposta('Mail', 'E-POSTA ADRESİ'),
  webSitesi('Web Sitesi', 'WEB SİTESİ'),
  yetkili1('Yetkili 1', 'YETKİLİ 1'),
  yetkili2('Yetkili 2', 'YETKİLİ 2');

  /// Formdaki etiket.
  final String etiket;

  /// Tablo sütun başlığı.
  final String baslik;

  const AdresAlani(this.etiket, this.baslik);
}

class Adres {
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
  factory Adres.alanlardan(Map<AdresAlani, String> d) {
    String al(AdresAlani a) => d[a] ?? '';
    return Adres(
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

  /// Eski sürümlerde kaydedilmiş, bazı alanları olmayan kayıtlar da okunabilir.
  factory Adres.fromJson(Map<String, dynamic> json) =>
      Adres.alanlardan({for (final a in AdresAlani.values) a: json[a.name] as String? ?? ''});

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

  Map<String, dynamic> toJson() => {for (final a in AdresAlani.values) a.name: this[a]};
}
