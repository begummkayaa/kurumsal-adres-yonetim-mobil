import 'package:flutter/material.dart';

/// Ana sayfadaki renkli işlem butonu (Kaydet, Sil, ...).
class IslemButonu extends StatelessWidget {
  final String metin;
  final Color renk;
  final IconData ikon;
  final VoidCallback onPressed;

  const IslemButonu({super.key, required this.metin, required this.renk, required this.ikon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: renk,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      avatar: Icon(ikon, color: Colors.white, size: 18),
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

  const BolumBasligi({super.key, required this.baslik, required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Icon(ikon, color: Colors.grey),
          const SizedBox(width: 8),
          Text(baslik, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
        ]),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
