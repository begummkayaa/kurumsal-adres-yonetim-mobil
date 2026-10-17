import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/adres.dart';

/// Adres kayıtlarını cihazda (SharedPreferences) JSON olarak saklar.
class AdresDeposu {
  static const _anahtar = 'adres_kayitlari';

  /// Uygulama ilk kez açıldığında gösterilen örnek kayıtlar.
  static const ornekKayitlar = [
    Adres(
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
    Adres(kod: '56565656', ad: 'FIRAT TEKNOLOJİ', sehir: 'Elazığ', ulke: 'Türkiye', telefon: '0424 237 00 00', eposta: 'info@firat.edu.tr'),
  ];

  /// Kayıtlı listeyi okur; daha önce hiç kayıt yapılmadıysa örnek kayıtları döner.
  Future<List<Adres>> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_anahtar);
    if (json == null) return List.of(ornekKayitlar);

    final liste = jsonDecode(json) as List<dynamic>;
    return liste.map((e) => Adres.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> kaydet(List<Adres> kayitlar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anahtar, jsonEncode(kayitlar.map((k) => k.toJson()).toList()));
  }
}
