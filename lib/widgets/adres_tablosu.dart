import 'package:flutter/material.dart';

import '../models/adres.dart';
import '../tema.dart';

/// Kayıtları gösteren, yatayda kaydırılabilen tablo. Satıra tıklanınca [onSec],
/// kaydın [kayitlar] içindeki sırasıyla çağrılır.
class AdresTablosu extends StatelessWidget {
  final List<Adres> kayitlar;

  /// Gösterilecek kayıtların [kayitlar] içindeki sıraları (ör. arama sonucu).
  final List<int> gosterilecekler;
  final int? seciliIndex;
  final ValueChanged<int> onSec;

  const AdresTablosu({
    super.key,
    required this.kayitlar,
    required this.gosterilecekler,
    required this.seciliIndex,
    required this.onSec,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: tabloBaslikRengi,
        headingTextStyle: tabloBaslikYazisi,
        dataRowMinHeight: 60,
        dataRowMaxHeight: 60,
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('KOD')),
          DataColumn(label: Text('AD')),
          DataColumn(label: Text('ŞEHİR')),
          DataColumn(label: Text('TELEFON')),
          DataColumn(label: Text('E-POSTA')),
        ],
        rows: [
          for (final i in gosterilecekler)
            DataRow(
              selected: i == seciliIndex,
              onSelectChanged: (_) => onSec(i),
              cells: [
                DataCell(Text(kayitlar[i].kod)),
                DataCell(Text(kayitlar[i].ad)),
                DataCell(Text(kayitlar[i].sehir)),
                DataCell(Text(kayitlar[i].telefon)),
                DataCell(Text(kayitlar[i].eposta)),
              ],
            ),
        ],
      ),
    );
  }
}
