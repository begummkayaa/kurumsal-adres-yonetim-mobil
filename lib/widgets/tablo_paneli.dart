import 'package:flutter/material.dart';

import '../tema.dart';

/// Web sürümündeki liste kartı: koyu başlık çubuğu (başlık + arama), içerik ve alt bilgi satırı.
class TabloPaneli extends StatelessWidget {
  final String baslik;
  final TextEditingController aramaController;
  final Widget child;

  /// Alt satırın solundaki içerik (ör. PDF butonu).
  final Widget? altSol;

  /// Alt satırın sağındaki yazı (ör. "Listelenen Kayıt Sayısı: 38").
  final String altSag;

  const TabloPaneli({
    super.key,
    required this.baslik,
    required this.aramaController,
    required this.child,
    required this.altSag,
    this.altSol,
  });

  @override
  Widget build(BuildContext context) {
    final aramaKutusu = SizedBox(
      width: 240,
      height: 38,
      child: TextField(
        key: const Key('tabloArama'),
        controller: aramaController,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'İsim veya Kod ara...',
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 18),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: anaRenk,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.menu, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text('  |  MEGA İŞ ÇÖZÜMLERİ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
                aramaKutusu,
              ],
            ),
          ),
          child,
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                ?altSol,
                const Spacer(),
                Text(altSag, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
