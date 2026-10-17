import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/adres.dart';
import '../utils/tarih.dart';

/// PDF rapor tanımı: başlık, dosya adı öneki, sütunlar ve sayfa yönü (web sürümüyle aynı).
class PdfRaporTuru {
  final String baslik;
  final String dosyaOneki;
  final List<AdresAlani> alanlar;
  final bool yatay;

  const PdfRaporTuru({required this.baslik, required this.dosyaOneki, required this.alanlar, this.yatay = false});

  static const ozet = PdfRaporTuru(
    baslik: 'MEGA İŞ ÇÖZÜMLERİ - ADRES ÖZET RAPORU (RAPOR 1)',
    dosyaOneki: 'Adres_Ozet_Raporu',
    alanlar: [AdresAlani.kod, AdresAlani.ad, AdresAlani.adres, AdresAlani.semt, AdresAlani.sehir, AdresAlani.telefon, AdresAlani.eposta],
  );

  /// Web sürümündeki gibi Kod hariç tüm alanlar, sığması için yatay sayfa.
  static final detayli = PdfRaporTuru(
    baslik: 'MEGA İŞ ÇÖZÜMLERİ - DETAYLI ADRES RAPORU (RAPOR 2)',
    dosyaOneki: 'Adres_Detayli_Raporu',
    alanlar: AdresAlani.values.where((a) => a != AdresAlani.kod).toList(),
    yatay: true,
  );

  /// Ör. Adres_Ozet_Raporu_17.09.2026_13_40.pdf
  String dosyaAdi(DateTime tarih) => '${dosyaOneki}_${tarihYaz(tarih)}_${saatYaz(tarih, ayirac: '_')}.pdf';
}

/// PDF'teki sütun başlığı ("E-POSTA ADRESİ" -> "E-Posta Adresi" gibi, web sürümündeki yazımla).
String _pdfBasligi(AdresAlani a) => switch (a) {
      AdresAlani.eposta => 'E-Posta Adresi',
      AdresAlani.semt => 'Semt',
      _ => a.etiket,
    };

/// Sütunların göreli genişliği; kısa değerli sütunlar (şehir, ülke) kelime ortasından bölünmesin diye.
double _sutunOrani(AdresAlani a) => switch (a) {
      AdresAlani.adres => 3.5,
      AdresAlani.eposta => 2.2,
      AdresAlani.ad => 2.0,
      AdresAlani.webSitesi => 1.8,
      AdresAlani.telefon => 1.6,
      AdresAlani.semt || AdresAlani.vergiDairesi || AdresAlani.vergiNo || AdresAlani.yetkili1 || AdresAlani.yetkili2 => 1.5,
      AdresAlani.fax || AdresAlani.kod || AdresAlani.sehir => 1.3,
      AdresAlani.ulke || AdresAlani.postaKodu => 1.1,
    };

const _yesil = PdfColor.fromInt(0xFF1E7B34);
const _koyu = PdfColor.fromInt(0xFF2C3E50);

Future<Uint8List> adresRaporuPdf({
  required PdfRaporTuru tur,
  required List<Adres> kayitlar,
  required DateTime tarih,
}) async {
  final normal = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final kalin = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  final yaziBoyu = tur.yatay ? 6.5 : 8.0;

  final belge = pw.Document(title: tur.baslik, author: 'MEGA İŞ ÇÖZÜMLERİ');
  belge.addPage(
    pw.MultiPage(
      pageFormat: tur.yatay ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      theme: pw.ThemeData.withFont(base: normal, bold: kalin),
      header: (context) => context.pageNumber > 1
          ? pw.SizedBox()
          : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(tur.baslik, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _yesil)),
                pw.SizedBox(height: 4),
                pw.Text('Rapor Tarihi: ${tarihYaz(tarih)} ${saatYaz(tarih)}', style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 12),
              ],
            ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Sayfa ${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8)),
      ),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: [for (final a in tur.alanlar) _pdfBasligi(a)],
          data: [
            for (final k in kayitlar) [for (final a in tur.alanlar) k[a]],
          ],
          columnWidths: {
            for (var i = 0; i < tur.alanlar.length; i++) i: pw.FlexColumnWidth(_sutunOrani(tur.alanlar[i])),
          },
          headerStyle: pw.TextStyle(fontSize: yaziBoyu, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: _koyu),
          cellStyle: pw.TextStyle(fontSize: yaziBoyu),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
        ),
      ],
    ),
  );
  return belge.save();
}
