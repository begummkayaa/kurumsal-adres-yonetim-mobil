import 'package:flutter/material.dart';

import 'pages/ana_sayfa.dart';
import 'tema.dart';

void main() {
  runApp(const KurumsalMobilApp());
}

class KurumsalMobilApp extends StatelessWidget {
  const KurumsalMobilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mega İş Çözümleri',
      theme: uygulamaTemasi,
      home: const AnaSayfa(),
    );
  }
}
