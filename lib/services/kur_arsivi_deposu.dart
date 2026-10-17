import 'dart:convert';

import 'package:flutter/material.dart' show DateUtils;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kur.dart';

/// "Güncel Kur Çek" ile alınan kurları ve otomatik kur servisi ayarını cihazda saklar.
class KurArsiviDeposu {
  static const _arsivAnahtari = 'kur_arsivi';
  static const _otomatikAnahtari = 'otomatik_kur_servisi';

  /// Arşiv, en yeni çekim en üstte olacak şekilde.
  Future<List<KurKaydi>> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_arsivAnahtari);
    if (json == null) return [];
    final liste = (jsonDecode(json) as List<dynamic>).map((e) => KurKaydi.fromJson(e as Map<String, dynamic>)).toList();
    return liste..sort((a, b) => b.cekimTarihi.compareTo(a.cekimTarihi));
  }

  Future<void> ekle(KurKaydi kayit) async {
    final arsiv = await yukle();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_arsivAnahtari, jsonEncode([kayit, ...arsiv].map((k) => k.toJson()).toList()));
  }

  /// Bugün için arşivde çekim var mı?
  Future<bool> bugunCekildiMi(DateTime simdi) async =>
      (await yukle()).any((k) => DateUtils.isSameDay(k.cekimTarihi, simdi));

  Future<bool> otomatikServisAcikMi() async => (await SharedPreferences.getInstance()).getBool(_otomatikAnahtari) ?? false;

  Future<void> otomatikServisAyarla(bool acik) async => (await SharedPreferences.getInstance()).setBool(_otomatikAnahtari, acik);
}
