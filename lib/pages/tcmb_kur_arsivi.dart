import 'package:flutter/material.dart';

import '../models/kur.dart';
import '../services/api_istemcisi.dart';
import '../services/ayar_deposu.dart';
import '../services/kur_api.dart';
import '../tema.dart';
import '../utils/tarih.dart';
import '../widgets/kayit_tablosu.dart';
import '../widgets/marka_basligi.dart';
import '../widgets/tablo_paneli.dart';

/// Web ve masaüstü sürümleriyle ortak TCMB Döviz Arşivi (DovizGecmisi tablosu).
class TcmbKurArsivi extends StatefulWidget {
  final KurApi kurApi;

  const TcmbKurArsivi({super.key, required this.kurApi});

  @override
  State<TcmbKurArsivi> createState() => _TcmbKurArsiviState();
}

class _TcmbKurArsiviState extends State<TcmbKurArsivi> {
  final _ayarlar = AyarDeposu();
  List<KurKaydi>? _arsiv;
  String? _hata;
  bool _otomatikAcik = false;

  @override
  void initState() {
    super.initState();
    _ayarlar.otomatikKurServisiAcikMi().then((acik) {
      if (mounted) setState(() => _otomatikAcik = acik);
    });
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _arsiv = null;
      _hata = null;
    });
    try {
      final arsiv = await widget.kurApi.listele();
      if (mounted) setState(() => _arsiv = arsiv);
    } on ApiHatasi catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _otomatikDegistir() async {
    final yeni = !_otomatikAcik;
    await _ayarlar.otomatikKurServisiAyarla(yeni);
    if (!mounted) return;
    setState(() => _otomatikAcik = yeni);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(yeni
            ? 'Otomatik kur servisi açıldı: arşivde o günün kuru yoksa uygulama açılışında çekilecek.'
            : 'Otomatik kur servisi kapatıldı.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final arsiv = _arsiv;
    return Scaffold(
      appBar: AppBar(
        title: const MarkaBasligi(),
        actions: [IconButton(onPressed: _yukle, icon: const Icon(Icons.refresh), tooltip: 'Arşivi yenile')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TabloPaneli(
          baslik: 'TCMB Döviz Arşivi',
          sagUst: OutlinedButton.icon(
            onPressed: _otomatikDegistir,
            icon: Icon(_otomatikAcik ? Icons.toggle_on : Icons.toggle_off, size: 22),
            label: Text('Otomatik Kur Servisi: ${_otomatikAcik ? 'Açık' : 'Kapalı'}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _otomatikAcik ? const Color(0xFF7EE2A8) : Colors.white70,
              side: const BorderSide(color: Colors.white24),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          altSol: const Text('TCMB arşiv kayıtları listelenmektedir.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          altSag: 'Listelenen Arşiv Kaydı: ${arsiv?.length ?? 0}',
          child: _icerik(arsiv),
        ),
      ),
    );
  }

  Widget _icerik(List<KurKaydi>? arsiv) {
    if (_hata != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.cloud_off, color: Colors.red, size: 36),
          const SizedBox(height: 8),
          Text(_hata!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _yukle, icon: const Icon(Icons.refresh), label: const Text('Tekrar Dene')),
        ]),
      );
    }
    return switch (arsiv) {
      null => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      [] => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Henüz kur çekilmedi. Ana sayfadaki "Güncel Kur Çek" butonunu kullanın.')),
        ),
      _ => _tablo(arsiv),
    };
  }

  Widget _tablo(List<KurKaydi> arsiv) {
    String kur(double? deger) => deger?.toStringAsFixed(4) ?? '-';
    return PaneleYayilanTablo(
      tablo: DataTable(
        headingRowColor: tabloBaslikRengi,
        headingTextStyle: tabloBaslikYazisi,
        columns: const [
          DataColumn(label: Text('ÇEKİM TARİHİ')),
          DataColumn(label: Text('ABD DOLARI (\$)'), numeric: true),
          DataColumn(label: Text('EURO (€)'), numeric: true),
          DataColumn(label: Text('DURUM')),
        ],
        rows: [
          for (final k in arsiv)
            DataRow(cells: [
              DataCell(Text('${tarihYaz(k.tarih)} ${saatYaz(k.tarih)}:${k.tarih.second.toString().padLeft(2, '0')}')),
              DataCell(Text(kur(k.dolar), style: const TextStyle(color: Color(0xFF198754), fontWeight: FontWeight.bold))),
              DataCell(Text(kur(k.euro), style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold))),
              DataCell(_durum(k)),
            ]),
        ],
      ),
    );
  }

  Widget _durum(KurKaydi k) {
    if (!k.guncel) return Text(k.durum);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EE),
        border: Border.all(color: const Color(0xFFA3D9B8)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.circle, size: 8, color: Color(0xFF198754)),
        const SizedBox(width: 6),
        Text(k.durum, style: const TextStyle(color: Color(0xFF198754), fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
