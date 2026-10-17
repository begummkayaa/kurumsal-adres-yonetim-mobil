import 'package:flutter/material.dart';

import 'pages/ana_sayfa.dart';
import 'services/adres_api.dart';
import 'services/kur_api.dart';
import 'tema.dart';

void main() {
  runApp(const KurumsalMobilApp());
}

class KurumsalMobilApp extends StatelessWidget {
  /// Testlerde gerçek API'ye bağlanmamak için dışarıdan verilebilir.
  final AdresApi? adresApi;
  final KurApi? kurApi;

  const KurumsalMobilApp({super.key, this.adresApi, this.kurApi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mega İş Çözümleri',
      theme: uygulamaTemasi,
      home: AnaSayfa(adresApi: adresApi, kurApi: kurApi),
    );
  }
}
