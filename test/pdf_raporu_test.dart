import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

import 'package:mega_mobil_proje/models/adres.dart';
import 'package:mega_mobil_proje/pages/adres_raporu.dart';
import 'package:mega_mobil_proje/services/pdf_raporu.dart';

const _kayitlar = [
  Adres(kod: '0001.001', ad: 'MEGA İŞ ÇÖZÜMLERİ', semt: 'Ataşehir', sehir: 'İstanbul', yetkili1: 'Çağrı Öztürk'),
  Adres(kod: '24343434', ad: 'KAYA YAZILIM', sehir: 'Elazığ'),
];

bool pdfMi(Uint8List bytes) => String.fromCharCodes(bytes.take(5)) == '%PDF-';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gömülen fontlar Türkçe harflerin hepsini içeriyor', () async {
    for (final dosya in ['assets/fonts/Roboto-Regular.ttf', 'assets/fonts/Roboto-Bold.ttf']) {
      final font = TtfParser(await rootBundle.load(dosya));
      for (final harf in 'çÇğĞıİöÖşŞüÜ'.runes) {
        expect(font.charToGlyphIndexMap.containsKey(harf), isTrue, reason: '$dosya: ${String.fromCharCode(harf)}');
      }
    }
  });

  test('dosya adları web sürümündeki biçimde', () {
    final tarih = DateTime(2026, 9, 17, 13, 40);
    expect(PdfRaporTuru.ozet.dosyaAdi(tarih), 'Adres_Ozet_Raporu_17.09.2026_13_40.pdf');
    expect(PdfRaporTuru.detayli.dosyaAdi(tarih), 'Adres_Detayli_Raporu_17.09.2026_13_40.pdf');
  });

  test('detaylı rapor Kod hariç tüm alanları içeriyor ve yatay', () {
    expect(PdfRaporTuru.detayli.alanlar, isNot(contains(AdresAlani.kod)));
    expect(PdfRaporTuru.detayli.alanlar, hasLength(AdresAlani.values.length - 1));
    expect(PdfRaporTuru.detayli.yatay, isTrue);
    expect(PdfRaporTuru.ozet.yatay, isFalse);
  });

  test('özet ve detaylı PDF oluşturuluyor', () async {
    for (final tur in [PdfRaporTuru.ozet, PdfRaporTuru.detayli]) {
      final pdf = await adresRaporuPdf(tur: tur, kayitlar: _kayitlar, tarih: DateTime(2026, 9, 17, 13, 40));
      expect(pdfMi(pdf), isTrue, reason: tur.dosyaOneki);
    }
  });

  test('çok sayıda kayıt birden fazla sayfaya bölünüyor', () async {
    final cokKayit = [for (var i = 0; i < 120; i++) Adres(kod: 'K$i', ad: 'Firma $i', sehir: 'Elazığ')];
    final pdf = await adresRaporuPdf(tur: PdfRaporTuru.ozet, kayitlar: cokKayit, tarih: DateTime(2026, 9, 17));
    final sayfaSayisi = RegExp(r'/Type\s*/Page[^s]').allMatches(String.fromCharCodes(pdf)).length;
    expect(sayfaSayisi, greaterThan(1));
  });

  testWidgets('PDF Olarak İndir butonu listelenen kayıtların PDF’ini veriyor', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Uint8List? verilenPdf;
    String? verilenAd;
    await tester.pumpWidget(MaterialApp(
      home: AdresRaporu(
        baslik: 'Özet Adres Raporu',
        kayitlar: _kayitlar,
        alanlar: PdfRaporTuru.ozet.alanlar,
        pdfTuru: PdfRaporTuru.ozet,
        pdfPaylas: (pdf, ad) async {
          verilenPdf = pdf;
          verilenAd = ad;
        },
      ),
    ));

    // PDF oluşturma gerçek asenkron iş (font okuma, sıkıştırma) yaptığı için runAsync içinde beklenir.
    await tester.runAsync(() async {
      await tester.tap(find.text('PDF Olarak İndir'));
      for (var i = 0; i < 100 && verilenPdf == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();

    expect(verilenPdf, isNotNull);
    expect(pdfMi(verilenPdf!), isTrue);
    expect(verilenAd, startsWith('Adres_Ozet_Raporu_'));
    expect(verilenAd, endsWith('.pdf'));
  });
}
