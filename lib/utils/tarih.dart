String _iki(int sayi) => sayi.toString().padLeft(2, '0');

/// 17.09.2026
String tarihYaz(DateTime t) => '${_iki(t.day)}.${_iki(t.month)}.${t.year}';

/// 13:40 (dosya adlarında [ayirac] ile ör. 13_40)
String saatYaz(DateTime t, {String ayirac = ':'}) => '${_iki(t.hour)}$ayirac${_iki(t.minute)}';
