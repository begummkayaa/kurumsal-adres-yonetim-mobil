import 'package:flutter/material.dart' show DateUtils;

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

/// Çekilen kurun, çekildiği gün için güncel olup olmadığı (web sürümündeki "Durum" sütunu).
enum KurDurumu {
  guncel('Güncel Bugünün Kuru'),
  gecmisIsGunu('En Son Açıklanan Geçmiş İş Günü Kuru (15:30 Öncesi / Tatil Modu)');

  final String aciklama;
  const KurDurumu(this.aciklama);
}

/// "Güncel Kur Çek" ile alınıp arşive yazılan dolar/euro kuru (TCMB döviz alış).
class KurKaydi {
  final DateTime cekimTarihi;
  final DateTime bultenTarihi;
  final double usd;
  final double eur;

  const KurKaydi({required this.cekimTarihi, required this.bultenTarihi, required this.usd, required this.eur});

  /// TCMB bugünün kurunu 15:30'da açıklar; öncesinde veya tatilde önceki iş gününün kuru gelir.
  KurDurumu get durum => DateUtils.isSameDay(cekimTarihi, bultenTarihi) ? KurDurumu.guncel : KurDurumu.gecmisIsGunu;

  factory KurKaydi.fromJson(Map<String, dynamic> json) => KurKaydi(
        cekimTarihi: DateTime.parse(json['cekimTarihi'] as String),
        bultenTarihi: DateTime.parse(json['bultenTarihi'] as String),
        usd: (json['usd'] as num).toDouble(),
        eur: (json['eur'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'cekimTarihi': cekimTarihi.toIso8601String(),
        'bultenTarihi': bultenTarihi.toIso8601String(),
        'usd': usd,
        'eur': eur,
      };
}
