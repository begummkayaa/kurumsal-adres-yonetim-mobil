import 'package:flutter/material.dart';

import 'models/adres.dart';
import 'services/adres_deposu.dart';
import 'utils/dogrulama.dart';

void main() {
  runApp(const KurumsalMobilApp());
}

class KurumsalMobilApp extends StatelessWidget {
  const KurumsalMobilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mega İş Çözümleri',
      theme: ThemeData(
        primaryColor: const Color(0xFF0F172A), 
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final _depo = AdresDeposu();
  List<Adres> _kayitlar = [];
  bool _yukleniyor = true;

  final _kodController = TextEditingController();
  final _adController = TextEditingController();
  final _adresController = TextEditingController();
  final _sehirController = TextEditingController();
  final _telefonController = TextEditingController();
  final _epostaController = TextEditingController();
  final _kodFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int? _seciliIndex;

  @override
  void initState() {
    super.initState();
    _kayitlariYukle();
  }

  Future<void> _kayitlariYukle() async {
    final kayitlar = await _depo.yukle();
    if (!mounted) return;
    setState(() {
      _kayitlar = kayitlar;
      _yukleniyor = false;
    });
  }

  @override
  void dispose() {
    _kodController.dispose();
    _adController.dispose();
    _adresController.dispose();
    _sehirController.dispose();
    _telefonController.dispose();
    _epostaController.dispose();
    _kodFocus.dispose();
    super.dispose();
  }

  void _mesajGoster(String mesaj, {bool hata = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: hata ? Colors.red : Colors.green),
    );
  }

  void _formuBosalt() {
    for (final c in [_kodController, _adController, _adresController, _sehirController, _telefonController, _epostaController]) {
      c.clear();
    }
    _formKey.currentState?.reset();
    setState(() => _seciliIndex = null);
  }

  /// Kod başka bir kayıtta (seçili kayıt hariç) kullanılıyorsa hata döner.
  String? _kodDogrula(String? deger) {
    final zorunluHata = Dogrulama.zorunlu(deger, 'Kod');
    if (zorunluHata != null) return zorunluHata;
    final kod = deger!.trim();
    for (var i = 0; i < _kayitlar.length; i++) {
      if (i != _seciliIndex && _kayitlar[i].kod == kod) return 'Bu kod başka bir kayıtta kullanılıyor.';
    }
    return null;
  }

  void _kaydiSec(int index) {
    final k = _kayitlar[index];
    _kodController.text = k.kod;
    _adController.text = k.ad;
    _adresController.text = k.adres;
    _sehirController.text = k.sehir;
    _telefonController.text = k.telefon;
    _epostaController.text = k.eposta;
    setState(() => _seciliIndex = index);
  }

  /// Formu doğrular ve bilgilerden bir Adres oluşturur; hatalı alan varsa uyarı gösterip null döner.
  Adres? _formdanAdres() {
    if (!_formKey.currentState!.validate()) {
      _mesajGoster('Lütfen formdaki hatalı alanları düzeltin.', hata: true);
      return null;
    }
    return Adres(
      kod: _kodController.text.trim(),
      ad: _adController.text.trim(),
      adres: _adresController.text.trim(),
      sehir: _sehirController.text.trim(),
      telefon: _telefonController.text.trim(),
      eposta: _epostaController.text.trim(),
    );
  }

  void _yeniKayit() {
    _formuBosalt();
    _kodFocus.requestFocus();
  }

  void _kaydet() {
    final yeni = _formdanAdres();
    if (yeni == null) return;

    setState(() => _kayitlar.add(yeni));
    _depo.kaydet(_kayitlar);
    _formuBosalt();
    _mesajGoster('Kayıt eklendi.');
  }

  void _guncelle() {
    final index = _seciliIndex;
    if (index == null) {
      _mesajGoster('Güncellemek için tablodan bir kayıt seçin.', hata: true);
      return;
    }
    final guncel = _formdanAdres();
    if (guncel == null) return;

    setState(() => _kayitlar[index] = guncel);
    _depo.kaydet(_kayitlar);
    _formuBosalt();
    _mesajGoster('Kayıt güncellendi.');
  }

  Future<void> _sil() async {
    final index = _seciliIndex;
    if (index == null) {
      _mesajGoster('Silmek için tablodan bir kayıt seçin.', hata: true);
      return;
    }
    final kayit = _kayitlar[index];

    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: Text('"${kayit.ad}" (${kayit.kod}) kaydı silinecek. Emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    setState(() => _kayitlar.removeAt(index));
    _depo.kaydet(_kayitlar);
    _formuBosalt();
    _mesajGoster('Kayıt silindi.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEGA İŞ ÇÖZÜMLERİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Color(0xFF0F172A)), child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 24))),
            ListTile(leading: const Icon(Icons.home), title: const Text('Ana Sayfa'), onTap: () => Navigator.pop(context)),
            ExpansionTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Raporlar'),
              children: [
                ListTile(title: const Text('Özet Adres Raporu'), contentPadding: const EdgeInsets.only(left: 50), onTap: () {}),
                ListTile(title: const Text('Detaylı Adres Raporu'), contentPadding: const EdgeInsets.only(left: 50), onTap: () {}),
                ListTile(title: const Text('TCMB Kur Arşivi'), contentPadding: const EdgeInsets.only(left: 50), onTap: () {}),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BUTONLAR
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildIslemButonu('Yeni Kayıt', Colors.blue, Icons.add, _yeniKayit),
                _buildIslemButonu('Kaydet', Colors.green, Icons.save, _kaydet),
                _buildIslemButonu('Güncelle', Colors.orange, Icons.edit, _guncelle),
                _buildIslemButonu('Sil', Colors.red, Icons.delete, _sil),
                _buildIslemButonu('Temizle', Colors.teal, Icons.cleaning_services, _formuBosalt),
              ],
            ),
            const SizedBox(height: 24),
            
            // FORM ALANI
            const Row(children: [Icon(Icons.description_outlined, color: Colors.grey), SizedBox(width: 8), Text('ADRES ANA BİLGİLERİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))]),
            const Divider(),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField('Kod *', _kodController, focusNode: _kodFocus, dogrula: _kodDogrula),
                  _buildTextField('Ad *', _adController, dogrula: (d) => Dogrulama.zorunlu(d, 'Ad')),
                  _buildTextField('Adres', _adresController, maxLines: 3),
                  _buildTextField('Şehir', _sehirController),
                  _buildTextField('Telefon', _telefonController, klavye: TextInputType.phone, dogrula: Dogrulama.telefon),
                  _buildTextField('E-posta', _epostaController, klavye: TextInputType.emailAddress, dogrula: Dogrulama.eposta),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // TABLO ALANI
            const Row(children: [Icon(Icons.list_alt, color: Colors.grey), SizedBox(width: 8), Text('KAYIT LİSTESİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))]),
            const Divider(),
            const SizedBox(height: 16),
            
            // Sağa Sola Kaydırılabilir Tablo
            if (_yukleniyor)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('KOD')),
                    DataColumn(label: Text('AD')),
                    DataColumn(label: Text('ŞEHİR')),
                    DataColumn(label: Text('TELEFON')),
                    DataColumn(label: Text('E-POSTA')),
                  ],
                  rows: [
                    for (var i = 0; i < _kayitlar.length; i++)
                      DataRow(
                        selected: i == _seciliIndex,
                        onSelectChanged: (_) => _kaydiSec(i),
                        cells: [
                          DataCell(Text(_kayitlar[i].kod)),
                          DataCell(Text(_kayitlar[i].ad)),
                          DataCell(Text(_kayitlar[i].sehir)),
                          DataCell(Text(_kayitlar[i].telefon)),
                          DataCell(Text(_kayitlar[i].eposta)),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIslemButonu(String metin, Color renk, IconData ikon, VoidCallback onPressed) {
    return ActionChip(
      backgroundColor: renk,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      avatar: Icon(ikon, color: Colors.white, size: 18),
      label: Text(metin),
      onPressed: onPressed,
    );
  }

  Widget _buildTextField(String etiket, TextEditingController controller, {int maxLines = 1, TextInputType? klavye, FocusNode? focusNode, FormFieldValidator<String>? dogrula}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: dogrula,
        maxLines: maxLines,
        keyboardType: klavye,
        decoration: InputDecoration(labelText: etiket, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }
}