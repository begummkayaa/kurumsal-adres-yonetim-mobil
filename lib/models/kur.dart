/// TCMB bültenindeki tek bir döviz kuru. Bazı dövizlerde (ör. XDR) efektif kur yayımlanmaz, o alanlar null olur.
class Kur {
  final String kod;
  final String isim;
  final int birim;
  final double? dovizAlis;
  final double? dovizSatis;
  final double? efektifAlis;
  final double? efektifSatis;

  const Kur({
    required this.kod,
    required this.isim,
    required this.birim,
    this.dovizAlis,
    this.dovizSatis,
    this.efektifAlis,
    this.efektifSatis,
  });
}

/// Bir günün kur bülteni. [tarih], bültenin gerçekten yayımlandığı gündür.
class KurBulteni {
  final DateTime tarih;
  final List<Kur> kurlar;

  const KurBulteni({required this.tarih, required this.kurlar});
}
