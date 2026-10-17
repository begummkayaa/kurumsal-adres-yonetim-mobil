import 'package:flutter/material.dart';

import '../models/adres.dart';
import '../pages/detayli_adres_raporu.dart';
import '../pages/ozet_adres_raporu.dart';
import '../pages/tcmb_kur_arsivi.dart';
import '../tema.dart';

/// Soldan açılan menü: Ana Sayfa ve rapor sayfaları.
class AnaMenu extends StatelessWidget {
  /// Raporlara gönderilecek güncel kayıt listesi.
  final List<Adres> kayitlar;

  const AnaMenu({super.key, required this.kayitlar});

  @override
  Widget build(BuildContext context) {
    /// Menüyü kapatıp verilen sayfayı açar.
    void sayfayaGit(Widget sayfa) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => sayfa));
    }

    const altMenuBoslugu = EdgeInsets.only(left: 50);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(decoration: BoxDecoration(color: anaRenk), child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 24))),
          ListTile(leading: const Icon(Icons.home), title: const Text('Ana Sayfa'), onTap: () => Navigator.pop(context)),
          ExpansionTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Raporlar'),
            children: [
              ListTile(
                title: const Text('Özet Adres Raporu'),
                contentPadding: altMenuBoslugu,
                onTap: () => sayfayaGit(OzetAdresRaporu(kayitlar: List.unmodifiable(kayitlar))),
              ),
              ListTile(
                title: const Text('Detaylı Adres Raporu'),
                contentPadding: altMenuBoslugu,
                onTap: () => sayfayaGit(DetayliAdresRaporu(kayitlar: List.unmodifiable(kayitlar))),
              ),
              ListTile(
                title: const Text('TCMB Kur Arşivi'),
                contentPadding: altMenuBoslugu,
                onTap: () => sayfayaGit(const TcmbKurArsivi()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
