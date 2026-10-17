import '../models/adres.dart';
import 'api_istemcisi.dart';

/// Adres kayıtlarını web ve masaüstü sürümleriyle ortak veritabanından (AdresAna) API üzerinden okur ve yazar.
class AdresApi {
  final ApiIstemcisi _api;

  AdresApi([ApiIstemcisi? api]) : _api = api ?? ApiIstemcisi();

  Future<List<Adres>> listele() async {
    final liste = await _api.get('/api/adresler') as List<dynamic>;
    return liste.map((e) => Adres.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Kaydı ekler ve veritabanının verdiği ID ile geri döner.
  Future<Adres> ekle(Adres adres) async =>
      Adres.fromJson(await _api.post('/api/adresler', adres.toJson()) as Map<String, dynamic>);

  Future<Adres> guncelle(Adres adres) async =>
      Adres.fromJson(await _api.put('/api/adresler/${adres.id}', adres.toJson()) as Map<String, dynamic>);

  Future<void> sil(int id) => _api.delete('/api/adresler/$id');
}
