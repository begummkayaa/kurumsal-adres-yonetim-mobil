import 'package:flutter/material.dart';

/// Uygulamanın kurumsal lacivert rengi.
const anaRenk = Color(0xFF0F172A);

final uygulamaTemasi = ThemeData(
  primaryColor: anaRenk,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(backgroundColor: anaRenk, foregroundColor: Colors.white),
);

/// Tabloların lacivert başlık satırı.
final tabloBaslikRengi = WidgetStateProperty.all(anaRenk);
const tabloBaslikYazisi = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
