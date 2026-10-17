import 'package:flutter_test/flutter_test.dart';

import 'package:mega_mobil_proje/utils/dogrulama.dart';

void main() {
  group('zorunlu', () {
    test('boş ve sadece boşluk hata verir', () {
      expect(Dogrulama.zorunlu('', 'Ad'), 'Ad boş bırakılamaz.');
      expect(Dogrulama.zorunlu('   ', 'Ad'), 'Ad boş bırakılamaz.');
      expect(Dogrulama.zorunlu(null, 'Ad'), 'Ad boş bırakılamaz.');
    });
    test('dolu değer geçer', () => expect(Dogrulama.zorunlu('Mega', 'Ad'), isNull));
  });

  group('telefon', () {
    test('boş bırakılabilir', () => expect(Dogrulama.telefon(''), isNull));
    test('geçerli formatlar', () {
      for (final t in ['0212 392 32 22', '+90 216 210 00 10', '(0424) 237-00-00', '05321234567']) {
        expect(Dogrulama.telefon(t), isNull, reason: t);
      }
    });
    test('çok kısa veya harfli numaralar hata verir', () {
      expect(Dogrulama.telefon('123'), isNotNull);
      expect(Dogrulama.telefon('0212 abc 32 22'), isNotNull);
    });
  });

  group('fax', () {
    test('kısa numaralar da geçer', () {
      expect(Dogrulama.fax('258 68 94'), isNull);
      expect(Dogrulama.fax('32 3232 32'), isNull);
      expect(Dogrulama.fax(''), isNull);
    });
    test('harf içeremez', () => expect(Dogrulama.fax('258 abc'), isNotNull));
  });

  group('sadeceRakam', () {
    test('rakamlar ve boş değer geçer', () {
      expect(Dogrulama.sadeceRakam('34752', 'Posta Kodu'), isNull);
      expect(Dogrulama.sadeceRakam('', 'Posta Kodu'), isNull);
    });
    test('harf veya boşluk hata verir', () {
      expect(Dogrulama.sadeceRakam('34 752', 'Posta Kodu'), 'Posta Kodu yalnızca rakam içerebilir.');
      expect(Dogrulama.sadeceRakam('61308A', 'Vergi No'), isNotNull);
    });
  });

  group('webSitesi', () {
    test('geçerli adresler', () {
      for (final w in ['www.mega.com', 'https://www.nova.com/', 'http://mega.com.tr/iletisim', 'megaiscozum.com']) {
        expect(Dogrulama.webSitesi(w), isNull, reason: w);
      }
    });
    test('hatalı adresler', () {
      for (final w in ['mega', 'www mega com', 'https://']) {
        expect(Dogrulama.webSitesi(w), isNotNull, reason: w);
      }
    });
  });

  group('eposta', () {
    test('boş bırakılabilir', () => expect(Dogrulama.eposta(''), isNull));
    test('geçerli adresler', () {
      for (final e in ['mega@mega.com', 'info@firat.edu.tr', 'ad.soyad+not@alan-adi.com']) {
        expect(Dogrulama.eposta(e), isNull, reason: e);
      }
    });
    test('hatalı adresler', () {
      for (final e in ['mega.com', 'mega@', '@mega.com', 'mega@mega', 'a b@mega.com']) {
        expect(Dogrulama.eposta(e), isNotNull, reason: e);
      }
    });
  });
}
