import 'package:flutter/material.dart';

import '../models/adres.dart';
import '../tema.dart';

/// Kayıtları verilen [alanlar] sütunlarıyla gösteren, yatayda kaydırılabilen tablo.
///
/// [onSec] verilirse her satırın başında "Seç" bağlantısı olur ve satıra tıklamak da seçer;
/// [onSec], kaydın [kayitlar] içindeki sırasıyla çağrılır.
class KayitTablosu extends StatelessWidget {
  final List<Adres> kayitlar;
  final List<AdresAlani> alanlar;

  /// Gösterilecek kayıtların [kayitlar] içindeki sıraları (ör. arama sonucu).
  final List<int> gosterilecekler;

  /// Bazı sütunlar için varsayılan başlık yerine kullanılacak başlıklar.
  final Map<AdresAlani, String> ozelBasliklar;
  final int? seciliIndex;
  final ValueChanged<int>? onSec;

  const KayitTablosu({
    super.key,
    required this.kayitlar,
    required this.alanlar,
    required this.gosterilecekler,
    this.ozelBasliklar = const {},
    this.seciliIndex,
    this.onSec,
  });

  /// Uzun metinler (adres, ünvan) bu genişlikte alt satıra geçer.
  static const _enGenisHucre = 200.0;

  @override
  Widget build(BuildContext context) {
    final secilebilir = onSec != null;
    return PaneleYayilanTablo(
      tablo: DataTable(
        headingRowColor: tabloBaslikRengi,
        headingTextStyle: tabloBaslikYazisi,
        dataRowMinHeight: 52,
        dataRowMaxHeight: double.infinity,
        columnSpacing: 20,
        showCheckboxColumn: false,
        columns: [
          if (secilebilir) const DataColumn(label: Text('')),
          for (final a in alanlar) DataColumn(label: Text(ozelBasliklar[a] ?? a.baslik)),
        ],
        rows: [
          for (final i in gosterilecekler)
            DataRow(
              selected: i == seciliIndex,
              onSelectChanged: secilebilir ? (_) => onSec!(i) : null,
              cells: [
                if (secilebilir)
                  DataCell(TextButton(
                    onPressed: () => onSec!(i),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
                    child: const Text('Seç', style: TextStyle(decoration: TextDecoration.underline)),
                  )),
                for (final a in alanlar)
                  DataCell(ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _enGenisHucre),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(kayitlar[i][a]),
                    ),
                  )),
              ],
            ),
        ],
      ),
    );
  }
}

/// Tablo panelden darsa panelin genişliğine yayılır (başlık satırı sonuna kadar uzanır),
/// genişse yatayda kaydırılır.
class PaneleYayilanTablo extends StatelessWidget {
  final DataTable tablo;

  const PaneleYayilanTablo({super.key, required this.tablo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kisit) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(constraints: BoxConstraints(minWidth: kisit.maxWidth), child: tablo),
      ),
    );
  }
}
