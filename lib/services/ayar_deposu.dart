import 'package:shared_preferences/shared_preferences.dart';

/// Bu cihaza özel ayarlar (veritabanında değil, cihazda saklanır).
class AyarDeposu {
  static const _otomatikKurAnahtari = 'otomatik_kur_servisi';

  /// Açıksa uygulama her gün ilk açıldığında güncel kuru çeker. Varsayılan kapalı.
  Future<bool> otomatikKurServisiAcikMi() async =>
      (await SharedPreferences.getInstance()).getBool(_otomatikKurAnahtari) ?? false;

  Future<void> otomatikKurServisiAyarla(bool acik) async =>
      (await SharedPreferences.getInstance()).setBool(_otomatikKurAnahtari, acik);
}
