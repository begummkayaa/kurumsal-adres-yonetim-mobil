import 'package:flutter/material.dart';

import '../models/adres.dart';
import '../services/adres_deposu.dart';
import '../utils/dogrulama.dart';
import '../widgets/adres_tablosu.dart';
import '../widgets/ana_menu.dart';
import '../widgets/form_ogeleri.dart';

/// Adres kayıtlarının eklendiği, güncellendiği ve silindiği ana ekran.
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

  final _aramaController = TextEditingController();

  List<TextEditingController> get _tumAlanlar =>
      [_kodController, _adController, _adresController, _sehirController, _telefonController, _epostaController];

  /// Aramaya uyan kayıtların [_kayitlar] içindeki sıraları.
  List<int> get _gorunenIndeksler => [
        for (var i = 0; i < _kayitlar.length; i++)
          if (_kayitlar[i].aramayaUyar(_aramaController.text)) i,
      ];

  @override
  void initState() {
    super.initState();
    _aramaController.addListener(() => setState(() {}));
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
    for (final c in _tumAlanlar) {
      c.dispose();
    }
    _aramaController.dispose();
    _kodFocus.dispose();
    super.dispose();
  }

  void _mesajGoster(String mesaj, {bool hata = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: hata ? Colors.red : Colors.green),
    );
  }

  void _formuBosalt() {
    for (final c in _tumAlanlar) {
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
        elevation: 0,
      ),
      drawer: AnaMenu(kayitlar: _kayitlar),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                IslemButonu(metin: 'Yeni Kayıt', renk: Colors.blue, ikon: Icons.add, onPressed: _yeniKayit),
                IslemButonu(metin: 'Kaydet', renk: Colors.green, ikon: Icons.save, onPressed: _kaydet),
                IslemButonu(metin: 'Güncelle', renk: Colors.orange, ikon: Icons.edit, onPressed: _guncelle),
                IslemButonu(metin: 'Sil', renk: Colors.red, ikon: Icons.delete, onPressed: _sil),
                IslemButonu(metin: 'Temizle', renk: Colors.teal, ikon: Icons.cleaning_services, onPressed: _formuBosalt),
              ],
            ),
            const SizedBox(height: 24),

            const BolumBasligi(baslik: 'ADRES ANA BİLGİLERİ', ikon: Icons.description_outlined),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  FormAlani(etiket: 'Kod *', controller: _kodController, focusNode: _kodFocus, dogrula: _kodDogrula),
                  FormAlani(etiket: 'Ad *', controller: _adController, dogrula: (d) => Dogrulama.zorunlu(d, 'Ad')),
                  FormAlani(etiket: 'Adres', controller: _adresController, maxLines: 3),
                  FormAlani(etiket: 'Şehir', controller: _sehirController),
                  FormAlani(etiket: 'Telefon', controller: _telefonController, klavye: TextInputType.phone, dogrula: Dogrulama.telefon),
                  FormAlani(etiket: 'E-posta', controller: _epostaController, klavye: TextInputType.emailAddress, dogrula: Dogrulama.eposta),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const BolumBasligi(baslik: 'KAYIT LİSTESİ', ikon: Icons.list_alt),
            TextField(
              controller: _aramaController,
              decoration: InputDecoration(
                labelText: 'Kayıtlarda ara',
                hintText: 'Kod, ad, adres, şehir, telefon veya e-posta',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _aramaController.text.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.close), tooltip: 'Aramayı temizle', onPressed: _aramaController.clear),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 8),
            if (_yukleniyor)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else ...[
              Text('${_gorunenIndeksler.length} / ${_kayitlar.length} kayıt', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              if (_gorunenIndeksler.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Aramaya uyan kayıt yok.')))
              else
                AdresTablosu(kayitlar: _kayitlar, gosterilecekler: _gorunenIndeksler, seciliIndex: _seciliIndex, onSec: _kaydiSec),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
