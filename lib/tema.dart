import 'package:flutter/material.dart';

/// Uygulamanın kurumsal lacivert rengi.
const anaRenk = Color(0xFF0F172A);

final uygulamaTemasi = ThemeData(
  primaryColor: anaRenk,
  scaffoldBackgroundColor: const Color(0xFFF4F6F9),
  cardTheme: const CardThemeData(color: Colors.white, surfaceTintColor: Colors.transparent, elevation: 1),
  appBarTheme: const AppBarTheme(backgroundColor: anaRenk, foregroundColor: Colors.white),
);

/// Tabloların lacivert başlık satırı.
final tabloBaslikRengi = WidgetStateProperty.all(anaRenk);
const tabloBaslikYazisi = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
