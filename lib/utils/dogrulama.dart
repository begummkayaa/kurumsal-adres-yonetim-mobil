/// Form alanlarının doğrulama kuralları. Hata varsa mesajı, yoksa null döner.
class Dogrulama {
  static final _epostaDeseni = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _telefonKarakterleri = RegExp(r'^[0-9+()\s-]+$');
  static final _sadeceRakam = RegExp(r'^[0-9]+$');
  static final _webDeseni = RegExp(r'^(https?://)?[\w-]+(\.[\w-]+)+(/\S*)?$');

  static String? zorunlu(String? deger, String alanAdi) {
    if (deger == null || deger.trim().isEmpty) return '$alanAdi boş bırakılamaz.';
    return null;
  }

  /// Telefon isteğe bağlıdır; girildiyse 10-13 rakam içermelidir.
  static String? telefon(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return null;
    if (!_telefonKarakterleri.hasMatch(metin)) return 'Telefon yalnızca rakam, boşluk, +, -, ( ) içerebilir.';
    final rakamSayisi = metin.replaceAll(RegExp(r'\D'), '').length;
    if (rakamSayisi < 10 || rakamSayisi > 13) return 'Geçerli bir telefon numarası girin.';
    return null;
  }

  /// Fax isteğe bağlıdır; kısa (dahili) numaralar da olabildiği için yalnızca karakterler kontrol edilir.
  static String? fax(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return null;
    if (!_telefonKarakterleri.hasMatch(metin)) return 'Fax yalnızca rakam, boşluk, +, -, ( ) içerebilir.';
    return null;
  }

  /// İsteğe bağlı, yalnızca rakamlardan oluşan alanlar (Posta Kodu, Vergi No).
  static String? sadeceRakam(String? deger, String alanAdi) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return null;
    if (!_sadeceRakam.hasMatch(metin)) return '$alanAdi yalnızca rakam içerebilir.';
    return null;
  }

  /// E-posta isteğe bağlıdır; girildiyse geçerli formatta olmalıdır.
  static String? eposta(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return null;
    if (!_epostaDeseni.hasMatch(metin)) return 'Geçerli bir e-posta adresi girin.';
    return null;
  }

  /// Web sitesi isteğe bağlıdır; girildiyse boşluksuz ve alan adı içeren bir adres olmalıdır.
  static String? webSitesi(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return null;
    if (!_webDeseni.hasMatch(metin)) return 'Geçerli bir web adresi girin (ör. www.mega.com).';
    return null;
  }
}
