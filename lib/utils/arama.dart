/// Türkçe kurallarıyla küçük harfe çevirir. Dart'ın toLowerCase'i 'İ' harfini 'i' yapmaz,
/// 'I' harfini de 'ı' yerine 'i' yapar; bu yüzden önce bu iki harf elle çevrilir.
String turkceKucukHarf(String metin) => metin.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// [alanlar]dan herhangi biri [arama] metnini içeriyorsa (büyük/küçük harf duyarsız) true döner.
/// Boş arama her şeye uyar.
bool aramayaUyar(String arama, Iterable<String> alanlar) {
  final aranan = turkceKucukHarf(arama.trim());
  if (aranan.isEmpty) return true;
  return alanlar.any((alan) => turkceKucukHarf(alan).contains(aranan));
}
