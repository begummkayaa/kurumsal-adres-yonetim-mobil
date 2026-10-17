# Kurumsal Adres Yönetimi – Mobil

Firma adres kayıtlarını eklemek, güncellemek, silmek ve raporlamak için Flutter ile geliştirilmiş mobil uygulama. [Web](https://github.com/begummkayaa/kurumsal-adres-yonetim-web) ve [masaüstü](https://github.com/begummkayaa/kurumsal-adres-yonetim-masaustu) sürümlerinin mobil karşılığıdır.

## Özellikler

**Adres kayıtları**
- Kayıt ekleme, tablodan seçip güncelleme ve onaylı silme
- Form doğrulama: Kod ve Ad zorunlu, kod benzersiz, telefon ve e-posta formatı kontrolü
- Tüm alanlarda, Türkçe karakter duyarlı arama (ör. `istanbul` → `İstanbul`)
- Kayıtlar cihazda kalıcı olarak saklanır (`shared_preferences`)

**Raporlar** (sol menü → Raporlar)
- **Özet Adres Raporu:** toplam kayıt, şehir sayısı, iletişim bilgisi olan kayıtlar ve şehirlere göre dağılım
- **Detaylı Adres Raporu:** tüm kayıtlar bütün alanlarıyla, aranabilir liste halinde
- **TCMB Kur Arşivi:** seçilen tarihteki döviz kurları, TCMB'nin resmi arşivinden çekilir. Hafta sonu veya tatil seçilirse en yakın önceki bülten gösterilir.

## Kurulum ve Çalıştırma

Gereksinim: [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.13)

```bash
flutter pub get
flutter run              # bağlı cihaz veya emülatörde
flutter run -d chrome    # tarayıcıda
```

> **Not:** TCMB sunucusu CORS başlığı göndermediği için kur arşivi tarayıcıda çalışmaz. Android/iOS'ta sorun yoktur. Geliştirme sırasında tarayıcıda denemek için:
> `flutter run -d chrome --web-browser-flag "--disable-web-security"`

## Testler

```bash
flutter test
```

Testler; doğrulama kurallarını, aramayı, kalıcı kaydı, ana ekrandaki tüm işlemleri, raporları ve TCMB bülten çözümlemesini kapsar. TCMB testleri sahte bir sunucuyla çalışır, internet bağlantısı gerektirmez.

## Proje Yapısı

```
lib/
├── main.dart                  Uygulamanın giriş noktası
├── tema.dart                  Renkler ve tema
├── models/
│   ├── adres.dart             Adres kaydı
│   └── kur.dart               Döviz kuru ve kur bülteni
├── pages/
│   ├── ana_sayfa.dart         Kayıt formu, işlem butonları ve kayıt listesi
│   ├── ozet_adres_raporu.dart
│   ├── detayli_adres_raporu.dart
│   └── tcmb_kur_arsivi.dart
├── services/
│   ├── adres_deposu.dart      Kayıtların cihazda saklanması
│   └── tcmb_servisi.dart      TCMB kur bülteninin çekilmesi ve çözümlenmesi
├── utils/
│   ├── arama.dart             Türkçe uyumlu arama
│   └── dogrulama.dart         Form doğrulama kuralları
└── widgets/
    ├── adres_tablosu.dart
    ├── ana_menu.dart
    └── form_ogeleri.dart      İşlem butonu, form alanı, bölüm başlığı
```

## Kullanılan Paketler

| Paket | Kullanım |
|---|---|
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Kayıtları cihazda saklama |
| [http](https://pub.dev/packages/http) | TCMB'den kur bülteni çekme |
| [xml](https://pub.dev/packages/xml) | Kur bültenini çözümleme |
