import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/kur.dart';

class KurAlinamadi implements Exception {
  final String mesaj;
  const KurAlinamadi(this.mesaj);

  @override
  String toString() => mesaj;
}

/// TCMB'nin günlük kur arşivinden (https://www.tcmb.gov.tr/kurlar/) bülten çeker.
class TcmbServisi {
  /// Hafta sonu ve tatillerde bülten yayımlanmaz; en fazla bu kadar gün geriye gidilir.
  static const enFazlaGeriGun = 10;

  final http.Client _client;

  TcmbServisi({http.Client? client}) : _client = client ?? http.Client();

  static Uri bultenAdresi(DateTime tarih) {
    String iki(int s) => s.toString().padLeft(2, '0');
    final yil = tarih.year.toString();
    return Uri.parse('https://www.tcmb.gov.tr/kurlar/$yil${iki(tarih.month)}/${iki(tarih.day)}${iki(tarih.month)}$yil.xml');
  }

  /// [tarih] için bülteni getirir. O gün bülten yoksa (hafta sonu, tatil, henüz açıklanmamış)
  /// önceki günlere bakar ve bulduğu ilk bülteni döner.
  Future<KurBulteni> bultenGetir(DateTime tarih) async {
    var gun = DateTime(tarih.year, tarih.month, tarih.day);
    for (var i = 0; i <= enFazlaGeriGun; i++) {
      final http.Response yanit;
      try {
        yanit = await _client.get(bultenAdresi(gun));
      } on http.ClientException {
        throw const KurAlinamadi('TCMB sunucusuna ulaşılamadı. İnternet bağlantınızı kontrol edin.');
      }

      if (yanit.statusCode == 200) return bulteniCoz(yanit.body);
      if (yanit.statusCode != 404) throw KurAlinamadi('TCMB beklenmeyen bir yanıt verdi (HTTP ${yanit.statusCode}).');
      gun = gun.subtract(const Duration(days: 1));
    }
    throw const KurAlinamadi('Seçilen tarih ve öncesindeki günler için kur bülteni bulunamadı.');
  }

  static KurBulteni bulteniCoz(String xmlMetni) {
    final kok = XmlDocument.parse(xmlMetni).rootElement;
    // Tarih özniteliği "16.10.2026" biçimindedir.
    final parcalar = kok.getAttribute('Tarih')!.split('.').map(int.parse).toList();
    final tarih = DateTime(parcalar[2], parcalar[1], parcalar[0]);

    double? sayi(XmlElement e, String etiket) => double.tryParse(e.getElement(etiket)?.innerText.trim() ?? '');

    final kurlar = kok.findElements('Currency').map((e) {
      return Kur(
        kod: e.getAttribute('Kod') ?? '',
        isim: e.getElement('Isim')?.innerText.trim() ?? '',
        birim: int.tryParse(e.getElement('Unit')?.innerText.trim() ?? '') ?? 1,
        dovizAlis: sayi(e, 'ForexBuying'),
        dovizSatis: sayi(e, 'ForexSelling'),
        efektifAlis: sayi(e, 'BanknoteBuying'),
        efektifSatis: sayi(e, 'BanknoteSelling'),
      );
    }).toList();

    return KurBulteni(tarih: tarih, kurlar: kurlar);
  }
}
