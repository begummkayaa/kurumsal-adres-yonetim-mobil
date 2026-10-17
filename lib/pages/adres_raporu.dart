import 'package:flutter/material.dart';

import '../models/adres.dart';
import '../widgets/kayit_tablosu.dart';
import '../widgets/marka_basligi.dart';
import '../widgets/tablo_paneli.dart';

/// Web sürümündeki rapor sayfası: seçili sütunlarla, aranabilir kayıt tablosu.
class AdresRaporu extends StatefulWidget {
  final String baslik;
  final List<Adres> kayitlar;
  final List<AdresAlani> alanlar;

  const AdresRaporu({super.key, required this.baslik, required this.kayitlar, required this.alanlar});

  @override
  State<AdresRaporu> createState() => _AdresRaporuState();
}

class _AdresRaporuState extends State<AdresRaporu> {
  final _aramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aramaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  List<int> get _gorunenIndeksler => [
        for (var i = 0; i < widget.kayitlar.length; i++)
          if (widget.kayitlar[i].aramayaUyar(_aramaController.text)) i,
      ];

  @override
  Widget build(BuildContext context) {
    final gorunenler = _gorunenIndeksler;
    return Scaffold(
      appBar: AppBar(title: const MarkaBasligi()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TabloPaneli(
          baslik: widget.baslik,
          aramaController: _aramaController,
          altSag: 'Listelenen Kayıt Sayısı: ${gorunenler.length}',
          child: gorunenler.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(widget.kayitlar.isEmpty ? 'Henüz kayıt yok.' : 'Aramaya uyan kayıt yok.')),
                )
              : KayitTablosu(
                  kayitlar: widget.kayitlar,
                  alanlar: widget.alanlar,
                  ozelBasliklar: const {AdresAlani.semt: 'SEMT'},
                  gosterilecekler: gorunenler,
                ),
        ),
      ),
    );
  }
}

/// Rapor 1: temel adres ve iletişim bilgileri.
class OzetAdresRaporu extends StatelessWidget {
  static const alanlar = [
    AdresAlani.kod,
    AdresAlani.ad,
    AdresAlani.adres,
    AdresAlani.semt,
    AdresAlani.sehir,
    AdresAlani.telefon,
    AdresAlani.eposta,
  ];

  final List<Adres> kayitlar;

  const OzetAdresRaporu({super.key, required this.kayitlar});

  @override
  Widget build(BuildContext context) => AdresRaporu(baslik: 'Özet Adres Raporu', kayitlar: kayitlar, alanlar: alanlar);
}

/// Rapor 2: kayıtların tüm alanları.
class DetayliAdresRaporu extends StatelessWidget {
  static const alanlar = AdresAlani.values;

  final List<Adres> kayitlar;

  const DetayliAdresRaporu({super.key, required this.kayitlar});

  @override
  Widget build(BuildContext context) => AdresRaporu(baslik: 'Detaylı Adres Raporu', kayitlar: kayitlar, alanlar: alanlar);
}
