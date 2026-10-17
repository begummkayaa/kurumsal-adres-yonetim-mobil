import 'package:flutter/material.dart';

/// Ana sayfadaki hap şeklindeki işlem butonu.
/// Dolu (Kaydet, Sil, ...) ya da [cerceveli] (gezinme, Ekranı Temizle) olabilir.
class IslemButonu extends StatelessWidget {
  final String metin;
  final Color renk;
  final IconData ikon;
  final VoidCallback onPressed;
  final bool cerceveli;

  /// Dolu butonda yazı rengi (açık renkli butonlarda koyu yazı için).
  final Color yaziRengi;

  const IslemButonu({
    super.key,
    required this.metin,
    required this.renk,
    required this.ikon,
    required this.onPressed,
    this.cerceveli = false,
    this.yaziRengi = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final yazi = cerceveli ? renk : yaziRengi;
    return ActionChip(
      backgroundColor: cerceveli ? Colors.white : renk,
      side: BorderSide(color: cerceveli ? renk.withValues(alpha: 0.5) : renk),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: yazi, fontWeight: FontWeight.bold, fontSize: 13),
      avatar: Icon(ikon, color: yazi, size: 16),
      label: Text(metin),
      onPressed: onPressed,
    );
  }
}

/// Etiketli, kenarlıklı form metin alanı.
class FormAlani extends StatelessWidget {
  final String etiket;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? klavye;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? dogrula;

  const FormAlani({
    super.key,
    required this.etiket,
    required this.controller,
    this.maxLines = 1,
    this.klavye,
    this.focusNode,
    this.dogrula,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: dogrula,
        maxLines: maxLines,
        keyboardType: klavye,
        decoration: InputDecoration(
          labelText: etiket,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// İkonlu bölüm başlığı ve altındaki çizgi.
class BolumBasligi extends StatelessWidget {
  final String baslik;
  final IconData ikon;

  /// Başlığın sağında gösterilen küçük açıklama.
  final String? sag;

  const BolumBasligi({super.key, required this.baslik, required this.ikon, this.sag});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Icon(ikon, color: Colors.grey),
          const SizedBox(width: 8),
          // Dar ekranda başlık ve sağdaki açıklama taşmak yerine alt satıra geçer.
          Expanded(child: Text(baslik, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))),
          if (sag != null)
            Flexible(child: Text(sag!, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, color: Colors.black54))),
        ]),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
