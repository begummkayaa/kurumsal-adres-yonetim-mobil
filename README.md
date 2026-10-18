# 📱 Kurumsal Adres Yönetimi – Mobil

Firma adres kayıtlarını eklemek, güncellemek, silmek ve raporlamak için **Flutter** ile geliştirilmiş mobil uygulama. Ekranlar ve raporlar web sürümüyle aynı yapıdadır.

> 🔗 Bu projenin [web](https://github.com/begummkayaa/kurumsal-adres-yonetim-web) ve [masaüstü](https://github.com/begummkayaa/kurumsal-adres-yonetim-masaustu) sürümleri de bulunmaktadır. Üç sürüm aynı SQL Server veritabanını kullanır.

---

## 📑 İçindekiler

- [Mimari](#-mimari)
- [Özellikler](#-özellikler)
- [Kurulum ve Çalıştırma](#-kurulum-ve-çalıştırma)
- [Testler](#-testler)
- [Proje Yapısı](#-proje-yapısı)
- [Kullanılan Paketler](#-kullanılan-paketler)

---

## 🧩 Mimari

```
Flutter uygulaması  ──HTTP/JSON──▶  MegaApi (ASP.NET Core)  ──▶  SQL Server
                                                                (AdresAna, DovizGecmisi)
Web (ASP.NET Web Forms) ─────────────────────────────────────▶      ▲
Masaüstü (WinForms) ─────────────────────────────────────────────────┘
```

> ℹ️ Flutter, SQL Server'a doğrudan bağlanamadığı için veritabanına `api/MegaApi` üzerinden erişir.

---

## ✨ Özellikler

### 📇 Adres Kayıtları
- 🗂️ **15 alan:** Kod, Ad, Adres, Semt, Şehir, Ülke, Posta Kodu, Telefon, Fax, Vergi Dairesi, Vergi No, Mail, Web Sitesi, Yetkili 1, Yetkili 2
- ✏️ Kayıt ekleme, listeden seçip güncelleme ve onaylı silme; değişiklikler web ve masaüstü sürümlerinde de görünür
- ⏮️ **İlk / Geri / İleri / Son** butonlarıyla kayıtlar arasında gezinme
- ✅ **Form doğrulama:** Kod ve Ad zorunlu, kod benzersiz; telefon, fax, posta kodu, vergi no, e-posta ve web adresi format kontrolü; alanlara veritabanı sütun uzunluğundan uzun yazılamaz
- 🔍 Tüm alanlarda, Türkçe karakter duyarlı arama (ör. `istanbul` → `İstanbul`)
- 📐 Geniş ekranda form iki sütun, telefonda tek sütun

### 📊 Raporlar (sol menü → Raporlar)
- 📄 **Özet Adres Raporu (Rapor 1):** Kod, Ad, Adres, Semt, Şehir, Telefon, E-posta
- 📋 **Detaylı Adres Raporu (Rapor 2):** kayıtların tüm alanları
- 📥 İki rapor da aranabilir ve **PDF olarak indirilebilir**. PDF'te Türkçe karakterler doğru görünür, detaylı rapor yatay sayfaya basılır.
- 💱 **TCMB Döviz Arşivi:** ana sayfadaki **Güncel Kur Çek** butonuyla TCMB'den alınan dolar/euro kurlarının (efektif satış) listesi; web sürümüyle aynı arşivdir. Hafta sonu veya 15:30 öncesinde çekilen kur, durum sütununda "Geçmiş İş Günü Kuru" olarak belirtilir. 🔄 **Otomatik Kur Servisi** açılırsa uygulama, arşivde o günün kuru yoksa açılışta kendisi çeker.

---

## 🚀 Kurulum ve Çalıştırma

**🧰 Gereksinimler:** [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.13), [.NET 10 SDK](https://dotnet.microsoft.com/download) ve web/masaüstü sürümlerinin kullandığı SQL Server veritabanı.

### 1️⃣ API'yi Başlatın
Veritabanı bağlantısı `api/MegaApi/appsettings.json` içindedir.

```bash
cd api/MegaApi
dotnet run          # http://localhost:5080
```

### 2️⃣ Uygulamayı Çalıştırın

```bash
flutter pub get
flutter run -d chrome    # tarayıcıda (API: localhost:5080)
flutter run              # Android emülatöründe (API: 10.0.2.2:5080)
```

### 📲 Gerçek Telefonda Çalıştırma
Telefon ve bilgisayar aynı Wi-Fi'de olmalı; API adresi olarak bilgisayarın yerel IP'si verilir (Windows'ta `ipconfig` ile öğrenilir). 🛡️ Windows Güvenlik Duvarı'nın 5080 portuna izin vermesi gerekebilir.

```bash
flutter run --dart-define=API_URL=http://192.168.1.20:5080
```

### 🔌 API Uçları

| Yöntem | Adres | İşlem |
|---|---|---|
| GET | `/api/adresler` | Tüm kayıtlar (ID sırasıyla) |
| POST | `/api/adresler` | Kayıt ekle |
| PUT | `/api/adresler/{id}` | Kaydı güncelle |
| DELETE | `/api/adresler/{id}` | Kaydı sil |
| GET | `/api/kurlar` | TCMB döviz arşivi (en yeni üstte) |
| POST | `/api/kurlar/guncel` | TCMB'den güncel kuru çek ve arşive ekle |
| GET | `/api/saglik` | API çalışıyor mu |

---

## 🧪 Testler

```bash
flutter test
```

Testler; doğrulama kurallarını, aramayı, ana ekrandaki tüm işlemleri ve gezinmeyi, API hatalarını (sunucu kapalı, kod çakışması), küçük ekranda taşma olmamasını, raporları, PDF çıktısını ve kur arşivini kapsar. 💡 Testler bellekte çalışan sahte bir API ile çalışır; veritabanı veya internet gerektirmez.

---

## 📂 Proje Yapısı

```
api/MegaApi/                      ASP.NET Core API (veritabanı erişimi, TCMB kur çekme)
lib/
├── main.dart                     Uygulamanın giriş noktası
├── tema.dart                     Renkler ve tema
├── models/
│   ├── adres.dart                Adres kaydı ve alanları
│   └── kur.dart                  Kur arşivi kaydı
├── pages/
│   ├── ana_sayfa.dart            İşlem butonları, kayıt formu ve kayıt listesi
│   ├── adres_raporu.dart         Özet ve Detaylı Adres raporları
│   └── tcmb_kur_arsivi.dart      TCMB Döviz Arşivi
├── services/
│   ├── api_istemcisi.dart        API adresi ve istekler
│   ├── adres_api.dart            Adres kayıtları (AdresAna)
│   ├── kur_api.dart              Kur arşivi (DovizGecmisi)
│   ├── ayar_deposu.dart          Cihaza özel ayarlar (otomatik kur servisi)
│   └── pdf_raporu.dart           PDF rapor çıktısı
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

---

## 📦 Kullanılan Paketler

| Paket | Kullanım |
|---|---|
| 🌐 [http](https://pub.dev/packages/http) | API ile iletişim |
| 💾 [shared_preferences](https://pub.dev/packages/shared_preferences) | Cihaza özel ayarlar |
| 📄 [pdf](https://pub.dev/packages/pdf) | PDF rapor oluşturma |
| 🖨️ [printing](https://pub.dev/packages/printing) | PDF'i paylaşma / indirme |

**🔗 API:** [Microsoft.Data.SqlClient](https://www.nuget.org/packages/Microsoft.Data.SqlClient) ve [Dapper](https://www.nuget.org/packages/Dapper).
