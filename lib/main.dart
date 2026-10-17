import 'package:flutter/material.dart';

import 'pages/ana_sayfa.dart';
import 'services/tcmb_servisi.dart';
import 'tema.dart';

void main() {
  runApp(const KurumsalMobilApp());
}

class KurumsalMobilApp extends StatelessWidget {
  /// Testlerde gerçek TCMB'ye bağlanmamak için dışarıdan verilebilir.
  final TcmbServisi? tcmbServisi;

  const KurumsalMobilApp({super.key, this.tcmbServisi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mega İş Çözümleri',
      theme: uygulamaTemasi,
      home: AnaSayfa(tcmbServisi: tcmbServisi),
    );
  }
}
