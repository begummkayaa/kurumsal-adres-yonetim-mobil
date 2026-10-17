import 'package:flutter/material.dart' show DateUtils;

import '../models/kur.dart';
import 'api_istemcisi.dart';

/// TCMB Döviz Arşivi'ni (DovizGecmisi) API üzerinden okur; güncel kuru API'ye çektirir.
class KurApi {
  final ApiIstemcisi _api;

  KurApi([ApiIstemcisi? api]) : _api = api ?? ApiIstemcisi();

  /// En yeni çekim en üstte.
  Future<List<KurKaydi>> listele() async {
    final liste = await _api.get('/api/kurlar') as List<dynamic>;
    return liste.map((e) => KurKaydi.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// API, TCMB'den güncel dolar/euro kurunu alır, arşive yazar ve yazdığı kaydı döner.
  Future<KurKaydi> guncelKurCek() async =>
      KurKaydi.fromJson(await _api.post('/api/kurlar/guncel') as Map<String, dynamic>);

  /// Bugün için arşivde çekim var mı?
  Future<bool> bugunCekildiMi(DateTime simdi) async => (await listele()).any((k) => DateUtils.isSameDay(k.tarih, simdi));
}
