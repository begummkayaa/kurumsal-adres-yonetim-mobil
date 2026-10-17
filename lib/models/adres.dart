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

  Map<String, dynamic> toJson() => {
        'kod': kod,
        'ad': ad,
        'adres': adres,
        'sehir': sehir,
        'telefon': telefon,
        'eposta': eposta,
      };
}
