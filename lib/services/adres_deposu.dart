import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/adres.dart';

/// Adres kayıtlarını cihazda (SharedPreferences) JSON olarak saklar.
class AdresDeposu {
  static const _anahtar = 'adres_kayitlari';

  /// Uygulama ilk kez açıldığında gösterilen örnek kayıtlar.
  static const ornekKayitlar = [
    Adres(kod: '0001.001', ad: 'MEGA İŞ ÇÖZÜMLERİ', sehir: 'İstanbul', telefon: '+90 216 210 00 10', eposta: 'mega@mega.com'),
    Adres(kod: '24343434', ad: 'KAYA YAZILIM', sehir: 'Elazığ', telefon: '0212 392 32 22', eposta: 'kaya@gmail.com'),
    Adres(kod: '56565656', ad: 'FIRAT TEKNOLOJİ', sehir: 'Elazığ', telefon: '0424 237 00 00', eposta: 'info@firat.edu.tr'),
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
