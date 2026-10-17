import 'package:flutter/material.dart';

import '../models/adres.dart';

/// Kayıtların genel sayılarını ve şehirlere göre dağılımını gösterir.
class OzetAdresRaporu extends StatelessWidget {
  final List<Adres> kayitlar;

  const OzetAdresRaporu({super.key, required this.kayitlar});

  /// Şehir -> kayıt sayısı, çoktan aza sıralı. Şehri boş olanlar "Belirtilmemiş" altında toplanır.
  List<MapEntry<String, int>> get _sehirDagilimi {
    final sayilar = <String, int>{};
    for (final k in kayitlar) {
      final sehir = k.sehir.isEmpty ? 'Belirtilmemiş' : k.sehir;
      sayilar[sehir] = (sayilar[sehir] ?? 0) + 1;
    }
    return sayilar.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  @override
  Widget build(BuildContext context) {
    final dagilim = _sehirDagilimi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özet Adres Raporu'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ozetKarti('Toplam Kayıt', kayitlar.length, Icons.list_alt, Colors.blue),
              _ozetKarti('Şehir Sayısı', dagilim.length, Icons.location_city, Colors.teal),
              _ozetKarti('Telefonu Olan', kayitlar.where((k) => k.telefon.isNotEmpty).length, Icons.phone, Colors.green),
              _ozetKarti('E-postası Olan', kayitlar.where((k) => k.eposta.isNotEmpty).length, Icons.email, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          const Text('ŞEHİRLERE GÖRE DAĞILIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
          const Divider(),
          if (dagilim.isEmpty)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Henüz kayıt yok.')))
          else
            for (final e in dagilim)
              ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(e.key),
                trailing: Text('${e.value} kayıt', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
        ],
      ),
    );
  }

  Widget _ozetKarti(String baslik, int deger, IconData ikon, Color renk) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ikon, color: renk),
              const SizedBox(height: 8),
              Text('$deger', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(baslik, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
