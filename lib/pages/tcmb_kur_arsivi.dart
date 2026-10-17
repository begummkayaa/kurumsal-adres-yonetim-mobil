import 'package:flutter/material.dart';

import '../models/kur.dart';
import '../services/kur_arsivi_deposu.dart';
import '../tema.dart';
import '../utils/tarih.dart';
import '../widgets/kayit_tablosu.dart';
import '../widgets/marka_basligi.dart';
import '../widgets/tablo_paneli.dart';

/// "Güncel Kur Çek" ile alınan dolar/euro kurlarının arşivi (web sürümündeki TCMB Döviz Arşivi).
class TcmbKurArsivi extends StatefulWidget {
  const TcmbKurArsivi({super.key});

  @override
  State<TcmbKurArsivi> createState() => _TcmbKurArsiviState();
}

class _TcmbKurArsiviState extends State<TcmbKurArsivi> {
  final _depo = KurArsiviDeposu();
  List<KurKaydi>? _arsiv;
  bool _otomatikAcik = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final arsiv = await _depo.yukle();
    final otomatik = await _depo.otomatikServisAcikMi();
    if (!mounted) return;
    setState(() {
      _arsiv = arsiv;
      _otomatikAcik = otomatik;
    });
  }

  Future<void> _otomatikDegistir() async {
    final yeni = !_otomatikAcik;
    await _depo.otomatikServisAyarla(yeni);
    if (!mounted) return;
    setState(() => _otomatikAcik = yeni);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(yeni
            ? 'Otomatik kur servisi açıldı: uygulama her gün ilk açıldığında güncel kur çekilecek.'
            : 'Otomatik kur servisi kapatıldı.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final arsiv = _arsiv;
    return Scaffold(
      appBar: AppBar(title: const MarkaBasligi()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TabloPaneli(
          baslik: 'TCMB Döviz Arşivi',
          sagUst: OutlinedButton.icon(
            onPressed: arsiv == null ? null : _otomatikDegistir,
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
          child: switch (arsiv) {
            null => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            [] => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Henüz kur çekilmedi. Ana sayfadaki "Güncel Kur Çek" butonunu kullanın.')),
              ),
            _ => _tablo(arsiv),
          },
        ),
      ),
    );
  }

  Widget _tablo(List<KurKaydi> arsiv) {
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
              DataCell(Text('${tarihYaz(k.cekimTarihi)} ${saatYaz(k.cekimTarihi)}:${k.cekimTarihi.second.toString().padLeft(2, '0')}')),
              DataCell(Text(k.usd.toStringAsFixed(4), style: const TextStyle(color: Color(0xFF198754), fontWeight: FontWeight.bold))),
              DataCell(Text(k.eur.toStringAsFixed(4), style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold))),
              DataCell(_durum(k)),
            ]),
        ],
      ),
    );
  }

  Widget _durum(KurKaydi k) {
    if (k.durum == KurDurumu.gecmisIsGunu) {
      return Text('${k.durum.aciklama} · ${tarihYaz(k.bultenTarihi)} bülteni');
    }
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
        Text(k.durum.aciklama, style: const TextStyle(color: Color(0xFF198754), fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
