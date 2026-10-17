import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mega_mobil_proje/models/adres.dart';
import 'package:mega_mobil_proje/services/adres_deposu.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('hiç kayıt yapılmadıysa örnek kayıtları döner', () async {
    final kayitlar = await AdresDeposu().yukle();
    expect(kayitlar.map((k) => k.kod), AdresDeposu.ornekKayitlar.map((k) => k.kod));
  });

  test('kaydedilen liste tüm alanlarıyla geri okunur', () async {
    const kayit = Adres(
      kod: 'K1',
      ad: 'Deneme',
      adres: 'Atatürk Cad. No:1',
      sehir: 'Ankara',
      telefon: '0312 000 00 00',
      eposta: 'deneme@mega.com',
    );
    await AdresDeposu().kaydet([kayit]);

    final okunan = await AdresDeposu().yukle();
    expect(okunan, hasLength(1));
    expect(okunan.single.toJson(), kayit.toJson());
  });

  test('tüm kayıtlar silinince boş liste döner, örnekler geri gelmez', () async {
    await AdresDeposu().kaydet([]);
    expect(await AdresDeposu().yukle(), isEmpty);
  });
}
