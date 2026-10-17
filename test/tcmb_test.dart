import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mega_mobil_proje/main.dart';
import 'package:mega_mobil_proje/models/kur.dart';
import 'package:mega_mobil_proje/pages/tcmb_kur_arsivi.dart';
import 'package:mega_mobil_proje/services/kur_arsivi_deposu.dart';
import 'package:mega_mobil_proje/services/tcmb_servisi.dart';

/// 16.10.2026 tarihli gerçek TCMB bülteninden kısaltılmış örnek.
const _ornekBulten = '''<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="isokur.xsl"?>
<Tarih_Date Tarih="16.10.2026" Date="10/16/2026"  Bulten_No="2026/196" >
	<Currency CrossOrder="0" Kod="USD" CurrencyCode="USD">
			<Unit>1</Unit>
			<Isim>ABD DOLARI</Isim>
			<CurrencyName>US DOLLAR</CurrencyName>
			<ForexBuying>49.3573</ForexBuying>
			<ForexSelling>49.4463</ForexSelling>
			<BanknoteBuying>49.3228</BanknoteBuying>
			<BanknoteSelling>49.5204</BanknoteSelling>
			<CrossRateUSD/>
			<CrossRateOther/>
	</Currency>
	<Currency CrossOrder="9" Kod="EUR" CurrencyCode="EUR">
			<Unit>1</Unit>
			<Isim>EURO</Isim>
			<CurrencyName>EURO</CurrencyName>
			<ForexBuying>55.5179</ForexBuying>
			<ForexSelling>55.6180</ForexSelling>
			<BanknoteBuying>55.4790</BanknoteBuying>
			<BanknoteSelling>55.7015</BanknoteSelling>
			<CrossRateUSD/>
			<CrossRateOther>1.1248</CrossRateOther>
	</Currency>
	<Currency CrossOrder="0" Kod="XDR" CurrencyCode="XDR">
		<Unit>1</Unit>
		<Isim>ÖZEL ÇEKME HAKKI (SDR)                            </Isim>
		<CurrencyName>SPECIAL DRAWING RIGHT (SDR)                       </CurrencyName>
		<ForexBuying>66.9840</ForexBuying>
		<ForexSelling/>
		<BanknoteBuying/>
		<BanknoteSelling/>
		<CrossRateUSD/>
		<CrossRateOther>1.35590</CrossRateOther>
	</Currency>
</Tarih_Date>''';

/// Sadece 16.10.2026 bültenini bilen sahte TCMB sunucusu; istenen adresleri [istekler]e yazar.
MockClient sahteSunucu(List<String> istekler) {
  return MockClient((istek) async {
    istekler.add(istek.url.path);
    if (istek.url.path == '/kurlar/202610/16102026.xml') {
      return http.Response.bytes(utf8.encode(_ornekBulten), 200, headers: {'content-type': 'application/xml; charset=utf-8'});
    }
    return http.Response('Not Found', 404);
  });
}

/// Gerçek saatle çalışan (DateTime.now) testler için: hangi gün istenirse istensin örnek bülteni döner.
MockClient herGunCevaplayanSunucu(List<String> istekler) {
  return MockClient((istek) async {
    istekler.add(istek.url.path);
    return http.Response.bytes(utf8.encode(_ornekBulten), 200, headers: {'content-type': 'application/xml; charset=utf-8'});
  });
}

void main() {
  test('bülten adresi TCMB arşiv biçiminde oluşturuluyor', () {
    expect(TcmbServisi.bultenAdresi(DateTime(2026, 3, 5)).toString(),
        'https://www.tcmb.gov.tr/kurlar/202603/05032026.xml');
  });

  test('bülten XML’i çözülüyor, boş efektif kurlar null oluyor', () {
    final bulten = TcmbServisi.bulteniCoz(_ornekBulten);

    expect(bulten.tarih, DateTime(2026, 10, 16));
    expect(bulten.kurlar.map((k) => k.kod), ['USD', 'EUR', 'XDR']);

    final usd = bulten.kurlar.first;
    expect(usd.isim, 'ABD DOLARI');
    expect(usd.birim, 1);
    expect(usd.dovizAlis, 49.3573);
    expect(usd.efektifSatis, 49.5204);

    final xdr = bulten.kurlar.last;
    expect(xdr.isim, 'ÖZEL ÇEKME HAKKI (SDR)');
    expect(xdr.dovizAlis, 66.9840);
    expect(xdr.dovizSatis, isNull);
    expect(xdr.efektifAlis, isNull);
  });

  test('hafta sonu seçilince önceki iş gününün bülteni getiriliyor', () async {
    final istekler = <String>[];
    final servis = TcmbServisi(client: sahteSunucu(istekler));

    // 18.10.2026 Pazar: önce Pazar, sonra Cumartesi, sonra Cuma denenir.
    final bulten = await servis.bultenGetir(DateTime(2026, 10, 18));

    expect(bulten.tarih, DateTime(2026, 10, 16));
    expect(istekler, ['/kurlar/202610/18102026.xml', '/kurlar/202610/17102026.xml', '/kurlar/202610/16102026.xml']);
  });

  test('hiç bülten bulunamazsa anlaşılır hata veriyor', () async {
    final servis = TcmbServisi(client: MockClient((_) async => http.Response('', 404)));
    expect(servis.bultenGetir(DateTime(2026, 10, 16)), throwsA(isA<KurAlinamadi>()));
  });

  test('bağlantı hatası anlaşılır hataya çevriliyor', () async {
    final servis = TcmbServisi(client: MockClient((_) async => throw http.ClientException('bağlantı yok')));
    expect(servis.bultenGetir(DateTime(2026, 10, 16)), throwsA(isA<KurAlinamadi>()));
  });

  group('Güncel Kur Çek', () {
    test('cuma 16:00: bugünün bülteni, durum güncel', () async {
      final kayit = await TcmbServisi(client: sahteSunucu([])).guncelKurCek(DateTime(2026, 10, 16, 16, 0));
      expect(kayit.usd, 49.3573);
      expect(kayit.eur, 55.5179);
      expect(kayit.bultenTarihi, DateTime(2026, 10, 16));
      expect(kayit.durum, KurDurumu.guncel);
    });

    test('cumartesi: cuma bülteni, durum geçmiş iş günü', () async {
      final kayit = await TcmbServisi(client: sahteSunucu([])).guncelKurCek(DateTime(2026, 10, 17, 10, 0));
      expect(kayit.bultenTarihi, DateTime(2026, 10, 16));
      expect(kayit.durum, KurDurumu.gecmisIsGunu);
      expect(kayit.durum.aciklama, 'En Son Açıklanan Geçmiş İş Günü Kuru (15:30 Öncesi / Tatil Modu)');
    });
  });

  group('Kur arşivi deposu', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    KurKaydi kayit(DateTime cekim) => KurKaydi(cekimTarihi: cekim, bultenTarihi: DateTime(2026, 10, 16), usd: 49.3573, eur: 55.5179);

    test('kayıtlar en yeni üstte olacak şekilde saklanıyor', () async {
      final depo = KurArsiviDeposu();
      await depo.ekle(kayit(DateTime(2026, 10, 16, 9)));
      await depo.ekle(kayit(DateTime(2026, 10, 17, 9)));

      final arsiv = await depo.yukle();
      expect(arsiv.map((k) => k.cekimTarihi.day), [17, 16]);
      expect(arsiv.first.usd, 49.3573);
    });

    test('bugün çekim yapıldı mı bilgisi', () async {
      final depo = KurArsiviDeposu();
      expect(await depo.bugunCekildiMi(DateTime(2026, 10, 17, 12)), isFalse);
      await depo.ekle(kayit(DateTime(2026, 10, 17, 9)));
      expect(await depo.bugunCekildiMi(DateTime(2026, 10, 17, 12)), isTrue);
      expect(await depo.bugunCekildiMi(DateTime(2026, 10, 18, 12)), isFalse);
    });

    test('otomatik servis ayarı saklanıyor, varsayılan kapalı', () async {
      final depo = KurArsiviDeposu();
      expect(await depo.otomatikServisAcikMi(), isFalse);
      await depo.otomatikServisAyarla(true);
      expect(await depo.otomatikServisAcikMi(), isTrue);
    });
  });

  group('TCMB Döviz Arşivi sayfası', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> ac(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TcmbKurArsivi()));
      await tester.pumpAndSettle();
    }

    testWidgets('boşken nasıl kur çekileceğini söylüyor', (tester) async {
      await ac(tester);
      expect(find.textContaining('Güncel Kur Çek'), findsOneWidget);
      expect(find.text('Listelenen Arşiv Kaydı: 0'), findsOneWidget);
    });

    testWidgets('arşivdeki çekimleri tarih, kur ve durumla listeliyor', (tester) async {
      final depo = KurArsiviDeposu();
      await depo.ekle(KurKaydi(cekimTarihi: DateTime(2026, 10, 16, 16, 5, 9), bultenTarihi: DateTime(2026, 10, 16), usd: 49.3573, eur: 55.5179));
      await depo.ekle(KurKaydi(cekimTarihi: DateTime(2026, 10, 17, 13, 47, 52), bultenTarihi: DateTime(2026, 10, 16), usd: 49.3573, eur: 55.5179));
      await ac(tester);

      expect(find.text('Listelenen Arşiv Kaydı: 2'), findsOneWidget);
      expect(find.text('17.10.2026 13:47:52'), findsOneWidget);
      expect(find.text('49.3573'), findsNWidgets(2));
      expect(find.text('55.5179'), findsNWidgets(2));
      expect(find.textContaining('Güncel Bugünün Kuru'), findsOneWidget);
      expect(find.textContaining('Geçmiş İş Günü Kuru'), findsOneWidget);
    });

    testWidgets('Otomatik Kur Servisi butonu ayarı açıp kapatıyor', (tester) async {
      await ac(tester);
      expect(find.text('Otomatik Kur Servisi: Kapalı'), findsOneWidget);

      await tester.tap(find.text('Otomatik Kur Servisi: Kapalı'));
      await tester.pumpAndSettle();
      expect(find.text('Otomatik Kur Servisi: Açık'), findsOneWidget);
      expect(await KurArsiviDeposu().otomatikServisAcikMi(), isTrue);
    });
  });

  group('Ana sayfa', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> ac(WidgetTester tester, TcmbServisi servis) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(KurumsalMobilApp(tcmbServisi: servis));
      await tester.pumpAndSettle();
    }

    testWidgets('Güncel Kur Çek butonu kuru çekip arşive ekliyor', (tester) async {
      await ac(tester, TcmbServisi(client: herGunCevaplayanSunucu([])));

      await tester.tap(find.text('Güncel Kur Çek'));
      await tester.pumpAndSettle();

      expect(find.textContaining('USD 49.3573 · EUR 55.5179'), findsOneWidget);
      expect(await KurArsiviDeposu().yukle(), hasLength(1));
    });

    testWidgets('kur çekilemezse hata mesajı gösteriyor, arşive bir şey eklemiyor', (tester) async {
      await ac(tester, TcmbServisi(client: MockClient((_) async => http.Response('', 500))));

      await tester.tap(find.text('Güncel Kur Çek'));
      await tester.pumpAndSettle();

      expect(find.textContaining('HTTP 500'), findsOneWidget);
      expect(await KurArsiviDeposu().yukle(), isEmpty);
    });

    testWidgets('otomatik servis açıksa açılışta kur çekiliyor', (tester) async {
      await KurArsiviDeposu().otomatikServisAyarla(true);
      final istekler = <String>[];
      await ac(tester, TcmbServisi(client: herGunCevaplayanSunucu(istekler)));

      expect(istekler, isNotEmpty);
      expect(await KurArsiviDeposu().yukle(), hasLength(1));
    });

    testWidgets('otomatik servis kapalıysa açılışta kur çekilmiyor', (tester) async {
      final istekler = <String>[];
      await ac(tester, TcmbServisi(client: herGunCevaplayanSunucu(istekler)));
      expect(istekler, isEmpty);
    });
  });
}
