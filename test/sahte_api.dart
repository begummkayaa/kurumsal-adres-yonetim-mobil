import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mega_mobil_proje/models/adres.dart';
import 'package:mega_mobil_proje/services/adres_api.dart';
import 'package:mega_mobil_proje/services/api_istemcisi.dart';

/// Testlerde kullanılan örnek kayıtlar (web sürümündeki verilerden).
const ornekKayitlar = [
  Adres(
    id: 1,
    kod: '0001.001',
    ad: 'MEGA İŞ ÇÖZÜMLERİ',
    adres: 'İçerenköy Mah. Eski Üsküdar Cad. Erkut Sok. No: 7 Çetin Ceylan Sitesi B Blok D:8',
    semt: 'Ataşehir',
    sehir: 'İstanbul',
    ulke: 'Türkiye',
    postaKodu: '34752',
    telefon: '+90 216 210 00 10',
    fax: '258 68 94',
    vergiDairesi: 'Kozyatağı',
    vergiNo: '6130836324',
    eposta: 'mega@mega.com',
  ),
  Adres(
    id: 2,
    kod: '24343434',
    ad: 'KAYA YAZILIM',
    adres: 'Cumhuriyet Mah. Fidanlı Sok.',
    semt: 'Cumhuriyet',
    sehir: 'Elazığ',
    ulke: 'Türkiye',
    postaKodu: '23000',
    telefon: '0212 392 32 22',
    vergiDairesi: 'Hilalkent',
    eposta: 'kaya@gmail.com',
  ),
  Adres(id: 3, kod: '56565656', ad: 'FIRAT TEKNOLOJİ', sehir: 'Elazığ', ulke: 'Türkiye', telefon: '0424 237 00 00', eposta: 'info@firat.edu.tr'),
];

/// MegaApi'nin /api/adresler uçlarını bellekte taklit eden sahte sunucu.
class SahteAdresSunucusu {
  /// "Veritabanındaki" kayıtlar (JSON olarak, API'nin döndüğü gibi).
  final List<Map<String, dynamic>> kayitlar;

  /// true ise her istek bağlantı hatası verir (API kapalıymış gibi).
  bool kapali;

  int _sonId;

  SahteAdresSunucusu({List<Adres> baslangic = ornekKayitlar, this.kapali = false})
      : kayitlar = [for (final k in baslangic) k.toJson()],
        _sonId = baslangic.fold(0, (en, k) => (k.id ?? 0) > en ? k.id! : en);

  late final AdresApi api = AdresApi(ApiIstemcisi(client: MockClient(_cevapla), adres: 'http://sahte'));

  Future<http.Response> _cevapla(http.Request istek) async {
    if (kapali) throw http.ClientException('bağlantı reddedildi');

    final parcalar = istek.url.pathSegments; // [api, adresler, (id)]
    final id = parcalar.length > 2 ? int.parse(parcalar[2]) : null;
    final govde = istek.body.isEmpty ? null : jsonDecode(istek.body) as Map<String, dynamic>;
    int sira(int id) => kayitlar.indexWhere((k) => k['id'] == id);
    bool kodVar(String kod, int? haric) => kayitlar.any((k) => k['kod'] == kod && k['id'] != haric);

    switch (istek.method) {
      case 'GET':
        return _json(kayitlar);
      case 'POST':
        if (kodVar(govde!['kod'] as String, null)) return _json({'mesaj': "'${govde['kod']}' kodu başka bir kayıtta kullanılıyor."}, 409);
        final yeni = {...govde, 'id': ++_sonId};
        kayitlar.add(yeni);
        return _json(yeni, 201);
      case 'PUT':
        if (sira(id!) == -1) return _json({'mesaj': '$id numaralı kayıt bulunamadı.'}, 404);
        if (kodVar(govde!['kod'] as String, id)) return _json({'mesaj': "'${govde['kod']}' kodu başka bir kayıtta kullanılıyor."}, 409);
        final guncel = {...govde, 'id': id};
        kayitlar[sira(id)] = guncel;
        return _json(guncel);
      case 'DELETE':
        if (sira(id!) == -1) return _json({'mesaj': '$id numaralı kayıt bulunamadı.'}, 404);
        kayitlar.removeAt(sira(id));
        return http.Response('', 204);
    }
    return http.Response('', 405);
  }

  static http.Response _json(Object veri, [int durum = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(veri)), durum, headers: {'content-type': 'application/json; charset=utf-8'});
}
