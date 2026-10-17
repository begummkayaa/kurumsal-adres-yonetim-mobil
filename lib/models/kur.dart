/// TCMB Döviz Arşivi'ndeki (DovizGecmisi tablosu) bir kur çekimi.
class KurKaydi {
  static const guncelDurum = 'Güncel Bugünün Kuru';

  final int id;
  final DateTime tarih;
  final double? dolar;
  final double? euro;

  /// Web sürümüyle aynı metin: "Güncel Bugünün Kuru" ya da
  /// "En Son Açıklanan Geçmiş İş Günü Kuru (15:30 Öncesi / Tatil Modu)".
  final String durum;

  const KurKaydi({required this.id, required this.tarih, this.dolar, this.euro, this.durum = ''});

  bool get guncel => durum == guncelDurum;

  factory KurKaydi.fromJson(Map<String, dynamic> json) => KurKaydi(
        id: json['id'] as int,
        tarih: DateTime.parse(json['tarih'] as String),
        dolar: (json['dolar'] as num?)?.toDouble(),
        euro: (json['euro'] as num?)?.toDouble(),
        durum: json['durum'] as String? ?? '',
      );
}
