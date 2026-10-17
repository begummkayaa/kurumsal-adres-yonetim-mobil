import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mega_mobil_proje/main.dart';

/// Uygulamayı açar ve kayıtların yüklenmesini bekler.
Future<void> uygulamayiAc(WidgetTester tester) async {
  await tester.pumpWidget(const KurumsalMobilApp());
  await tester.pumpAndSettle();
}

void main() {
  // Her test boş bir depoyla, yani örnek kayıtlarla başlar.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Eklenen kayıt uygulama yeniden açılınca duruyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Kod *'), '88888');
    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'KALICI FİRMA');
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    // Uygulamayı kapatıp yeniden aç.
    await tester.pumpWidget(const SizedBox());
    await uygulamayiAc(tester);

    expect(find.descendant(of: find.byType(DataTable), matching: find.text('KALICI FİRMA')), findsOneWidget);
  });

  testWidgets('Ana sayfa başlık, form ve tabloyla açılıyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    expect(find.text('MEGA İŞ ÇÖZÜMLERİ'), findsWidgets);
    expect(find.text('ADRES ANA BİLGİLERİ'), findsOneWidget);
    expect(find.text('KAYIT LİSTESİ'), findsOneWidget);

    for (final buton in ['Yeni Kayıt', 'Kaydet', 'Güncelle', 'Sil', 'Temizle']) {
      expect(find.text(buton), findsOneWidget);
    }
  });

  testWidgets('Kayıt listesi tabloda gösteriliyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    expect(find.text('KAYA YAZILIM'), findsOneWidget);
    expect(find.text('FIRAT TEKNOLOJİ'), findsOneWidget);
    expect(find.text('Elazığ'), findsNWidgets(2));
  });

  testWidgets('Formda E-posta dahil tüm alanlar var ve yazılabiliyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    for (final alan in ['Kod *', 'Ad *', 'Adres', 'Şehir', 'Telefon', 'E-posta']) {
      expect(find.widgetWithText(TextField, alan), findsOneWidget);
    }

    await tester.enterText(find.widgetWithText(TextField, 'E-posta'), 'test@mega.com');
    expect(find.text('test@mega.com'), findsOneWidget);
  });

  testWidgets('Kaydet formdaki bilgiyi tabloya ekliyor ve formu boşaltıyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Kod *'), '99999');
    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'YENİ FİRMA');
    await tester.enterText(find.widgetWithText(TextField, 'Şehir'), 'Ankara');
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('Kayıt eklendi.'), findsOneWidget);
    expect(find.descendant(of: find.byType(DataTable), matching: find.text('YENİ FİRMA')), findsOneWidget);
    expect(find.descendant(of: find.byType(DataTable), matching: find.text('Ankara')), findsOneWidget);
    expect(find.descendant(of: find.byType(TextField), matching: find.text('YENİ FİRMA')), findsNothing);
  });

  testWidgets('Kod veya Ad boşsa Kaydet kayıt eklemiyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'KODSUZ FİRMA');
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('Kod boş bırakılamaz.'), findsOneWidget);
    expect(find.text('Lütfen formdaki hatalı alanları düzeltin.'), findsOneWidget);
    expect(find.descendant(of: find.byType(DataTable), matching: find.text('KODSUZ FİRMA')), findsNothing);
  });

  testWidgets('Aynı kodla ikinci kayıt eklenemiyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Kod *'), '24343434');
    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'KOPYA FİRMA');
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('Bu kod başka bir kayıtta kullanılıyor.'), findsOneWidget);
    expect(find.descendant(of: find.byType(DataTable), matching: find.text('KOPYA FİRMA')), findsNothing);
  });

  testWidgets('Hatalı telefon ve e-posta ile kayıt eklenemiyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Kod *'), '77777');
    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'HATALI FİRMA');
    await tester.enterText(find.widgetWithText(TextField, 'Telefon'), '123');
    await tester.enterText(find.widgetWithText(TextField, 'E-posta'), 'mega.com');
    await tester.ensureVisible(find.text('Kaydet'));
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('Geçerli bir telefon numarası girin.'), findsOneWidget);
    expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);
    expect(find.descendant(of: find.byType(DataTable), matching: find.text('HATALI FİRMA')), findsNothing);
  });

  testWidgets('Yeni Kayıt formu boşaltıyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'SİLİNECEK');
    await tester.tap(find.text('Yeni Kayıt'));
    await tester.pump();

    expect(find.text('SİLİNECEK'), findsNothing);
  });

  testWidgets('Tablodan seçilen kayıt forma doluyor ve Güncelle değiştiriyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.ensureVisible(find.text('KAYA YAZILIM'));
    await tester.tap(find.text('KAYA YAZILIM'));
    await tester.pump();

    expect(find.descendant(of: find.byType(TextField), matching: find.text('KAYA YAZILIM')), findsOneWidget);
    expect(find.descendant(of: find.byType(TextField), matching: find.text('24343434')), findsOneWidget);

    // Kendi kodunu koruyarak güncellemek "kod kullanılıyor" hatası vermemeli.
    await tester.enterText(find.widgetWithText(TextField, 'Şehir'), 'İzmir');
    await tester.ensureVisible(find.text('Güncelle'));
    await tester.tap(find.text('Güncelle'));
    await tester.pump();

    expect(find.text('Kayıt güncellendi.'), findsOneWidget);
    final tablo = find.byType(DataTable);
    expect(find.descendant(of: tablo, matching: find.text('İzmir')), findsOneWidget);
    expect(find.descendant(of: tablo, matching: find.text('Elazığ')), findsOneWidget);
    expect(find.descendant(of: tablo, matching: find.text('KAYA YAZILIM')), findsOneWidget);
  });

  testWidgets('Kayıt seçilmeden Güncelle uyarı veriyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.tap(find.text('Güncelle'));
    await tester.pump();

    expect(find.text('Güncellemek için tablodan bir kayıt seçin.'), findsOneWidget);
  });

  Future<void> kaydiSecVeSileBas(WidgetTester tester, String ad) async {
    await tester.ensureVisible(find.text(ad));
    await tester.tap(find.text(ad));
    await tester.pump();
    await tester.ensureVisible(find.text('Sil'));
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
  }

  testWidgets('Sil onaylanınca seçili kaydı siliyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await kaydiSecVeSileBas(tester, 'KAYA YAZILIM');
    expect(find.text('Kaydı Sil'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Sil')));
    await tester.pumpAndSettle();

    expect(find.text('Kayıt silindi.'), findsOneWidget);
    expect(find.text('KAYA YAZILIM'), findsNothing);
    expect(find.text('FIRAT TEKNOLOJİ'), findsOneWidget);
  });

  testWidgets('Sil iptal edilince kayıt kalıyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await kaydiSecVeSileBas(tester, 'KAYA YAZILIM');
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(DataTable), matching: find.text('KAYA YAZILIM')), findsOneWidget);
  });

  testWidgets('Kayıt seçilmeden Sil uyarı veriyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.tap(find.text('Sil'));
    await tester.pump();

    expect(find.text('Silmek için tablodan bir kayıt seçin.'), findsOneWidget);
  });

  testWidgets('Temizle formu boşaltıyor ve seçimi kaldırıyor', (WidgetTester tester) async {
    await uygulamayiAc(tester);

    await tester.ensureVisible(find.text('KAYA YAZILIM'));
    await tester.tap(find.text('KAYA YAZILIM'));
    await tester.pump();
    await tester.ensureVisible(find.text('Temizle'));
    await tester.tap(find.text('Temizle'));
    await tester.pump();

    expect(find.descendant(of: find.byType(TextField), matching: find.text('KAYA YAZILIM')), findsNothing);

    // Seçim kalktığı için Güncelle artık uyarı vermeli.
    await tester.ensureVisible(find.text('Güncelle'));
    await tester.tap(find.text('Güncelle'));
    await tester.pump();
    expect(find.text('Güncellemek için tablodan bir kayıt seçin.'), findsOneWidget);
  });
}
