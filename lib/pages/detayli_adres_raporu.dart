import 'package:flutter/material.dart';

import '../models/adres.dart';

/// Tüm kayıtları bütün alanlarıyla listeler; herhangi bir alana göre aranabilir.
class DetayliAdresRaporu extends StatefulWidget {
  final List<Adres> kayitlar;

  const DetayliAdresRaporu({super.key, required this.kayitlar});

  @override
  State<DetayliAdresRaporu> createState() => _DetayliAdresRaporuState();
}

class _DetayliAdresRaporuState extends State<DetayliAdresRaporu> {
  String _arama = '';

  List<Adres> get _filtrelenmis => widget.kayitlar.where((k) => k.aramayaUyar(_arama)).toList();

  @override
  Widget build(BuildContext context) {
    final liste = _filtrelenmis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detaylı Adres Raporu'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Kayıtlarda ara',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (deger) => setState(() => _arama = deger),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${liste.length} kayıt listeleniyor', style: const TextStyle(color: Colors.black54)),
            ),
          ),
          Expanded(
            child: liste.isEmpty
                ? const Center(child: Text('Eşleşen kayıt bulunamadı.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: liste.length,
                    itemBuilder: (context, i) => _kayitKarti(liste[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _kayitKarti(Adres k) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k.ad, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Kod: ${k.kod}', style: const TextStyle(color: Colors.black54)),
            const Divider(),
            _satir(Icons.home_outlined, k.adres),
            _satir(Icons.location_city, k.sehir),
            _satir(Icons.phone, k.telefon),
            _satir(Icons.email_outlined, k.eposta),
          ],
        ),
      ),
    );
  }

  Widget _satir(IconData ikon, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(ikon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(deger.isEmpty ? '-' : deger)),
        ],
      ),
    );
  }
}
