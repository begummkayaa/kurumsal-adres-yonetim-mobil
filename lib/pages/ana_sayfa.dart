import 'package:flutter/material.dart';

import '../models/adres.dart';
import '../services/adres_api.dart';
import '../services/api_istemcisi.dart';
import '../services/ayar_deposu.dart';
import '../services/kur_api.dart';
import '../tema.dart';
import '../utils/dogrulama.dart';
import '../widgets/ana_menu.dart';
import '../widgets/form_ogeleri.dart';
import '../widgets/kayit_tablosu.dart';
import '../widgets/marka_basligi.dart';
import '../widgets/tablo_paneli.dart';

enum _Yon { ilk, geri, ileri, son }

/// Adres kayıtlarının eklendiği, güncellendiği ve silindiği ana ekran.
class AnaSayfa extends StatefulWidget {
  /// Testlerde gerçek API'ye bağlanmamak için dışarıdan verilebilir.
  final AdresApi? adresApi;
  final KurApi? kurApi;

  const AnaSayfa({super.key, this.adresApi, this.kurApi});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late final _adresApi = widget.adresApi ?? AdresApi();
  late final _kurApi = widget.kurApi ?? KurApi();
  final _ayarlar = AyarDeposu();
  bool _kurCekiliyor = false;
  List<Adres> _kayitlar = [];
  bool _yukleniyor = true;
  String? _yuklemeHatasi;

  /// Kaydet/Güncelle/Sil isteği sürerken ikinci kez basılmasın diye.
  bool _islemSuruyor = false;

  /// Her form alanının controller'ı.
  final _alanlar = {for (final a in AdresAlani.values) a: TextEditingController()};
  final _kodFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int? _seciliIndex;

  final _aramaController = TextEditingController();

  Iterable<TextEditingController> get _tumAlanlar => _alanlar.values;

  /// Kayıt listesinde (web sürümündeki gibi) yetkililer dışındaki tüm alanlar gösterilir.
  static final _listeSutunlari =
      AdresAlani.values.where((a) => a != AdresAlani.yetkili1 && a != AdresAlani.yetkili2).toList();

  /// Aramaya uyan kayıtların [_kayitlar] içindeki sıraları.
  List<int> get _gorunenIndeksler => [
        for (var i = 0; i < _kayitlar.length; i++)
          if (_kayitlar[i].aramayaUyar(_aramaController.text)) i,
      ];

  @override
  void initState() {
    super.initState();
    _aramaController.addListener(() => setState(() {}));
    _kayitlariYukle().then((_) => _otomatikKurServisi());
  }

  /// Kayıtları veritabanından (API) yeniden okur. Seçili kayıt hâlâ varsa seçili kalır.
  Future<void> _kayitlariYukle() async {
    final seciliId = _seciliIndex == null ? null : _kayitlar[_seciliIndex!].id;
    setState(() {
      _yukleniyor = true;
      _yuklemeHatasi = null;
    });
    try {
      final kayitlar = await _adresApi.listele();
      if (!mounted) return;
      final yeniIndex = kayitlar.indexWhere((k) => k.id == seciliId);
      setState(() {
        _kayitlar = kayitlar;
        _seciliIndex = seciliId == null || yeniIndex == -1 ? null : yeniIndex;
      });
    } on ApiHatasi catch (e) {
      if (!mounted) return;
      setState(() => _yuklemeHatasi = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  /// [islem] sürerken diğer işlemleri engeller; API hatasını kullanıcıya gösterir.
  Future<void> _apiIslemi(Future<void> Function() islem) async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    try {
      await islem();
    } on ApiHatasi catch (e) {
      _mesajGoster(e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  /// Otomatik kur servisi açıksa ve arşivde bugünün çekimi yoksa (web/masaüstünden yapılanlar dahil)
  /// uygulama açılışında güncel kuru çeker.
  Future<void> _otomatikKurServisi() async {
    if (!await _ayarlar.otomatikKurServisiAcikMi()) return;
    try {
      if (await _kurApi.bugunCekildiMi(DateTime.now())) return;
    } on ApiHatasi {
      return; // API'ye ulaşılamıyorsa kayıt listesi zaten hatayı gösteriyor.
    }
    await _guncelKurCek();
  }

  /// API'ye güncel dolar/euro kurunu TCMB'den çektirip TCMB Döviz Arşivi'ne ekletir.
  Future<void> _guncelKurCek() async {
    setState(() => _kurCekiliyor = true);
    try {
      final kayit = await _kurApi.guncelKurCek();
      _mesajGoster('Güncel kur çekildi ve arşive eklendi: '
          'USD ${kayit.dolar?.toStringAsFixed(4) ?? '-'} · EUR ${kayit.euro?.toStringAsFixed(4) ?? '-'}');
    } on ApiHatasi catch (e) {
      _mesajGoster(e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kurCekiliyor = false);
    }
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
    if (!mounted) return; // ör. kur çekilirken sayfadan çıkıldıysa
    // Önceki mesaj kapanmadan yenisi gelirse (ör. art arda gezinme) beklemeden onu göster.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
  Adres? _formdanAdres({int? id}) {
    if (!_formKey.currentState!.validate()) {
      _mesajGoster('Lütfen formdaki hatalı alanları düzeltin.', hata: true);
      return null;
    }
    return Adres.alanlardan(_alanlar.map((alan, c) => MapEntry(alan, c.text.trim())), id: id);
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
      enFazla: alan.enFazla,
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

  /// İlk/Geri/İleri/Son: listede görünen (aramaya uyan) kayıtlar arasında gezinir.
  void _gez(_Yon yon) {
    final liste = _gorunenIndeksler;
    if (liste.isEmpty) {
      _mesajGoster('Listede gezinilecek kayıt yok.', hata: true);
      return;
    }
    final simdiki = _seciliIndex == null ? -1 : liste.indexOf(_seciliIndex!);
    final hedef = switch (yon) {
      _Yon.ilk => 0,
      _Yon.son => liste.length - 1,
      // Seçim yoksa İleri ilk kayda, Geri son kayda gider.
      _Yon.ileri => simdiki == -1 ? 0 : simdiki + 1,
      _Yon.geri => simdiki == -1 ? liste.length - 1 : simdiki - 1,
    };
    if (hedef < 0) {
      _mesajGoster('İlk kayıttasınız.');
      return;
    }
    if (hedef >= liste.length) {
      _mesajGoster('Son kayıttasınız.');
      return;
    }
    _kaydiSec(liste[hedef]);
  }

  Widget _butonGrubu(List<Widget> butonlar) => Wrap(spacing: 8, runSpacing: 8, children: butonlar);

  Widget _listeIcerigi() {
    if (_yukleniyor) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
    if (_yuklemeHatasi != null) return _yuklemeHatasiKutusu(_yuklemeHatasi!);
    if (_gorunenIndeksler.isEmpty) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Aramaya uyan kayıt yok.')));
    }
    return KayitTablosu(
      kayitlar: _kayitlar,
      alanlar: _listeSutunlari,
      ozelBasliklar: const {AdresAlani.kod: 'FİRMA KODU', AdresAlani.ad: 'FİRMA ÜNVANI'},
      gosterilecekler: _gorunenIndeksler,
      seciliIndex: _seciliIndex,
      onSec: _kaydiSec,
    );
  }

  Widget _yuklemeHatasiKutusu(String mesaj) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Icon(Icons.cloud_off, color: Colors.red, size: 36),
        const SizedBox(height: 8),
        Text('Kayıtlar yüklenemedi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _kayitlariYukle, icon: const Icon(Icons.refresh), label: const Text('Tekrar Dene')),
      ]),
    );
  }

  void _yeniKayit() {
    _formuBosalt();
    _kodFocus.requestFocus();
  }

  Future<void> _kaydet() async {
    final yeni = _formdanAdres();
    if (yeni == null) return;

    await _apiIslemi(() async {
      final kaydedilen = await _adresApi.ekle(yeni);
      if (!mounted) return;
      setState(() => _kayitlar.add(kaydedilen));
      _formuBosalt();
      _mesajGoster('Kayıt eklendi.');
    });
  }

  Future<void> _guncelle() async {
    final index = _seciliIndex;
    if (index == null) {
      _mesajGoster('Güncellemek için tablodan bir kayıt seçin.', hata: true);
      return;
    }
    final guncel = _formdanAdres(id: _kayitlar[index].id);
    if (guncel == null) return;

    await _apiIslemi(() async {
      final kaydedilen = await _adresApi.guncelle(guncel);
      if (!mounted) return;
      setState(() => _kayitlar[index] = kaydedilen);
      _formuBosalt();
      _mesajGoster('Kayıt güncellendi.');
    });
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

    await _apiIslemi(() async {
      await _adresApi.sil(kayit.id!);
      if (!mounted) return;
      setState(() => _kayitlar.removeAt(index));
      _formuBosalt();
      _mesajGoster('Kayıt silindi.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MarkaBasligi(),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _yukleniyor ? null : _kayitlariYukle,
            icon: const Icon(Icons.refresh),
            tooltip: 'Kayıtları yenile',
          ),
        ],
      ),
      drawer: AnaMenu(kayitlar: _kayitlar, kurApi: _kurApi),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Kartlar web sürümündeki gibi sayfa genişliğinde.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _butonGrubu([
                      IslemButonu(metin: 'Yeni Kayıt', renk: const Color(0xFF0D6EFD), ikon: Icons.add, onPressed: _yeniKayit),
                      IslemButonu(metin: 'Kaydet', renk: const Color(0xFF198754), ikon: Icons.save, onPressed: _kaydet),
                      IslemButonu(
                        metin: 'Güncelle',
                        renk: const Color(0xFFFFC107),
                        yaziRengi: Colors.black87,
                        ikon: Icons.edit,
                        onPressed: _guncelle,
                      ),
                      IslemButonu(metin: 'Sil', renk: const Color(0xFFDC3545), ikon: Icons.delete, onPressed: _sil),
                    ]),
                    _butonGrubu([
                      IslemButonu(metin: 'İlk', renk: anaRenk, ikon: Icons.first_page, cerceveli: true, onPressed: () => _gez(_Yon.ilk)),
                      IslemButonu(metin: 'Geri', renk: anaRenk, ikon: Icons.chevron_left, cerceveli: true, onPressed: () => _gez(_Yon.geri)),
                      IslemButonu(metin: 'İleri', renk: anaRenk, ikon: Icons.chevron_right, cerceveli: true, onPressed: () => _gez(_Yon.ileri)),
                      IslemButonu(metin: 'Son', renk: anaRenk, ikon: Icons.last_page, cerceveli: true, onPressed: () => _gez(_Yon.son)),
                    ]),
                    _butonGrubu([
                      IslemButonu(
                        metin: 'Ekranı Temizle',
                        renk: const Color(0xFF0D6EFD),
                        ikon: Icons.cleaning_services,
                        cerceveli: true,
                        onPressed: _formuBosalt,
                      ),
                      IslemButonu(
                        metin: _kurCekiliyor ? 'Kur Çekiliyor...' : 'Güncel Kur Çek',
                        renk: anaRenk,
                        ikon: Icons.currency_exchange,
                        cerceveli: true,
                        onPressed: _kurCekiliyor ? () {} : _guncelKurCek,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  BolumBasligi(
                    baslik: 'ADRES ANA BİLGİLERİ',
                    ikon: Icons.description_outlined,
                    sag: _seciliIndex == null ? 'Yeni Kayıt Girişi' : 'Aktif Kayıt Düzenleme',
                  ),
                  Form(key: _formKey, child: _form()),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            TabloPaneli(
              baslik: 'Kayıt Listesi',
              aramaController: _aramaController,
              altSag: 'Listelenen Kayıt Sayısı: ${_gorunenIndeksler.length}',
              child: _listeIcerigi(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
