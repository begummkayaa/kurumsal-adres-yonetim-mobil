import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mega_mobil_proje/main.dart';
import 'package:mega_mobil_proje/models/adres.dart';
import 'package:mega_mobil_proje/pages/adres_raporu.dart';

const _kayitlar = [
  Adres(kod: 'A1', ad: 'ALFA', semt: 'Konak', sehir: 'İzmir', vergiNo: '1111111111', yetkili1: 'Ali Kaya'),
  Adres(kod: 'B2', ad: 'BETA', sehir: 'Elazığ', eposta: 'beta@mega.com'),
  Adres(kod: 'C3', ad: 'GAMA', sehir: 'Elazığ'),
];

Future<void> sayfayiAc(WidgetTester tester, Widget sayfa) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: sayfa));
}

Finder tablodaki(String metin) => find.descendant(of: find.byType(DataTable), matching: find.text(metin));

void main() {
  group('Özet Adres Raporu', () {
    testWidgets('web sürümündeki 7 sütunu gösteriyor', (tester) async {
      await sayfayiAc(tester, const OzetAdresRaporu(kayitlar: _kayitlar));

      for (final baslik in ['KOD', 'AD', 'ADRES', 'SEMT', 'ŞEHİR', 'TELEFON', 'E-POSTA ADRESİ']) {
        expect(tablodaki(baslik), findsOneWidget, reason: baslik);
      }
      expect(tablodaki('VERGİ NO'), findsNothing);
      expect(tablodaki('Konak'), findsOneWidget);
      expect(find.text('Listelenen Kayıt Sayısı: 3'), findsOneWidget);
    });

    testWidgets('kayıt yoksa bilgi veriyor', (tester) async {
      await sayfayiAc(tester, const OzetAdresRaporu(kayitlar: []));
      expect(find.text('Henüz kayıt yok.'), findsOneWidget);
    });
  });

  group('Detaylı Adres Raporu', () {
    testWidgets('tüm alanları gösteriyor', (tester) async {
      await sayfayiAc(tester, const DetayliAdresRaporu(kayitlar: _kayitlar));

      for (final baslik in ['VERGİ DAİRESİ', 'VERGİ NO', 'WEB SİTESİ', 'YETKİLİ 1', 'YETKİLİ 2']) {
        expect(tablodaki(baslik), findsOneWidget, reason: baslik);
      }
      expect(tablodaki('1111111111'), findsOneWidget);
      expect(tablodaki('Ali Kaya'), findsOneWidget);
    });

    testWidgets('aramaya göre filtreliyor', (tester) async {
      await sayfayiAc(tester, const DetayliAdresRaporu(kayitlar: _kayitlar));

      await tester.enterText(find.byKey(const Key('tabloArama')), 'elazığ');
      await tester.pump();
      expect(find.text('Listelenen Kayıt Sayısı: 2'), findsOneWidget);
      expect(tablodaki('ALFA'), findsNothing);

      await tester.enterText(find.byKey(const Key('tabloArama')), 'yok böyle bir şey');
      await tester.pump();
      expect(find.text('Aramaya uyan kayıt yok.'), findsOneWidget);
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
    await tester.tap(find.text('Detaylı Adres Raporu'));
    await tester.pumpAndSettle();

    expect(find.byType(DetayliAdresRaporu), findsOneWidget);
    expect(find.text('Listelenen Kayıt Sayısı: 3'), findsOneWidget);
  });
}
