import 'package:flutter/material.dart';

import 'models/adres.dart';

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
  final List<Adres> _kayitlar = [
    const Adres(kod: '0001.001', ad: 'MEGA İŞ ÇÖZÜMLERİ', sehir: 'İstanbul', telefon: '+90 216 210 00 10', eposta: 'mega@mega.com'),
    const Adres(kod: '24343434', ad: 'KAYA YAZILIM', sehir: 'Elazığ', telefon: '0212 392 32 22', eposta: 'kaya@gmail.com'),
    const Adres(kod: '56565656', ad: 'FIRAT TEKNOLOJİ', sehir: 'Elazığ', telefon: '0424 237 00 00', eposta: 'info@firat.edu.tr'),
  ];

  final _kodController = TextEditingController();
  final _adController = TextEditingController();
  final _adresController = TextEditingController();
  final _sehirController = TextEditingController();
  final _telefonController = TextEditingController();
  final _epostaController = TextEditingController();
  final _kodFocus = FocusNode();
  int? _seciliIndex;

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
    setState(() => _seciliIndex = null);
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

  /// Formdaki bilgilerden bir Adres oluşturur; Kod veya Ad boşsa uyarı gösterip null döner.
  Adres? _formdanAdres() {
    final kod = _kodController.text.trim();
    final ad = _adController.text.trim();
    if (kod.isEmpty || ad.isEmpty) {
      _mesajGoster('Kod ve Ad alanları boş bırakılamaz.', hata: true);
      return null;
    }
    return Adres(
      kod: kod,
      ad: ad,
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
    _formuBosalt();
    _mesajGoster('Kayıt güncellendi.');
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
                _buildIslemButonu('Sil', Colors.red, Icons.delete, () {}),
                _buildIslemButonu('Temizle', Colors.teal, Icons.cleaning_services, () {}),
              ],
            ),
            const SizedBox(height: 24),
            
            // FORM ALANI
            const Row(children: [Icon(Icons.description_outlined, color: Colors.grey), SizedBox(width: 8), Text('ADRES ANA BİLGİLERİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))]),
            const Divider(),
            const SizedBox(height: 16),
            _buildTextField('Kod', _kodController, focusNode: _kodFocus),
            _buildTextField('Ad', _adController),
            _buildTextField('Adres', _adresController, maxLines: 3),
            _buildTextField('Şehir', _sehirController),
            _buildTextField('Telefon', _telefonController, klavye: TextInputType.phone),
            _buildTextField('E-posta', _epostaController, klavye: TextInputType.emailAddress),
            
            const SizedBox(height: 32),
            
            // TABLO ALANI
            const Row(children: [Icon(Icons.list_alt, color: Colors.grey), SizedBox(width: 8), Text('KAYIT LİSTESİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))]),
            const Divider(),
            const SizedBox(height: 16),
            
            // Sağa Sola Kaydırılabilir Tablo
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

  Widget _buildTextField(String etiket, TextEditingController controller, {int maxLines = 1, TextInputType? klavye, FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType: klavye,
        decoration: InputDecoration(labelText: etiket, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }
}