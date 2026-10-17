import 'package:flutter_test/flutter_test.dart';

import 'package:mega_mobil_proje/models/adres.dart';
import 'package:mega_mobil_proje/utils/arama.dart';

void main() {
  test('Türkçe büyük harfler doğru küçültülüyor', () {
    expect(turkceKucukHarf('İSTANBUL'), 'istanbul');
    expect(turkceKucukHarf('ISPARTA'), 'ısparta');
    expect(turkceKucukHarf('ÇÖĞÜŞ'), 'çöğüş');
  });

  test('arama büyük/küçük harf ve Türkçe karakter duyarsız', () {
    expect(aramayaUyar('istanbul', ['İstanbul']), isTrue);
    expect(aramayaUyar('İSTANBUL', ['istanbul']), isTrue);
    expect(aramayaUyar('mega iş', ['MEGA İŞ ÇÖZÜMLERİ']), isTrue);
    expect(aramayaUyar('ankara', ['İstanbul']), isFalse);
  });

  test('boş arama her şeye uyuyor', () {
    expect(aramayaUyar('', ['herhangi']), isTrue);
    expect(aramayaUyar('   ', []), isTrue);
  });

  test('Adres tüm alanlarında arıyor', () {
    const k = Adres(kod: 'K1', ad: 'Deneme', adres: 'Atatürk Cad.', sehir: 'Elazığ', telefon: '0424 237 00 00', eposta: 'info@firat.edu.tr');
    for (final aranan in ['k1', 'deneme', 'atatürk', 'elazığ', '237', 'firat']) {
      expect(k.aramayaUyar(aranan), isTrue, reason: aranan);
    }
    expect(k.aramayaUyar('ankara'), isFalse);
  });
}
