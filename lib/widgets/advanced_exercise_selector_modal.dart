// lib/widgets/advanced_exercise_selector_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/audio_system.dart';
import '../core/youtube_helper.dart';
import '../models/task_model.dart';

class ExerciseLibraryItem {
  final String ad;
  final String kategori;
  final String tip; // 'Fiziksel' veya 'Zihinsel'
  final String varsayilanHacim;
  final String? youtubeArama;
  final String? kasGrubu;

  const ExerciseLibraryItem({
    required this.ad,
    required this.kategori,
    this.tip = 'Fiziksel',
    this.varsayilanHacim = '4 Set x 10 Tekrar',
    this.youtubeArama,
    this.kasGrubu,
  });
}

class AdvancedExerciseSelectorModal extends StatefulWidget {
  final String baslik;
  final String onayButonMetni;
  final void Function(Gorev gorev) onEklendi;

  const AdvancedExerciseSelectorModal({
    super.key,
    this.baslik = 'ZİNDANA EK HAREKET ENJEKTE ET',
    this.onayButonMetni = 'ZİNDANA EKLE',
    required this.onEklendi,
  });

  static Future<void> show(
    BuildContext context, {
    String baslik = 'ZİNDANA EK HAREKET ENJEKTE ET',
    String onayButonMetni = 'ZİNDANA EKLE',
    required void Function(Gorev gorev) onEklendi,
  }) {
    AudioSystem.playTransition();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdvancedExerciseSelectorModal(
        baslik: baslik,
        onayButonMetni: onayButonMetni,
        onEklendi: onEklendi,
      ),
    );
  }

  @override
  State<AdvancedExerciseSelectorModal> createState() =>
      _AdvancedExerciseSelectorModalState();
}

class _AdvancedExerciseSelectorModalState
    extends State<AdvancedExerciseSelectorModal> {
  static const Color sysGreen = Color(0xFF22C55E);
  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysRed = Color(0xFFEF4444);
  static const Color sysGold = Color(0xFFB08D57);
  static const Color sysDarkBg = Color(0xFF030712);
  static const Color sysCardBg = Color(0xFF070B14);

  final TextEditingController _aramaCtrl = TextEditingController();
  final TextEditingController _ozelGorevCtrl = TextEditingController();

  String _secilenKategori = 'Tümü';
  String _secilenTip = 'Fiziksel';
  int _secilenSet = 4;
  int _secilenTekrar = 10;
  int _secilenKardiyoDk = 20;

  ExerciseLibraryItem? _secilenItem;

  static const List<String> _kategoriler = [
    'Tümü',
    'Göğüs',
    'Sırt',
    'Omuz/Kol',
    'Bacak',
    'Karın',
    'Dövüş',
    'Kardiyo',
    'Calisthenics',
  ];

  static final List<ExerciseLibraryItem> _tumHareketler = [
    // ─── GÖĞÜS ───
    const ExerciseLibraryItem(ad: 'Incline Dumbbell Press', kategori: 'Göğüs', kasGrubu: 'Üst Göğüs & Ön Omuz'),
    const ExerciseLibraryItem(ad: 'Barbell Bench Press', kategori: 'Göğüs', kasGrubu: 'Tüm Göğüs & Triceps'),
    const ExerciseLibraryItem(ad: 'Dumbbell Fly', kategori: 'Göğüs', kasGrubu: 'Göğüs İzolasyon'),
    const ExerciseLibraryItem(ad: 'Dips / Sehpada İtiş', kategori: 'Göğüs', kasGrubu: 'Alt Göğüs & Triceps'),
    const ExerciseLibraryItem(ad: 'Kablo Göğüs İtiş (Cable Crossover)', kategori: 'Göğüs', kasGrubu: 'İç & Alt Göğüs'),
    const ExerciseLibraryItem(ad: 'Şınav (Push-up)', kategori: 'Göğüs', kasGrubu: 'Gövde & Göğüs'),
    const ExerciseLibraryItem(ad: 'Decline Dumbbell Press', kategori: 'Göğüs', kasGrubu: 'Alt Göğüs'),
    const ExerciseLibraryItem(ad: 'Machine Chest Press', kategori: 'Göğüs', kasGrubu: 'Tüm Göğüs'),
    const ExerciseLibraryItem(ad: 'Pec Deck Fly', kategori: 'Göğüs', kasGrubu: 'Göğüs Sıkıştırma'),
    const ExerciseLibraryItem(ad: 'Elmas Şınav (Diamond Push-up)', kategori: 'Göğüs', kasGrubu: 'Triceps & İç Göğüs'),
    const ExerciseLibraryItem(ad: 'Floor Press (Dumbbell/Barbell)', kategori: 'Göğüs', kasGrubu: 'Triceps & Kilitlenme'),
    const ExerciseLibraryItem(ad: 'Plyo Patlayıcı Şınav', kategori: 'Göğüs', kasGrubu: 'Patlayıcı İtiş'),

    // ─── SIRT ───
    const ExerciseLibraryItem(ad: 'Barfiks (Pull-up)', kategori: 'Sırt', kasGrubu: 'Kanat (Lats) & Biceps'),
    const ExerciseLibraryItem(ad: 'Lat Pulldown', kategori: 'Sırt', kasGrubu: 'Geniş Kanat'),
    const ExerciseLibraryItem(ad: 'Dumbbell Row', kategori: 'Sırt', kasGrubu: 'Orta Sırt & Kanat'),
    const ExerciseLibraryItem(ad: 'Barbell Row (Bent Over)', kategori: 'Sırt', kasGrubu: 'Sırt Kalınlığı & Trapez'),
    const ExerciseLibraryItem(ad: 'Face Pull', kategori: 'Sırt', kasGrubu: 'Arka Omuz & Üst Sırt'),
    const ExerciseLibraryItem(ad: 'T-Bar Row', kategori: 'Sırt', kasGrubu: 'Orta Sırt Kalınlığı'),
    const ExerciseLibraryItem(ad: 'Seated Cable Row', kategori: 'Sırt', kasGrubu: 'Alt & Orta Kanat'),
    const ExerciseLibraryItem(ad: 'Deadlift (Geleneksel)', kategori: 'Sırt', kasGrubu: 'Tüm Arka Zincir'),
    const ExerciseLibraryItem(ad: 'Çene Çekme (Chin-up)', kategori: 'Sırt', kasGrubu: 'Biceps & Alt Kanat'),
    const ExerciseLibraryItem(ad: 'Straight Arm Pulldown', kategori: 'Sırt', kasGrubu: 'Kanat İzolasyon'),
    const ExerciseLibraryItem(ad: 'Inverted Row (Australian Row)', kategori: 'Sırt', kasGrubu: 'Üst Sırt & Duruş'),

    // ─── OMUZ & KOL ───
    const ExerciseLibraryItem(ad: 'Overhead DB Press', kategori: 'Omuz/Kol', kasGrubu: 'Tüm Omuz Başı'),
    const ExerciseLibraryItem(ad: 'Overhead Barbell Press (OHP)', kategori: 'Omuz/Kol', kasGrubu: 'Ön/Yan Omuz & Çekirdek'),
    const ExerciseLibraryItem(ad: 'Lateral Raise (Dambıl Yan Açış)', kategori: 'Omuz/Kol', kasGrubu: 'Yan Omuz'),
    const ExerciseLibraryItem(ad: 'Arnold Press', kategori: 'Omuz/Kol', kasGrubu: 'Ön & Yan Omuz'),
    const ExerciseLibraryItem(ad: 'Biceps Barbell Curl', kategori: 'Omuz/Kol', kasGrubu: 'Ön Kol (Biceps)'),
    const ExerciseLibraryItem(ad: 'Hammer Curl', kategori: 'Omuz/Kol', kasGrubu: 'Brachialis & Ön Kol'),
    const ExerciseLibraryItem(ad: 'Incline Dumbbell Curl', kategori: 'Omuz/Kol', kasGrubu: 'Uzun Baş Biceps'),
    const ExerciseLibraryItem(ad: 'Preacher Curl (Scott Curl)', kategori: 'Omuz/Kol', kasGrubu: 'Kısa Baş Biceps'),
    const ExerciseLibraryItem(ad: 'Triceps Rope Pushdown', kategori: 'Omuz/Kol', kasGrubu: 'Dış Triceps'),
    const ExerciseLibraryItem(ad: 'Skull Crusher (Alna Triceps)', kategori: 'Omuz/Kol', kasGrubu: 'Uzun Baş Triceps'),
    const ExerciseLibraryItem(ad: 'Overhead Triceps Extension', kategori: 'Omuz/Kol', kasGrubu: 'Triceps Esnetme'),

    // ─── BACAK ───
    const ExerciseLibraryItem(ad: 'Barbell Squat', kategori: 'Bacak', kasGrubu: 'Ön Bacak (Quads) & Kalça'),
    const ExerciseLibraryItem(ad: 'Leg Press', kategori: 'Bacak', kasGrubu: 'Bacak Kuvveti'),
    const ExerciseLibraryItem(ad: 'Romanian Deadlift (RDL)', kategori: 'Bacak', kasGrubu: 'Arka Bacak (Hamstrings) & Kalça'),
    const ExerciseLibraryItem(ad: 'Bulgarian Split Squat', kategori: 'Bacak', kasGrubu: 'Tek Bacak Dengesi & Kalça'),
    const ExerciseLibraryItem(ad: 'Leg Extension', kategori: 'Bacak', kasGrubu: 'Ön Bacak İzolasyon'),
    const ExerciseLibraryItem(ad: 'Lying Leg Curl', kategori: 'Bacak', kasGrubu: 'Arka Bacak İzolasyon'),
    const ExerciseLibraryItem(ad: 'Walking Lunge / Adımlama', kategori: 'Bacak', kasGrubu: 'Kalça & Çeviklik'),
    const ExerciseLibraryItem(ad: 'Barbell Hip Thrust', kategori: 'Bacak', kasGrubu: 'Kalça Gücü (Glutes)'),
    const ExerciseLibraryItem(ad: 'Calf Raise (Kalf Yükseltme)', kategori: 'Bacak', kasGrubu: 'Baldır (Calves)'),
    const ExerciseLibraryItem(ad: 'Goblet Squat', kategori: 'Bacak', kasGrubu: 'Ön Bacak & Derinlik'),
    const ExerciseLibraryItem(ad: 'Box Jump / Sıçrama', kategori: 'Bacak', kasGrubu: 'Patlayıcı Bacak Gücü'),

    // ─── KARIN ───
    const ExerciseLibraryItem(ad: 'Hanging Leg Raise', kategori: 'Karın', kasGrubu: 'Alt Karın & Tutuş'),
    const ExerciseLibraryItem(ad: 'Plank', kategori: 'Karın', kasGrubu: 'Derin Çekirdek & Dayanıklılık'),
    const ExerciseLibraryItem(ad: 'Kablo Crunch', kategori: 'Karın', kasGrubu: 'Üst Karın Hipertrofisi'),
    const ExerciseLibraryItem(ad: 'Russian Twist', kategori: 'Karın', kasGrubu: 'Oblikler & Rotasyon'),
    const ExerciseLibraryItem(ad: 'Ab Wheel Rollout', kategori: 'Karın', kasGrubu: 'Tüm Karın Duvarı'),
    const ExerciseLibraryItem(ad: 'Bicycle Crunch', kategori: 'Karın', kasGrubu: 'Çapraz Karın Kasları'),
    const ExerciseLibraryItem(ad: 'Dragon Flag (Bruce Lee)', kategori: 'Karın', kasGrubu: 'Ekstrem Core Gücü'),
    const ExerciseLibraryItem(ad: 'Hollow Body Hold', kategori: 'Karın', kasGrubu: 'Jimnastik Core Kilidi'),

    // ─── DÖVÜŞ / GÖLGE BOKSU ───
    const ExerciseLibraryItem(ad: 'Peek-a-boo: Bob & Weave + 1-2-Roll-3', kategori: 'Dövüş', kasGrubu: 'Baş Hareketi & Patlayıcı Kroşe'),
    const ExerciseLibraryItem(ad: 'Out-Boxer: Double Jab + Cross + Sol Pivot', kategori: 'Dövüş', kasGrubu: 'Mesafe Kontrolü & Ayak Çevikliği'),
    const ExerciseLibraryItem(ad: 'İç Dövüş: 1-2 + Karaciğer Kroşesi + Aparkat', kategori: 'Dövüş', kasGrubu: 'Gövde Vuruşları & Yakın Dövüş'),
    const ExerciseLibraryItem(ad: 'Dutch Kickboks: 1-2-Sol Kroşe-Sağ Low Kick', kategori: 'Dövüş', kasGrubu: 'Kombine Dövüş & Bacak Yıkımı'),
    const ExerciseLibraryItem(ad: 'Muay Thai: Teep + 1-2 + Yatay Dirsek + Diz', kategori: 'Dövüş', kasGrubu: '8 Uzuv Sanatı & Clinch'),
    const ExerciseLibraryItem(ad: 'MMA: 1-2 + Takedown Sahtesi + Overhand + Sprawl', kategori: 'Dövüş', kasGrubu: 'Seviye Değişimi & Güreş Savunması'),
    const ExerciseLibraryItem(ad: 'Güreş: Pummeling & Seviye Değişimi Drilli', kategori: 'Dövüş', kasGrubu: 'Üst Gövde Kontrolü & Çekme Gücü'),
    const ExerciseLibraryItem(ad: 'Ağır Kum Torbası Kombinasyonları', kategori: 'Dövüş', kasGrubu: 'Darbe Gücü & Kemik Yoğunluğu'),
    const ExerciseLibraryItem(ad: 'Hızlı İp Atlama & Ayak Çevikliği', kategori: 'Dövüş', kasGrubu: 'Ritim & Baldır Dayanıklılığı'),
    const ExerciseLibraryItem(ad: 'Burpee Sprawl & Darbe Direnci', kategori: 'Dövüş', kasGrubu: 'Dövüş Kondisyonu & Akciğer Kapasitesi'),
    const ExerciseLibraryItem(ad: 'Slip & Counter Kontra Yumruk', kategori: 'Dövüş', kasGrubu: 'Refleks & Zamanlama'),

    // ─── KARDİYO ───
    const ExerciseLibraryItem(ad: '5 KM Avcı Koşusu (Hunter Run)', kategori: 'Kardiyo', kasGrubu: 'Aerobik Taban & Dayanıklılık'),
    const ExerciseLibraryItem(ad: '10 KM Maraton Koşusu', kategori: 'Kardiyo', kasGrubu: 'Aşırı Dayanıklılık (Saitama)'),
    const ExerciseLibraryItem(ad: '20 Dk Eğimli Yürüyüş Bandı (Incline Treadmill)', kategori: 'Kardiyo', kasGrubu: 'Zone 2 Yağ Yakımı'),
    const ExerciseLibraryItem(ad: '15 Dk Yüksek Yoğunluklu İp Atlama (HIIT)', kategori: 'Kardiyo', kasGrubu: 'Maksimal Kalp Hızı'),
    const ExerciseLibraryItem(ad: '20 Dk Zone 2 Dayanıklılık Koşusu', kategori: 'Kardiyo', kasGrubu: 'Mitokondri Gelişimi'),
    const ExerciseLibraryItem(ad: '15 Dk İnterval Sprint (Zone 4 Tabata)', kategori: 'Kardiyo', kasGrubu: 'Anaerobik Güç'),
    const ExerciseLibraryItem(ad: '20 Dk Kondisyon Bisikleti / Spinning', kategori: 'Kardiyo', kasGrubu: 'Düşük Eklem Yükü Kardiyo'),
    const ExerciseLibraryItem(ad: '15 Dk Concept 2 Kürek Ergometresi', kategori: 'Kardiyo', kasGrubu: 'Tüm Vücut Kondisyonu'),
    const ExerciseLibraryItem(ad: 'Dövüş Kondisyonu: Burpee Sprawl & Sıçrama', kategori: 'Kardiyo', kasGrubu: 'Dövüş Dayanıklılığı'),
    const ExerciseLibraryItem(ad: 'Merdiven Tırmanma (Stairmaster)', kategori: 'Kardiyo', kasGrubu: 'Kalça & Kardiyovasküler'),

    // ─── CALISTHENICS ───
    const ExerciseLibraryItem(ad: 'Muscle-up (Barda / Halkada)', kategori: 'Calisthenics', kasGrubu: 'Üst Gövde Patlayıcı Çekiş & İtiş'),
    const ExerciseLibraryItem(ad: 'L-Sit Hold (Parallette / Yerde)', kategori: 'Calisthenics', kasGrubu: 'Ön Kol & Sıkı Karın'),
    const ExerciseLibraryItem(ad: 'Handstand Push-up (Amuda Şınav)', kategori: 'Calisthenics', kasGrubu: 'Saf Omuz Gücü & Denge'),
    const ExerciseLibraryItem(ad: 'Pistol Squat (Tek Bacak Çöküş)', kategori: 'Calisthenics', kasGrubu: 'Tek Bacak Kuvveti & Bilek Hareketliliği'),
    const ExerciseLibraryItem(ad: 'Archer Push-up (Okçu Şınavı)', kategori: 'Calisthenics', kasGrubu: 'Tek Taraflı Göğüs İtiş'),
    const ExerciseLibraryItem(ad: 'Archer Pull-up (Okçu Barfiksi)', kategori: 'Calisthenics', kasGrubu: 'Tek Kol Barfiks Hazırlığı'),
    const ExerciseLibraryItem(ad: 'Ring Dips (Jimnastik Halkası Dips)', kategori: 'Calisthenics', kasGrubu: 'Omuz Stabilizasyonu & Göğüs'),
  ];

  @override
  void initState() {
    super.initState();
    _secilenItem = _tumHareketler.first;
    _secilenKategori = 'Tümü';
  }

  @override
  void dispose() {
    _aramaCtrl.dispose();
    _ozelGorevCtrl.dispose();
    super.dispose();
  }

  List<ExerciseLibraryItem> get _filtrelenmisHareketler {
    final arama = _aramaCtrl.text.trim().toLowerCase();
    return _tumHareketler.where((item) {
      final kategoriUyumu = (_secilenKategori == 'Tümü') || (item.kategori == _secilenKategori);
      if (!kategoriUyumu) return false;
      if (arama.isEmpty) return true;
      return item.ad.toLowerCase().contains(arama) ||
          (item.kasGrubu?.toLowerCase().contains(arama) ?? false) ||
          item.kategori.toLowerCase().contains(arama);
    }).toList();
  }

  String _formatlanmisGorevAdi() {
    if (_ozelGorevCtrl.text.trim().isNotEmpty) {
      final ozel = _ozelGorevCtrl.text.trim();
      if (_secilenTip == 'Zihinsel') return '[MNT] $ozel';
      return ozel.startsWith('[') ? ozel : '[EXTRA] $ozel';
    }

    final item = _secilenItem ?? _tumHareketler.first;
    final ad = item.ad;

    if (item.kategori == 'Kardiyo') {
      if (ad.contains('5 KM') || ad.contains('10 KM')) {
        return '[CARDIO] $ad';
      }
      return '[CARDIO] $ad ($_secilenKardiyoDk Dk)';
    }

    if (item.kategori == 'Dövüş') {
      return '[EXTRA] $ad ($_secilenSet Raund x 3 Dk)';
    }

    if (ad.toLowerCase().contains('plank') || ad.toLowerCase().contains('hold')) {
      return '[EXTRA] $ad ($_secilenSet Set x 60sn)';
    }

    return '[EXTRA] $ad ($_secilenSet Set x $_secilenTekrar Tekrar)';
  }

  void _onaylaVeEkle() {
    final gorevAdi = _formatlanmisGorevAdi();
    final gorev = Gorev(gorevAdi, false, _secilenTip);
    AudioSystem.playSuccess();
    widget.onEklendi(gorev);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final liste = _filtrelenmisHareketler;

    return AlertDialog(
      backgroundColor: sysDarkBg.withValues(alpha: 0.98),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: sysGreen, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      title: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: sysGreen, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.baslik,
              style: GoogleFonts.orbitron(
                color: sysGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white60, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '875+ Egzersiz kütüphanesinden seçin, filtreleyin ve set/tekrar hacmini belirleyin.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
              const SizedBox(height: 10),

              // ── CANLI ARAMA ÇUBUĞU ──
              TextField(
                controller: _aramaCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Egzersiz veya kas ara (örn: Bench, Squat, Koşu, Boks)...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  prefixIcon: const Icon(Icons.search, color: sysGreen, size: 18),
                  suffixIcon: _aramaCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white60, size: 16),
                          onPressed: () {
                            _aramaCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: sysCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: sysGreen.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: sysGreen, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── KATEGORİ FİLTRE ÇİPLERİ ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _kategoriler.map((kat) {
                    final secili = _secilenKategori == kat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(kat),
                        selected: secili,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _secilenKategori = kat;
                              final liste = _filtrelenmisHareketler;
                              if (liste.isNotEmpty) {
                                _secilenItem = liste.first;
                              }
                            });
                            AudioSystem.playTransition();
                          }
                        },
                        selectedColor: sysGreen.withValues(alpha: 0.25),
                        backgroundColor: sysCardBg,
                        labelStyle: TextStyle(
                          color: secili ? sysGreen : const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: secili ? sysGreen : Colors.white10,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // ── EGZERSİZ SEÇİM KARTLARI (YATAY / DİKEY SCROLL LİSTE) ──
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: sysCardBg,
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: liste.isEmpty
                    ? const Center(
                        child: Text(
                          'Aramanızla eşleşen egzersiz bulunamadı.\nAşağıdan özel isim yazabilirsiniz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(6),
                        itemCount: liste.length,
                        itemBuilder: (context, idx) {
                          final item = liste[idx];
                          final secili = _secilenItem?.ad == item.ad;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _secilenItem = item;
                                _ozelGorevCtrl.clear();
                              });
                              AudioSystem.playTransition();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: secili ? sysGreen.withValues(alpha: 0.15) : Colors.transparent,
                                border: Border.all(
                                  color: secili ? sysGreen : Colors.white10,
                                  width: secili ? 1.2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    secili ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: secili ? sysGreen : Colors.white30,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.ad,
                                          style: GoogleFonts.rajdhani(
                                            color: secili ? Colors.white : const Color(0xFFE2E8F0),
                                            fontSize: 13,
                                            fontWeight: secili ? FontWeight.bold : FontWeight.w600,
                                          ),
                                        ),
                                        if (item.kasGrubu != null)
                                          Text(
                                            '${item.kategori} • ${item.kasGrubu}',
                                            style: TextStyle(
                                              color: secili ? sysGreen : const Color(0xFF64748B),
                                              fontSize: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // YouTube Video Önizleme Butonu
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill, color: sysRed, size: 18),
                                    tooltip: 'Form Videosu',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => YoutubeHelper.videoAc(item.ad),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              // ── HACİM & SET/TEKRAR / KARDİYO DAKİKA AYARLARI ──
              if (_secilenKategori == 'Kardiyo' || _secilenItem?.kategori == 'Kardiyo') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KARDİYO SÜRESİ:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                    Row(
                      children: [15, 20, 30, 45].map((dk) {
                        final secili = _secilenKardiyoDk == dk;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: InkWell(
                            onTap: () => setState(() => _secilenKardiyoDk = dk),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: secili ? sysBlue.withValues(alpha: 0.25) : sysCardBg,
                                border: Border.all(color: secili ? sysBlue : Colors.white24),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$dk Dk',
                                style: TextStyle(
                                  color: secili ? sysBlue : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ] else ...[
                // Hızlı Hacim Kademeleri
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HACİM & UZATMA SEVİYESİ:',
                      style: GoogleFonts.orbitron(
                        color: sysGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _hacimKademesiChip('⚡ Standart (4 Set/Raund)', 4, 10),
                          const SizedBox(width: 6),
                          _hacimKademesiChip('⚔️ Uzatılmış (6 Set/Raund)', 6, 12),
                          const SizedBox(width: 6),
                          _hacimKademesiChip('👑 Şampiyon (8 Set/Raund)', 8, 15),
                          const SizedBox(width: 6),
                          _hacimKademesiChip('🔥 Ekstrem (10 Set/Raund)', 10, 20),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Hassas Set & Tekrar Sayaçları
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sysCardBg,
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Set/Raund: $_secilenSet',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 14, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    if (_secilenSet > 1) setState(() => _secilenSet--);
                                  },
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 14, color: sysGreen),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    if (_secilenSet < 20) setState(() => _secilenSet++);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sysCardBg,
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tekrar: $_secilenTekrar', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 14, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    if (_secilenTekrar > 2) setState(() => _secilenTekrar -= 2);
                                  },
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 14, color: sysGreen),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    if (_secilenTekrar < 50) setState(() => _secilenTekrar += 2);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // ── ÖZEL HAREKET GİRİŞİ ──
              TextField(
                controller: _ozelGorevCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Veya buraya özel bir görev / egzersiz yazın...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  prefixIcon: const Icon(Icons.edit_note, color: sysGold, size: 18),
                  filled: true,
                  fillColor: sysCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: sysGold, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── ÖNİZLEME ETİKETİ ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: sysGreen.withValues(alpha: 0.08),
                  border: Border.all(color: sysGreen.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.preview, color: sysGreen, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatlanmisGorevAdi(),
                        style: GoogleFonts.orbitron(
                          color: sysGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
                child: const Text('İPTAL'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sysGreen.withValues(alpha: 0.2),
                  side: const BorderSide(color: sysGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: _onaylaVeEkle,
                icon: const Icon(Icons.bolt, color: sysGreen, size: 18),
                label: Text(
                  widget.onayButonMetni,
                  style: GoogleFonts.orbitron(
                    color: sysGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hacimKademesiChip(String etiket, int setSayisi, int tekrarSayisi) {
    final secili = _secilenSet == setSayisi && _secilenTekrar == tekrarSayisi;
    return InkWell(
      onTap: () {
        setState(() {
          _secilenSet = setSayisi;
          _secilenTekrar = tekrarSayisi;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: secili ? sysGreen.withValues(alpha: 0.25) : sysCardBg,
          border: Border.all(color: secili ? sysGreen : Colors.white24),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          etiket,
          style: TextStyle(
            color: secili ? sysGreen : Colors.white70,
            fontSize: 10,
            fontWeight: secili ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
