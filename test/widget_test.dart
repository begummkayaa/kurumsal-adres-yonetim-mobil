import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mega_mobil_proje/main.dart';

void main() {
  testWidgets('Ana sayfa başlık, form ve tabloyla açılıyor', (WidgetTester tester) async {
    await tester.pumpWidget(const KurumsalMobilApp());

    expect(find.text('MEGA İŞ ÇÖZÜMLERİ'), findsWidgets);
    expect(find.text('ADRES ANA BİLGİLERİ'), findsOneWidget);
    expect(find.text('KAYIT LİSTESİ'), findsOneWidget);

    for (final buton in ['Yeni Kayıt', 'Kaydet', 'Güncelle', 'Sil', 'Temizle']) {
      expect(find.text(buton), findsOneWidget);
    }
  });

  testWidgets('Kayıt listesi tabloda gösteriliyor', (WidgetTester tester) async {
    await tester.pumpWidget(const KurumsalMobilApp());

    expect(find.text('KAYA YAZILIM'), findsOneWidget);
    expect(find.text('FIRAT TEKNOLOJİ'), findsOneWidget);
    expect(find.text('Elazığ'), findsNWidgets(2));
  });

  testWidgets('Formda E-posta dahil tüm alanlar var ve yazılabiliyor', (WidgetTester tester) async {
    await tester.pumpWidget(const KurumsalMobilApp());

    for (final alan in ['Kod', 'Ad', 'Adres', 'Şehir', 'Telefon', 'E-posta']) {
      expect(find.widgetWithText(TextField, alan), findsOneWidget);
    }

    await tester.enterText(find.widgetWithText(TextField, 'E-posta'), 'test@mega.com');
    expect(find.text('test@mega.com'), findsOneWidget);
  });
}
