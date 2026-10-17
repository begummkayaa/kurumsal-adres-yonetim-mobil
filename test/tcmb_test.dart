import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mega_mobil_proje/pages/tcmb_kur_arsivi.dart';
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

void main() {
  test('bülten adresi TCMB arşiv biçiminde oluşturuluyor', () {
    expect(TcmbServisi.bultenAdresi(DateTime(2026, 3, 5)).toString(),
        'https://www.tcmb.gov.tr/kurlar/202603/05032026.xml');
  });

  test('bülten XML’i çözülüyor, boş efektif kurlar null oluyor', () {
    final bulten = TcmbServisi.bulteniCoz(_ornekBulten);

    expect(bulten.tarih, DateTime(2026, 10, 16));
    expect(bulten.kurlar.map((k) => k.kod), ['USD', 'XDR']);

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

  testWidgets('kur arşivi sayfası kurları ve bülten tarihini gösteriyor', (tester) async {
    final servis = TcmbServisi(client: sahteSunucu([]));
    await tester.pumpWidget(MaterialApp(home: TcmbKurArsivi(servis: servis, baslangicTarihi: DateTime(2026, 10, 17))));
    await tester.pumpAndSettle();

    expect(find.text('16.10.2026 tarihli bülten'), findsOneWidget);
    expect(find.text('ABD DOLARI'), findsOneWidget);
    expect(find.text('49.3573'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(3)); // XDR'nin boş kurları
  });

  testWidgets('kur arşivi sayfası hata mesajını gösteriyor', (tester) async {
    final servis = TcmbServisi(client: MockClient((_) async => http.Response('', 500)));
    await tester.pumpWidget(MaterialApp(home: TcmbKurArsivi(servis: servis, baslangicTarihi: DateTime(2026, 10, 17))));
    await tester.pumpAndSettle();

    expect(find.textContaining('HTTP 500'), findsOneWidget);
  });
}
