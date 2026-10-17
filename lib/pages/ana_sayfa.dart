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

  /// Her form alanının controller'ı.
  final _alanlar = {for (final a in AdresAlani.values) a: TextEditingController()};
  final _kodFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int? _seciliIndex;

  final _aramaController = TextEditingController();

  Iterable<TextEditingController> get _tumAlanlar => _alanlar.values;

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
    _alanlar.forEach((alan, c) => c.text = k[alan]);
    setState(() => _seciliIndex = index);
  }

  /// Formu doğrular ve bilgilerden bir Adres oluşturur; hatalı alan varsa uyarı gösterip null döner.
  Adres? _formdanAdres() {
    if (!_formKey.currentState!.validate()) {
      _mesajGoster('Lütfen formdaki hatalı alanları düzeltin.', hata: true);
      return null;
    }
    return Adres.alanlardan(_alanlar.map((alan, c) => MapEntry(alan, c.text.trim())));
  }

  FormFieldValidator<String>? _dogrulayici(AdresAlani alan) => switch (alan) {
        AdresAlani.kod => _kodDogrula,
        AdresAlani.ad => (d) => Dogrulama.zorunlu(d, 'Ad'),
        AdresAlani.telefon => Dogrulama.telefon,
        AdresAlani.fax => Dogrulama.fax,
        AdresAlani.postaKodu => (d) => Dogrulama.sadeceRakam(d, 'Posta Kodu'),
        AdresAlani.vergiNo => (d) => Dogrulama.sadeceRakam(d, 'Vergi No'),
        AdresAlani.eposta => Dogrulama.eposta,
        AdresAlani.webSitesi => Dogrulama.webSitesi,
        _ => null,
      };

  TextInputType? _klavye(AdresAlani alan) => switch (alan) {
        AdresAlani.telefon || AdresAlani.fax => TextInputType.phone,
        AdresAlani.postaKodu || AdresAlani.vergiNo => TextInputType.number,
        AdresAlani.eposta => TextInputType.emailAddress,
        AdresAlani.webSitesi => TextInputType.url,
        _ => null,
      };

  Widget _formAlani(AdresAlani alan) {
    final zorunlu = alan == AdresAlani.kod || alan == AdresAlani.ad;
    return FormAlani(
      etiket: zorunlu ? '${alan.etiket} *' : alan.etiket,
      controller: _alanlar[alan]!,
      focusNode: alan == AdresAlani.kod ? _kodFocus : null,
      maxLines: alan == AdresAlani.adres ? 3 : 1,
      klavye: _klavye(alan),
      dogrula: _dogrulayici(alan),
    );
  }

  /// Web sürümündeki gibi: solda adres, sağda iletişim/vergi/yetkili bilgileri.
  /// Dar ekranda (telefon) iki grup alt alta tek sütun olur.
  Widget _form() {
    const sol = [AdresAlani.kod, AdresAlani.ad, AdresAlani.adres, AdresAlani.semt, AdresAlani.sehir, AdresAlani.ulke, AdresAlani.postaKodu];
    final sag = AdresAlani.values.where((a) => !sol.contains(a));
    return LayoutBuilder(builder: (context, kisit) {
      final solSutun = Column(children: [for (final a in sol) _formAlani(a)]);
      final sagSutun = Column(children: [for (final a in sag) _formAlani(a)]);
      if (kisit.maxWidth < 700) return Column(children: [solSutun, sagSutun]);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: solSutun), const SizedBox(width: 24), Expanded(child: sagSutun)],
      );
    });
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
            Form(key: _formKey, child: _form()),
            const SizedBox(height: 32),

            const BolumBasligi(baslik: 'KAYIT LİSTESİ', ikon: Icons.list_alt),
            TextField(
              controller: _aramaController,
              decoration: InputDecoration(
                labelText: 'Kayıtlarda ara',
                hintText: 'İsim, kod veya herhangi bir bilgi',
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
