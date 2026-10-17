import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/kur.dart';
import '../services/tcmb_servisi.dart';
import '../tema.dart';
import '../utils/tarih.dart';

/// Seçilen tarihteki TCMB döviz kurlarını gösterir.
class TcmbKurArsivi extends StatefulWidget {
  final TcmbServisi? servis;

  /// Sayfa açıldığında gösterilecek tarih; verilmezse bugün.
  final DateTime? baslangicTarihi;

  const TcmbKurArsivi({super.key, this.servis, this.baslangicTarihi});

  @override
  State<TcmbKurArsivi> createState() => _TcmbKurArsiviState();
}

class _TcmbKurArsiviState extends State<TcmbKurArsivi> {
  late final TcmbServisi _servis = widget.servis ?? TcmbServisi();
  late DateTime _secilenTarih = widget.baslangicTarihi ?? DateTime.now();
  KurBulteni? _bulten;
  String? _hata;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _getir();
  }

  Future<void> _getir() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final bulten = await _servis.bultenGetir(_secilenTarih);
      if (!mounted) return;
      setState(() => _bulten = bulten);
    } on KurAlinamadi catch (e) {
      if (!mounted) return;
      setState(() {
        _bulten = null;
        // Tarayıcıda TCMB, CORS başlığı göndermediği için istekler engellenir.
        _hata = kIsWeb ? '$e\n\nNot: Tarayıcıda TCMB istekleri CORS nedeniyle engellenebilir; mobil cihazda deneyin.' : '$e';
      });
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _tarihSec() async {
    final tarih = await showDatePicker(
      context: context,
      initialDate: _secilenTarih,
      firstDate: DateTime(1996, 4, 16),
      lastDate: DateTime.now(),
      helpText: 'Kur tarihi seçin',
    );
    if (tarih == null) return;
    setState(() => _secilenTarih = tarih);
    _getir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TCMB Kur Arşivi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _yukleniyor ? null : _tarihSec,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(tarihYaz(_secilenTarih)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _yukleniyor ? null : _getir, icon: const Icon(Icons.refresh), tooltip: 'Yenile'),
            ],
          ),
          const SizedBox(height: 16),
          ..._icerik(),
        ],
      ),
    );
  }

  List<Widget> _icerik() {
    if (_yukleniyor) {
      return const [Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))];
    }
    if (_hata != null) {
      return [
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(_hata!)),
              ],
            ),
          ),
        ),
      ];
    }
    final bulten = _bulten;
    if (bulten == null) return const [];

    final secilenGun = DateTime(_secilenTarih.year, _secilenTarih.month, _secilenTarih.day);
    return [
      if (bulten.tarih != secilenGun)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${tarihYaz(secilenGun)} tarihinde kur yayımlanmadığı için ${tarihYaz(bulten.tarih)} tarihli bülten gösteriliyor.',
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      Text('${tarihYaz(bulten.tarih)} tarihli bülten', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
      const Divider(),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: tabloBaslikRengi,
          headingTextStyle: tabloBaslikYazisi,
          columns: const [
            DataColumn(label: Text('KOD')),
            DataColumn(label: Text('DÖVİZ')),
            DataColumn(label: Text('BİRİM'), numeric: true),
            DataColumn(label: Text('DÖVİZ ALIŞ'), numeric: true),
            DataColumn(label: Text('DÖVİZ SATIŞ'), numeric: true),
            DataColumn(label: Text('EFEKTİF ALIŞ'), numeric: true),
            DataColumn(label: Text('EFEKTİF SATIŞ'), numeric: true),
          ],
          rows: [
            for (final k in bulten.kurlar)
              DataRow(cells: [
                DataCell(Text(k.kod, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(k.isim)),
                DataCell(Text('${k.birim}')),
                DataCell(Text(_sayiYaz(k.dovizAlis))),
                DataCell(Text(_sayiYaz(k.dovizSatis))),
                DataCell(Text(_sayiYaz(k.efektifAlis))),
                DataCell(Text(_sayiYaz(k.efektifSatis))),
              ]),
          ],
        ),
      ),
    ];
  }

  String _sayiYaz(double? deger) => deger == null ? '-' : deger.toStringAsFixed(4);
}
