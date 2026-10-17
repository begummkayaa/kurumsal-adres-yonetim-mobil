import '../utils/arama.dart' as arama;

class Adres {
  final String kod;
  final String ad;
  final String adres;
  final String sehir;
  final String telefon;
  final String eposta;

  const Adres({
    required this.kod,
    required this.ad,
    this.adres = '',
    this.sehir = '',
    this.telefon = '',
    this.eposta = '',
  });

  factory Adres.fromJson(Map<String, dynamic> json) {
    return Adres(
      kod: json['kod'] as String,
      ad: json['ad'] as String,
      adres: json['adres'] as String? ?? '',
      sehir: json['sehir'] as String? ?? '',
      telefon: json['telefon'] as String? ?? '',
      eposta: json['eposta'] as String? ?? '',
    );
  }

  /// Kod, ad, adres, şehir, telefon veya e-posta [metin]i içeriyorsa true döner.
  bool aramayaUyar(String metin) => arama.aramayaUyar(metin, [kod, ad, adres, sehir, telefon, eposta]);

  Map<String, dynamic> toJson() => {
        'kod': kod,
        'ad': ad,
        'adres': adres,
        'sehir': sehir,
        'telefon': telefon,
        'eposta': eposta,
      };
}
