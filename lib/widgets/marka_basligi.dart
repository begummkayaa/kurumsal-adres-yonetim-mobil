import 'package:flutter/material.dart';

/// Üst çubuktaki logo, firma adı ve alt başlık (web sürümündeki gibi).
class MarkaBasligi extends StatelessWidget {
  const MarkaBasligi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.apartment, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MEGA İŞ ÇÖZÜMLERİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                'KURUMSAL KAYNAK & ADRES YÖNETİMİ',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.white60),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
