import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/adres.dart';
import '../services/pdf_raporu.dart';
import '../widgets/kayit_tablosu.dart';
import '../widgets/marka_basligi.dart';
import '../widgets/tablo_paneli.dart';

/// PDF'i kullanıcıya verir: telefonda paylaşım menüsü açılır, tarayıcıda dosya iner.
typedef PdfPaylas = Future<void> Function(Uint8List pdf, String dosyaAdi);

Future<void> _varsayilanPdfPaylas(Uint8List pdf, String dosyaAdi) => Printing.sharePdf(bytes: pdf, filename: dosyaAdi);

/// Web sürümündeki rapor sayfası: seçili sütunlarla, aranabilir kayıt tablosu ve PDF çıktısı.
class AdresRaporu extends StatefulWidget {
  final String baslik;
  final List<Adres> kayitlar;
  final List<AdresAlani> alanlar;
  final PdfRaporTuru pdfTuru;
  final PdfPaylas pdfPaylas;

  const AdresRaporu({
    super.key,
    required this.baslik,
    required this.kayitlar,
    required this.alanlar,
    required this.pdfTuru,
    this.pdfPaylas = _varsayilanPdfPaylas,
  });

  @override
  State<AdresRaporu> createState() => _AdresRaporuState();
}

class _AdresRaporuState extends State<AdresRaporu> {
  final _aramaController = TextEditingController();
  bool _pdfHazirlaniyor = false;

  @override
  void initState() {
    super.initState();
    _aramaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  List<int> get _gorunenIndeksler => [
        for (var i = 0; i < widget.kayitlar.length; i++)
          if (widget.kayitlar[i].aramayaUyar(_aramaController.text)) i,
      ];

  /// Listede görünen (aramaya uyan) kayıtları PDF olarak verir.
  Future<void> _pdfIndir() async {
    setState(() => _pdfHazirlaniyor = true);
    try {
      final tarih = DateTime.now();
      final pdf = await adresRaporuPdf(
        tur: widget.pdfTuru,
        kayitlar: [for (final i in _gorunenIndeksler) widget.kayitlar[i]],
        tarih: tarih,
      );
      await widget.pdfPaylas(pdf, widget.pdfTuru.dosyaAdi(tarih));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF oluşturulamadı: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _pdfHazirlaniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gorunenler = _gorunenIndeksler;
    return Scaffold(
      appBar: AppBar(title: const MarkaBasligi()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TabloPaneli(
          baslik: widget.baslik,
          aramaController: _aramaController,
          altSag: 'Listelenen Kayıt Sayısı: ${gorunenler.length}',
          altSol: OutlinedButton.icon(
            onPressed: _pdfHazirlaniyor || gorunenler.isEmpty ? null : _pdfIndir,
            icon: _pdfHazirlaniyor
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('PDF Olarak İndir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF198754),
              backgroundColor: const Color(0xFFE8F5EE),
              side: const BorderSide(color: Color(0xFFA3D9B8)),
              shape: const StadiumBorder(),
            ),
          ),
          child: gorunenler.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(widget.kayitlar.isEmpty ? 'Henüz kayıt yok.' : 'Aramaya uyan kayıt yok.')),
                )
              : KayitTablosu(
                  kayitlar: widget.kayitlar,
                  alanlar: widget.alanlar,
                  ozelBasliklar: const {AdresAlani.semt: 'SEMT'},
                  gosterilecekler: gorunenler,
                ),
        ),
      ),
    );
  }
}

/// Rapor 1: temel adres ve iletişim bilgileri (PDF'tekiyle aynı sütunlar).
class OzetAdresRaporu extends StatelessWidget {
  static final alanlar = PdfRaporTuru.ozet.alanlar;

  final List<Adres> kayitlar;

  const OzetAdresRaporu({super.key, required this.kayitlar});

  @override
  Widget build(BuildContext context) =>
      AdresRaporu(baslik: 'Özet Adres Raporu', kayitlar: kayitlar, alanlar: alanlar, pdfTuru: PdfRaporTuru.ozet);
}

/// Rapor 2: kayıtların tüm alanları.
class DetayliAdresRaporu extends StatelessWidget {
  static const alanlar = AdresAlani.values;

  final List<Adres> kayitlar;

  const DetayliAdresRaporu({super.key, required this.kayitlar});

  @override
  Widget build(BuildContext context) =>
      AdresRaporu(baslik: 'Detaylı Adres Raporu', kayitlar: kayitlar, alanlar: alanlar, pdfTuru: PdfRaporTuru.detayli);
}
