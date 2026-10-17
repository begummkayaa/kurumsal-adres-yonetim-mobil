import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API'nin adresi. Gerçek telefonda bilgisayarın yerel IP'si verilmelidir:
/// `flutter run --dart-define=API_URL=http://192.168.1.20:5080`
String varsayilanApiAdresi() {
  const tanimli = String.fromEnvironment('API_URL');
  if (tanimli.isNotEmpty) return tanimli;
  // Android emülatörü, bilgisayarın localhost'una 10.0.2.2 üzerinden ulaşır.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5080';
  return 'http://localhost:5080';
}

/// API isteği başarısız olduğunda kullanıcıya gösterilecek mesajla fırlatılır.
class ApiHatasi implements Exception {
  final String mesaj;
  const ApiHatasi(this.mesaj);

  @override
  String toString() => mesaj;
}

/// MegaApi'ye JSON istekleri atar; hataları [ApiHatasi]'na çevirir.
class ApiIstemcisi {
  final http.Client _client;
  final String adres;

  ApiIstemcisi({http.Client? client, String? adres})
      : _client = client ?? http.Client(),
        adres = adres ?? varsayilanApiAdresi();

  Future<dynamic> get(String yol) => _gonder('GET', yol);
  Future<dynamic> post(String yol, [Object? govde]) => _gonder('POST', yol, govde);
  Future<dynamic> put(String yol, Object govde) => _gonder('PUT', yol, govde);
  Future<dynamic> delete(String yol) => _gonder('DELETE', yol);

  Future<dynamic> _gonder(String yontem, String yol, [Object? govde]) async {
    final istek = http.Request(yontem, Uri.parse('$adres$yol'));
    if (govde != null) {
      istek.headers['Content-Type'] = 'application/json; charset=utf-8';
      istek.body = jsonEncode(govde);
    }

    final http.Response yanit;
    try {
      yanit = await http.Response.fromStream(await _client.send(istek).timeout(const Duration(seconds: 20)));
    } on Exception {
      throw ApiHatasi('Sunucuya ulaşılamadı ($adres). API\'nin çalıştığından ve aynı ağda olduğunuzdan emin olun.');
    }

    final metin = utf8.decode(yanit.bodyBytes);
    final veri = metin.isEmpty ? null : jsonDecode(metin);
    if (yanit.statusCode >= 200 && yanit.statusCode < 300) return veri;

    final mesaj = veri is Map && veri['mesaj'] is String ? veri['mesaj'] as String : null;
    throw ApiHatasi(mesaj ?? 'Sunucu isteği tamamlayamadı (HTTP ${yanit.statusCode}).');
  }
}
