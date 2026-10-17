import 'package:flutter/material.dart';

import '../tema.dart';

/// Web sürümündeki liste kartı: koyu başlık çubuğu (başlık + arama veya bir buton), içerik ve alt bilgi satırı.
class TabloPaneli extends StatelessWidget {
  final String baslik;

  /// Verilirse başlık çubuğunun sağında arama kutusu olur.
  final TextEditingController? aramaController;

  /// Arama yerine başlık çubuğunun sağında gösterilecek içerik (ör. bir buton).
  final Widget? sagUst;
  final Widget child;

  /// Alt satırın solundaki içerik (ör. PDF butonu).
  final Widget? altSol;

  /// Alt satırın sağındaki yazı (ör. "Listelenen Kayıt Sayısı: 38").
  final String altSag;

  const TabloPaneli({
    super.key,
    required this.baslik,
    this.aramaController,
    this.sagUst,
    required this.child,
    required this.altSag,
    this.altSol,
  });

  @override
  Widget build(BuildContext context) {
    final baslikSatiri = Row(children: [
      const Icon(Icons.menu, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const TextSpan(text: '  |  MEGA İŞ ÇÖZÜMLERİ', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);

    final controller = aramaController;
    final aramaKutusu = controller == null
        ? null
        : SizedBox(
            height: 38,
            child: TextField(
              key: const Key('tabloArama'),
              controller: controller,
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
            // Geniş ekranda başlık solda, arama/buton sağda; dar ekranda alt alta.
            child: LayoutBuilder(builder: (context, kisit) {
              final dar = kisit.maxWidth < 520;
              final sag = aramaKutusu == null ? sagUst : (dar ? aramaKutusu : SizedBox(width: 240, child: aramaKutusu));
              if (sag == null) return baslikSatiri;
              if (dar) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [baslikSatiri, const SizedBox(height: 8), sag]);
              }
              return Row(children: [Expanded(child: baslikSatiri), const SizedBox(width: 12), sag]);
            }),
          ),
          child,
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                ?altSol,
                Text(altSag, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
