import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mega_mobil_proje/main.dart';
import 'package:mega_mobil_proje/models/adres.dart';
import 'package:mega_mobil_proje/pages/detayli_adres_raporu.dart';
import 'package:mega_mobil_proje/pages/ozet_adres_raporu.dart';

const _kayitlar = [
  Adres(kod: 'A1', ad: 'ALFA', sehir: 'Elazığ', telefon: '0424 237 00 00'),
  Adres(kod: 'B2', ad: 'BETA', sehir: 'Elazığ', eposta: 'beta@mega.com'),
  Adres(kod: 'C3', ad: 'GAMA', sehir: 'İstanbul'),
  Adres(kod: 'D4', ad: 'DELTA'),
];

Future<void> sayfayiAc(WidgetTester tester, Widget sayfa) async {
  await tester.pumpWidget(MaterialApp(home: sayfa));
}

/// Özet kartındaki sayıyı, kartın başlığına göre bulur.
Finder kartDegeri(String baslik, String deger) =>
    find.descendant(of: find.widgetWithText(Card, baslik), matching: find.text(deger));

void main() {
  group('Özet Adres Raporu', () {
    testWidgets('toplamları ve şehir dağılımını gösteriyor', (tester) async {
      await sayfayiAc(tester, const OzetAdresRaporu(kayitlar: _kayitlar));

      expect(kartDegeri('Toplam Kayıt', '4'), findsOneWidget);
      expect(kartDegeri('Şehir Sayısı', '3'), findsOneWidget);
      expect(kartDegeri('Telefonu Olan', '1'), findsOneWidget);
      expect(kartDegeri('E-postası Olan', '1'), findsOneWidget);

      expect(find.widgetWithText(ListTile, 'Elazığ'), findsOneWidget);
      expect(find.descendant(of: find.widgetWithText(ListTile, 'Elazığ'), matching: find.text('2 kayıt')), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Belirtilmemiş'), findsOneWidget);
    });

    testWidgets('kayıt yoksa bilgi veriyor', (tester) async {
      await sayfayiAc(tester, const OzetAdresRaporu(kayitlar: []));
      expect(find.text('Henüz kayıt yok.'), findsOneWidget);
    });
  });

  group('Detaylı Adres Raporu', () {
    testWidgets('tüm kayıtları listeliyor', (tester) async {
      await sayfayiAc(tester, const DetayliAdresRaporu(kayitlar: _kayitlar));

      expect(find.text('4 kayıt listeleniyor'), findsOneWidget);
      expect(find.text('ALFA'), findsOneWidget);
      expect(find.text('Kod: B2'), findsOneWidget);
    });

    testWidgets('aramaya göre filtreliyor', (tester) async {
      await sayfayiAc(tester, const DetayliAdresRaporu(kayitlar: _kayitlar));

      await tester.enterText(find.byType(TextField), 'elazığ');
      await tester.pump();
      expect(find.text('2 kayıt listeleniyor'), findsOneWidget);
      expect(find.text('GAMA'), findsNothing);

      await tester.enterText(find.byType(TextField), 'yok böyle bir şey');
      await tester.pump();
      expect(find.text('Eşleşen kayıt bulunamadı.'), findsOneWidget);
    });
  });

  testWidgets('Menüden raporlar açılıyor', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KurumsalMobilApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raporlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Özet Adres Raporu'));
    await tester.pumpAndSettle();

    expect(find.byType(OzetAdresRaporu), findsOneWidget);
    expect(kartDegeri('Toplam Kayıt', '3'), findsOneWidget);
  });
}
