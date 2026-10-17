# Kurumsal Adres Yönetimi – Mobil

Firma adres kayıtlarını eklemek, güncellemek, silmek ve raporlamak için Flutter ile geliştirilmiş mobil uygulama. [Web](https://github.com/begummkayaa/kurumsal-adres-yonetim-web) ve [masaüstü](https://github.com/begummkayaa/kurumsal-adres-yonetim-masaustu) sürümlerinin mobil karşılığıdır; ekranlar ve raporlar web sürümüyle aynı yapıdadır.

## Özellikler

**Adres kayıtları**
- 15 alan: Kod, Ad, Adres, Semt, Şehir, Ülke, Posta Kodu, Telefon, Fax, Vergi Dairesi, Vergi No, Mail, Web Sitesi, Yetkili 1, Yetkili 2
- Kayıt ekleme, listeden seçip güncelleme ve onaylı silme
- **İlk / Geri / İleri / Son** butonlarıyla kayıtlar arasında gezinme
- Form doğrulama: Kod ve Ad zorunlu, kod benzersiz; telefon, fax, posta kodu, vergi no, e-posta ve web adresi format kontrolü
- Tüm alanlarda, Türkçe karakter duyarlı arama (ör. `istanbul` → `İstanbul`)
- Kayıtlar cihazda kalıcı olarak saklanır
- Geniş ekranda form iki sütun, telefonda tek sütun

**Raporlar** (sol menü → Raporlar)
- **Özet Adres Raporu (Rapor 1):** Kod, Ad, Adres, Semt, Şehir, Telefon, E-posta
- **Detaylı Adres Raporu (Rapor 2):** kayıtların tüm alanları
- İki rapor da aranabilir ve **PDF olarak indirilebilir**. PDF'te Türkçe karakterler doğru görünür, detaylı rapor yatay sayfaya basılır.
- **TCMB Döviz Arşivi:** ana sayfadaki **Güncel Kur Çek** butonuyla TCMB'den alınan dolar/euro kurlarının listesi. Kur, o günün bülteni açıklanmadıysa (15:30 öncesi, hafta sonu, tatil) en son açıklanan iş gününden alınır ve durum sütununda belirtilir. **Otomatik Kur Servisi** açılırsa uygulama her gün ilk açıldığında kuru kendisi çeker.

## Kurulum ve Çalıştırma

Gereksinim: [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.13)

```bash
flutter pub get
flutter run              # bağlı cihaz veya emülatörde
flutter run -d chrome    # tarayıcıda
```

> **Not:** TCMB sunucusu CORS başlığı göndermediği için kur çekme tarayıcıda çalışmaz. Android/iOS'ta sorun yoktur. Geliştirme sırasında tarayıcıda denemek için:
> `flutter run -d chrome --web-browser-flag "--disable-web-security"`

## Testler

```bash
flutter test
```

Testler; doğrulama kurallarını, aramayı, kalıcı kaydı, ana ekrandaki tüm işlemleri ve gezinmeyi, küçük ekranda taşma olmamasını, raporları, PDF çıktısını ve TCMB kur çekme/arşivini kapsar. TCMB testleri sahte bir sunucuyla çalışır, internet bağlantısı gerektirmez.

## Proje Yapısı

```
lib/
├── main.dart                     Uygulamanın giriş noktası
├── tema.dart                     Renkler ve tema
├── models/
│   ├── adres.dart                Adres kaydı ve alanları
│   └── kur.dart                  Döviz kuru, kur bülteni ve kur arşivi kaydı
├── pages/
│   ├── ana_sayfa.dart            İşlem butonları, kayıt formu ve kayıt listesi
│   ├── adres_raporu.dart         Özet ve Detaylı Adres raporları
│   └── tcmb_kur_arsivi.dart      TCMB Döviz Arşivi
├── services/
│   ├── adres_deposu.dart         Kayıtların cihazda saklanması
│   ├── kur_arsivi_deposu.dart    Çekilen kurların ve otomatik servis ayarının saklanması
│   ├── pdf_raporu.dart           PDF rapor çıktısı
│   └── tcmb_servisi.dart         TCMB kur bülteninin çekilmesi ve çözümlenmesi
├── utils/
│   ├── arama.dart                Türkçe uyumlu arama
│   ├── dogrulama.dart            Form doğrulama kuralları
│   └── tarih.dart                Tarih/saat biçimlendirme
└── widgets/
    ├── ana_menu.dart             Sol menü
    ├── form_ogeleri.dart         İşlem butonu, form alanı, bölüm başlığı
    ├── kayit_tablosu.dart        Kayıt tablosu
    ├── marka_basligi.dart        Üst çubuktaki logo ve firma adı
    └── tablo_paneli.dart         Koyu başlıklı liste kartı
assets/fonts/                     PDF için Roboto (SIL Open Font License)
```

## Kullanılan Paketler

| Paket | Kullanım |
|---|---|
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Kayıtları ve kur arşivini cihazda saklama |
| [http](https://pub.dev/packages/http) | TCMB'den kur bülteni çekme |
| [xml](https://pub.dev/packages/xml) | Kur bültenini çözümleme |
| [pdf](https://pub.dev/packages/pdf) | PDF rapor oluşturma |
| [printing](https://pub.dev/packages/printing) | PDF'i paylaşma / indirme |
