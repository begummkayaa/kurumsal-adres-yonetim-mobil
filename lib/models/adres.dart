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
}
