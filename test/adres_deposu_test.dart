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
      semt: 'Çankaya',
      sehir: 'Ankara',
      ulke: 'Türkiye',
      postaKodu: '06100',
      telefon: '0312 000 00 00',
      fax: '0312 000 00 01',
      vergiDairesi: 'Çankaya V.D.',
      vergiNo: '1234567890',
      eposta: 'deneme@mega.com',
      webSitesi: 'www.deneme.com',
      yetkili1: 'Ali Kaya',
      yetkili2: 'Ayşe Yılmaz',
    );
    await AdresDeposu().kaydet([kayit]);

    final okunan = await AdresDeposu().yukle();
    expect(okunan, hasLength(1));
    expect(okunan.single.toJson(), kayit.toJson());
  });

  test('yeni alanlar eklenmeden önce kaydedilmiş eski kayıtlar da okunuyor', () async {
    SharedPreferences.setMockInitialValues({
      'adres_kayitlari': '[{"kod":"E1","ad":"Eski","adres":"","sehir":"Ankara","telefon":"","eposta":""}]',
    });

    final okunan = (await AdresDeposu().yukle()).single;
    expect(okunan.kod, 'E1');
    expect(okunan.sehir, 'Ankara');
    expect(okunan.vergiNo, '');
    expect(okunan.yetkili2, '');
  });

  test('tüm kayıtlar silinince boş liste döner, örnekler geri gelmez', () async {
    await AdresDeposu().kaydet([]);
    expect(await AdresDeposu().yukle(), isEmpty);
  });
}
