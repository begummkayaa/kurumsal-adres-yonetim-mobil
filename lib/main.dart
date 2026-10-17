import 'package:flutter/material.dart';

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
                _buildIslemButonu('Yeni Kayıt', Colors.blue, Icons.add),
                _buildIslemButonu('Kaydet', Colors.green, Icons.save),
                _buildIslemButonu('Güncelle', Colors.orange, Icons.edit),
                _buildIslemButonu('Sil', Colors.red, Icons.delete),
                _buildIslemButonu('Temizle', Colors.teal, Icons.cleaning_services),
              ],
            ),
            const SizedBox(height: 24),
            
            // FORM ALANI
            const Row(children: [Icon(Icons.description_outlined, color: Colors.grey), SizedBox(width: 8), Text('ADRES ANA BİLGİLERİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))]),
            const Divider(),
            const SizedBox(height: 16),
            _buildTextField('Kod'),
            _buildTextField('Ad'),
            _buildTextField('Adres', maxLines: 3),
            _buildTextField('Şehir'),
            _buildTextField('Telefon'),
            
            const SizedBox(height: 32),
            
            // TABLO ALANI
            const Row(children: [Icon(Icons.list_alt, color: Colors.grey), SizedBox(width: 8), Text('KAYIT LİSTESİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))]),
            const Divider(),
            const SizedBox(height: 16),
            
            // Sağa Sola Kaydırılabilir Tablo
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFF0F172A)),
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('KOD')),
                  DataColumn(label: Text('AD')),
                  DataColumn(label: Text('ŞEHİR')),
                  DataColumn(label: Text('TELEFON')),
                  DataColumn(label: Text('E-POSTA')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('0001.001')),
                    DataCell(Text('MEGA İŞ ÇÖZÜMLERİ')),
                    DataCell(Text('İstanbul')),
                    DataCell(Text('+90 216 210 00 10')),
                    DataCell(Text('mega@mega.com')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('24343434')),
                    DataCell(Text('KAYA YAZILIM')),
                    DataCell(Text('Elazığ')),
                    DataCell(Text('0212 392 32 22')),
                    DataCell(Text('kaya@gmail.com')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('56565656')),
                    DataCell(Text('FIRAT TEKNOLOJİ')),
                    DataCell(Text('Elazığ')),
                    DataCell(Text('0424 237 00 00')),
                    DataCell(Text('info@firat.edu.tr')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIslemButonu(String metin, Color renk, IconData ikon) {
    return ActionChip(
      backgroundColor: renk,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      avatar: Icon(ikon, color: Colors.white, size: 18),
      label: Text(metin),
      onPressed: () {},
    );
  }

  Widget _buildTextField(String etiket, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(labelText: etiket, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }
}