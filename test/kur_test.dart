import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mega_mobil_proje/main.dart';
import 'package:mega_mobil_proje/models/kur.dart';
import 'package:mega_mobil_proje/pages/tcmb_kur_arsivi.dart';
import 'package:mega_mobil_proje/services/ayar_deposu.dart';

import 'sahte_api.dart';

/// Web sürümünün yazdığı biçimde iki arşiv kaydı.
List<Map<String, dynamic>> ornekArsiv() => [
      {'id': 2, 'tarih': '2026-10-16T16:05:09', 'dolar': 49.5204, 'euro': 55.7014, 'durum': 'Güncel Bugünün Kuru'},
      {
        'id': 1,
        'tarih': '2026-09-17T13:47:52.773',
        'dolar': 48.7384,
        'euro': 56.2498,
        'durum': 'En Son Açıklanan Geçmiş İş Günü Kuru (15:30 Öncesi / Tatil Modu)',
      },
    ];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('API yanıtı KurKaydi’na çevriliyor, tarih yerel saat olarak okunuyor', () {
    final k = KurKaydi.fromJson(ornekArsiv().last);
    expect(k.tarih, DateTime(2026, 9, 17, 13, 47, 52, 773));
    expect(k.dolar, 48.7384);
    expect(k.guncel, isFalse);
    expect(KurKaydi.fromJson(ornekArsiv().first).guncel, isTrue);
  });

  test('bugün çekim yapıldı mı bilgisi arşivden okunuyor', () async {
    final sunucu = SahteKurSunucusu(arsiv: ornekArsiv());
    expect(await sunucu.api.bugunCekildiMi(DateTime(2026, 10, 16, 20)), isTrue);
    expect(await sunucu.api.bugunCekildiMi(DateTime(2026, 10, 17, 9)), isFalse);
  });

  test('otomatik kur servisi ayarı cihazda saklanıyor, varsayılan kapalı', () async {
    final ayarlar = AyarDeposu();
    expect(await ayarlar.otomatikKurServisiAcikMi(), isFalse);
    await ayarlar.otomatikKurServisiAyarla(true);
    expect(await ayarlar.otomatikKurServisiAcikMi(), isTrue);
  });

  group('TCMB Döviz Arşivi sayfası', () {
    Future<void> ac(WidgetTester tester, SahteKurSunucusu sunucu) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: TcmbKurArsivi(kurApi: sunucu.api)));
      await tester.pumpAndSettle();
    }

    testWidgets('veritabanındaki çekimleri tarih, kur ve durumla listeliyor', (tester) async {
      await ac(tester, SahteKurSunucusu(arsiv: ornekArsiv()));

      expect(find.text('Listelenen Arşiv Kaydı: 2'), findsOneWidget);
      expect(find.text('17.09.2026 13:47:52'), findsOneWidget);
      expect(find.text('48.7384'), findsOneWidget);
      expect(find.text('56.2498'), findsOneWidget);
      expect(find.text('Güncel Bugünün Kuru'), findsOneWidget);
      expect(find.textContaining('Geçmiş İş Günü Kuru'), findsOneWidget);
    });

    testWidgets('boşken nasıl kur çekileceğini söylüyor', (tester) async {
      await ac(tester, SahteKurSunucusu());
      expect(find.textContaining('Güncel Kur Çek'), findsOneWidget);
    });

    testWidgets('API kapalıysa hata ve Tekrar Dene gösteriliyor', (tester) async {
      final sunucu = SahteKurSunucusu(arsiv: ornekArsiv(), kapali: true);
      await ac(tester, sunucu);
      expect(find.textContaining('Sunucuya ulaşılamadı'), findsOneWidget);

      sunucu.kapali = false;
      await tester.tap(find.text('Tekrar Dene'));
      await tester.pumpAndSettle();
      expect(find.text('Listelenen Arşiv Kaydı: 2'), findsOneWidget);
    });

    testWidgets('Otomatik Kur Servisi butonu ayarı açıp kapatıyor', (tester) async {
      await ac(tester, SahteKurSunucusu());
      await tester.tap(find.text('Otomatik Kur Servisi: Kapalı'));
      await tester.pumpAndSettle();
      expect(find.text('Otomatik Kur Servisi: Açık'), findsOneWidget);
      expect(await AyarDeposu().otomatikKurServisiAcikMi(), isTrue);
    });
  });

  group('Ana sayfa', () {
    Future<void> ac(WidgetTester tester, SahteKurSunucusu kurlar) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(KurumsalMobilApp(adresApi: SahteAdresSunucusu().api, kurApi: kurlar.api));
      await tester.pumpAndSettle();
    }

    testWidgets('Güncel Kur Çek kuru API’ye çektirip arşive ekletiyor', (tester) async {
      final kurlar = SahteKurSunucusu();
      await ac(tester, kurlar);

      await tester.tap(find.text('Güncel Kur Çek'));
      await tester.pumpAndSettle();

      expect(find.text('Güncel kur çekildi ve arşive eklendi: USD 49.5204 · EUR 55.7014'), findsOneWidget);
      expect(kurlar.arsiv, hasLength(1));
    });

    testWidgets('TCMB’ye ulaşılamazsa API’nin mesajı gösteriliyor', (tester) async {
      final kurlar = SahteKurSunucusu()..tcmbHatasi = "TCMB'den kur alınamadı: zaman aşımı";
      await ac(tester, kurlar);

      await tester.tap(find.text('Güncel Kur Çek'));
      await tester.pumpAndSettle();
      expect(find.text("TCMB'den kur alınamadı: zaman aşımı"), findsOneWidget);
    });

    testWidgets('otomatik servis açık ve bugün çekim yoksa açılışta kur çekiliyor', (tester) async {
      await AyarDeposu().otomatikKurServisiAyarla(true);
      final kurlar = SahteKurSunucusu(arsiv: ornekArsiv());
      await ac(tester, kurlar);
      expect(kurlar.cekimSayisi, 1);
    });

    testWidgets('otomatik servis açık ama bugün (ör. webden) çekim yapılmışsa tekrar çekilmiyor', (tester) async {
      await AyarDeposu().otomatikKurServisiAyarla(true);
      final kurlar = SahteKurSunucusu(arsiv: [
        {'id': 9, 'tarih': DateTime.now().toIso8601String(), 'dolar': 49.5, 'euro': 55.7, 'durum': 'Güncel Bugünün Kuru'},
      ]);
      await ac(tester, kurlar);
      expect(kurlar.cekimSayisi, 0);
    });

    testWidgets('otomatik servis kapalıysa açılışta kur çekilmiyor', (tester) async {
      final kurlar = SahteKurSunucusu();
      await ac(tester, kurlar);
      expect(kurlar.cekimSayisi, 0);
    });
  });
}
