// lib/screens/workout_library_screen.dart
// ============================================================
// YOUTUBE DESTEKLİ & DÜZENLENEBİLİR ANTRENMAN KÜTÜPHANESİ
// Hazır antrenman şablonları sunar, her egzersiz satırında
// YouTube link ikonu bulunur, kullanıcı programı düzenleyebilir.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_model.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart';

// ──────────────────────────────────────────────
// ANA EKRAN
// ──────────────────────────────────────────────
class WorkoutLibraryScreen extends StatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  State<WorkoutLibraryScreen> createState() => _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends State<WorkoutLibraryScreen> {
  // ─── Sistem Renkleri ───
  static const Color _sysBlue   = Color(0xFF38BDF8);
  static const Color _sysDarkBg = Color(0xFF030712);
  static const Color _sysRed    = Color(0xFFEF4444);
  static const Color _sysGold   = Color(0xFFB08D57);
  static const Color _sysText   = Color(0xFF94A3B8);
  static const Color _sysGreen  = Color(0xFF22C55E);
  static const Color _sysPurple = Color(0xFFA855F7);

  // ─── State ───
  int _seciliSablonIndex = 0;
  bool _duzenlemeModu = false;

  late List<_AntrenmanSablonu> _sablonlar;

  @override
  void initState() {
    super.initState();
    _sablonlar = _varsayilanSablonlar();
    _kayitliVerileriYukle();
  }

  // ══════════════════════════════════════════════
  // VERİ KATMANI: Kaydet / Yükle (SharedPreferences)
  // ══════════════════════════════════════════════
  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> kayitListesi = _sablonlar.map((s) => {
      'ad': s.ad,
      'egzersizler': s.egzersizler.map((e) => e.toJson()).toList(),
    }).toList();
    await prefs.setString('workout_library_data', jsonEncode(kayitListesi));
  }

  Future<void> _kayitliVerileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('workout_library_data');
    if (json != null && json.isNotEmpty) {
      try {
        List<dynamic> kayitListesi = jsonDecode(json);
        for (var kayit in kayitListesi) {
          String ad = kayit['ad'];
          int sablonIdx = _sablonlar.indexWhere((s) => s.ad == ad);
          if (sablonIdx != -1) {
            List<dynamic> eList = kayit['egzersizler'];
            _sablonlar[sablonIdx].egzersizler = eList.map((e) => Egzersiz.fromJson(e)).toList();
          }
        }
        if (mounted) setState(() {});
      } catch (_) {}
    }
  }

  Future<void> _sablonuSifirla() async {
    final varsayilanlar = _varsayilanSablonlar();
    setState(() {
      _sablonlar[_seciliSablonIndex].egzersizler =
          varsayilanlar[_seciliSablonIndex].egzersizler.map((e) => e.kopyala()).toList();
    });
    await _kaydet();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('[SYSTEM] Template "${_sablonlar[_seciliSablonIndex].ad}" reset to default.'),
          backgroundColor: _sysBlue,
        ),
      );
    }
  }

  // ─── YouTube Aç ───
  Future<void> _youtubeAc(String aramaKelimesi) async {
    final url = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(aramaKelimesi)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ══════════════════════════════════════════════
  // DİYALOGLAR
  // ══════════════════════════════════════════════

  // ─── Egzersiz Ekle Diyalogu ───
  void _egzersizEkleDialog() {
    final adCtrl = TextEditingController();
    final setCtrl = TextEditingController(text: "3x12");
    final ytCtrl = TextEditingController();
    String kategori = "Fiziksel";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0E17),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: _sysBlue, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              title: Text(
                '[ ADD CUSTOM QUEST ]',
                style: GoogleFonts.orbitron(color: _sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogInput(adCtrl, 'Exercise Name', Icons.fitness_center),
                    const SizedBox(height: 12),
                    _dialogInput(setCtrl, 'Sets x Reps (e.g. 3x12)', Icons.repeat),
                    const SizedBox(height: 12),
                    _dialogInput(ytCtrl, 'YouTube Search (Optional)', Icons.play_circle_fill),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('TYPE: ', style: GoogleFonts.rajdhani(color: _sysText, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('PHY', style: TextStyle(color: kategori == "Fiziksel" ? Colors.black : _sysText, fontWeight: FontWeight.bold, fontSize: 12)),
                          selected: kategori == "Fiziksel",
                          selectedColor: _sysBlue,
                          backgroundColor: const Color(0xFF0F172A),
                          side: BorderSide(color: kategori == "Fiziksel" ? _sysBlue : _sysText.withValues(alpha: 0.3)),
                          onSelected: (_) => setDialogState(() => kategori = "Fiziksel"),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('MNT', style: TextStyle(color: kategori == "Zihinsel" ? Colors.black : _sysText, fontWeight: FontWeight.bold, fontSize: 12)),
                          selected: kategori == "Zihinsel",
                          selectedColor: _sysPurple,
                          backgroundColor: const Color(0xFF0F172A),
                          side: BorderSide(color: kategori == "Zihinsel" ? _sysPurple : _sysText.withValues(alpha: 0.3)),
                          onSelected: (_) => setDialogState(() => kategori = "Zihinsel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('CANCEL', style: TextStyle(color: _sysText, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (adCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _sablonlar[_seciliSablonIndex].egzersizler.add(
                          Egzersiz(
                            ad: adCtrl.text.trim(),
                            setTekrar: setCtrl.text.trim().isEmpty ? "3x12" : setCtrl.text.trim(),
                            youtubeArama: ytCtrl.text.trim().isEmpty ? adCtrl.text.trim() : ytCtrl.text.trim(),
                            kategori: kategori,
                          ),
                        );
                      });
                      _kaydet();
                      AudioSystem.playSuccess();
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sysBlue.withValues(alpha: 0.15),
                    side: const BorderSide(color: _sysBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text('ADD QUEST', style: GoogleFonts.orbitron(color: _sysBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Set/Tekrar Düzenle Diyalogu ───
  void _setDegistirDialog(int egzersizIndex) {
    final egz = _sablonlar[_seciliSablonIndex].egzersizler[egzersizIndex];
    final ctrl = TextEditingController(text: egz.setTekrar);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E17),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: _sysGold, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text(
            '[ MODIFY QUEST ]',
            style: GoogleFonts.orbitron(color: _sysGold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(egz.ad, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _dialogInput(ctrl, 'Sets x Reps', Icons.repeat),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: TextStyle(color: _sysText, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() {
                    _sablonlar[_seciliSablonIndex].egzersizler[egzersizIndex].setTekrar = ctrl.text.trim();
                  });
                  _kaydet();
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sysGold.withValues(alpha: 0.15),
                side: const BorderSide(color: _sysGold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('SAVE', style: GoogleFonts.orbitron(color: _sysGold, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ─── Silme Onayı ───
  void _egzersizSilOnay(int egzersizIndex) {
    final egz = _sablonlar[_seciliSablonIndex].egzersizler[egzersizIndex];
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E17),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: _sysRed, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text('[ DELETE QUEST ]', style: GoogleFonts.orbitron(color: _sysRed, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Text(
            'Remove "${egz.ad}" from this template?',
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: TextStyle(color: _sysText, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _sablonlar[_seciliSablonIndex].egzersizler.removeAt(egzersizIndex);
                });
                _kaydet();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sysRed.withValues(alpha: 0.15),
                side: const BorderSide(color: _sysRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('DELETE', style: GoogleFonts.orbitron(color: _sysRed, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  // ANA BUILD
  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sablon = _sablonlar[_seciliSablonIndex];

    return Scaffold(
      backgroundColor: _sysDarkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _sysBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'W O R K O U T   L A B',
          style: GoogleFonts.orbitron(color: _sysBlue, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
        ),
        actions: [
          // Düzenleme Modu Toggle
          IconButton(
            icon: Icon(
              _duzenlemeModu ? Icons.edit_off : Icons.edit,
              color: _duzenlemeModu ? _sysRed : _sysText,
              size: 22,
            ),
            tooltip: _duzenlemeModu ? 'Exit Edit Mode' : 'Edit Program',
            onPressed: () {
              setState(() => _duzenlemeModu = !_duzenlemeModu);
              if (!_duzenlemeModu) _kaydet();
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ──────────────────────────────────
          // 1. ŞABLON SEÇİCİ (Yatay Scroll)
          // ──────────────────────────────────
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _sablonlar.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _sablonKartiWidget(index),
                );
              },
            ),
          ),
          const SizedBox(height: 15),

          // ──────────────────────────────────
          // 2. SEÇİLİ ŞABLON BAŞLIK
          // ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HologramCard(
              neonRenk: sablon.renk,
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(sablon.ikon, color: sablon.renk, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sablon.ad, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(sablon.aciklama, style: GoogleFonts.rajdhani(color: _sysText, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  _zorlukBadge(sablon.zorluk, sablon.renk),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Düzenleme modu bilgi bandı
          if (_duzenlemeModu)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: _sysRed.withValues(alpha: 0.08),
                border: Border.all(color: _sysRed.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: _sysRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'EDIT MODE: Tap reps to modify, swipe left to delete, use + to add.',
                      style: GoogleFonts.rajdhani(color: _sysRed, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sablonuSifirla,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: _sysRed.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('RESET', style: TextStyle(color: _sysRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),

          // Egzersiz sayacı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'EXERCISES',
                  style: GoogleFonts.orbitron(color: _sysText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: sablon.renk.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: sablon.renk.withValues(alpha: 0.3)),
                  ),
                  child: Text('${sablon.egzersizler.length}', style: GoogleFonts.orbitron(color: sablon.renk, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // ──────────────────────────────────
          // 3. EGZERSİZ LİSTESİ
          // ──────────────────────────────────
          Expanded(
            child: sablon.egzersizler.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center, color: _sysText.withValues(alpha: 0.3), size: 50),
                        const SizedBox(height: 10),
                        Text('No exercises in this template.', style: TextStyle(color: _sysText)),
                        if (_duzenlemeModu) ...[
                          const SizedBox(height: 10),
                          Text('Tap + to add a quest.', style: TextStyle(color: sablon.renk, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sablon.egzersizler.length,
                    itemBuilder: (context, index) {
                      return _egzersizSatiriWidget(index, sablon.egzersizler[index], sablon.renk);
                    },
                  ),
          ),
        ],
      ),

      // ─── FAB: Egzersiz Ekle (Düzenleme Modunda) ───
      floatingActionButton: _duzenlemeModu
          ? FloatingActionButton(
              onPressed: _egzersizEkleDialog,
              backgroundColor: _sysBlue.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: _sysBlue, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, color: _sysBlue, size: 28),
            )
          : null,
    );
  }

  // ══════════════════════════════════════════════
  // YARDIMCI WİDGET'LAR
  // ══════════════════════════════════════════════

  // ─── Şablon Kartı ───
  Widget _sablonKartiWidget(int index) {
    final s = _sablonlar[index];
    bool secili = _seciliSablonIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _seciliSablonIndex = index);
        AudioSystem.playTransition();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: secili ? s.renk.withValues(alpha: 0.1) : const Color(0xFF070B14).withValues(alpha: 0.85),
          border: Border.all(
            color: secili ? s.renk : _sysText.withValues(alpha: 0.15),
            width: secili ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: secili
              ? [BoxShadow(color: s.renk.withValues(alpha: 0.15), blurRadius: 15, spreadRadius: 1)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(s.ikon, color: secili ? s.renk : _sysText.withValues(alpha: 0.5), size: 32),
            const SizedBox(height: 10),
            Text(
              s.ad,
              style: GoogleFonts.rajdhani(
                color: secili ? Colors.white : _sysText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _zorlukBadge(s.zorluk, secili ? s.renk : _sysText.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  // ─── Zorluk Badge ───
  Widget _zorlukBadge(String zorluk, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.1),
        border: Border.all(color: renk.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        zorluk,
        style: GoogleFonts.orbitron(color: renk, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  // ─── Egzersiz Satırı ───
  Widget _egzersizSatiriWidget(int index, Egzersiz egz, Color vurguRenk) {
    bool fiziksel = egz.kategori == "Fiziksel";

    return Dismissible(
      key: ValueKey('${_seciliSablonIndex}_${egz.ad}_$index'),
      direction: _duzenlemeModu ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _sysRed.withValues(alpha: 0.15),
          border: Border.all(color: _sysRed.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.delete_forever, color: _sysRed, size: 28),
      ),
      confirmDismiss: (direction) async {
        _egzersizSilOnay(index);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF070B14).withValues(alpha: 0.85),
          border: Border.all(color: vurguRenk.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Sıra numarası
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: vurguRenk.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: GoogleFonts.orbitron(color: vurguRenk, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),

            // Egzersiz Adı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    egz.ad,
                    style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fiziksel ? '[PHY]' : '[MNT]',
                    style: TextStyle(color: fiziksel ? _sysBlue.withValues(alpha: 0.5) : _sysPurple.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),

            // Set/Tekrar (düzenleme modunda tıklanabilir)
            GestureDetector(
              onTap: _duzenlemeModu ? () => _setDegistirDialog(index) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _duzenlemeModu ? _sysGold.withValues(alpha: 0.1) : vurguRenk.withValues(alpha: 0.06),
                  border: Border.all(color: _duzenlemeModu ? _sysGold.withValues(alpha: 0.5) : vurguRenk.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_duzenlemeModu)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.edit, color: _sysGold, size: 12),
                      ),
                    Text(
                      egz.setTekrar,
                      style: GoogleFonts.orbitron(
                        color: _duzenlemeModu ? _sysGold : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // YouTube İkonu
            GestureDetector(
              onTap: () => _youtubeAc(egz.youtubeArama.isNotEmpty ? egz.youtubeArama : egz.ad),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _sysRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _sysRed.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.play_circle_fill, color: _sysRed, size: 20),
              ),
            ),

            // Sil butonu (düzenleme modunda)
            if (_duzenlemeModu) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _egzersizSilOnay(index),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _sysRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.close, color: _sysRed, size: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Diyalog Input ───
  Widget _dialogInput(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _sysText),
        prefixIcon: Icon(icon, color: _sysBlue, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _sysBlue.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _sysBlue),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // HAZIR ANTRENMAN ŞABLONLARI (VARSAYILAN)
  // ══════════════════════════════════════════════
  List<_AntrenmanSablonu> _varsayilanSablonlar() {
    return [
      // ─── 1. SAITAMA HELL ───
      _AntrenmanSablonu(
        ad: "Saitama Hell",
        aciklama: "The training that broke all limits. No rest days.",
        zorluk: "S-RANK",
        ikon: Icons.whatshot,
        renk: _sysRed,
        egzersizler: [
          Egzersiz(ad: "Push-Ups", setTekrar: "100", youtubeArama: "100 push ups challenge proper form", kategori: "Fiziksel"),
          Egzersiz(ad: "Sit-Ups", setTekrar: "100", youtubeArama: "100 sit ups workout proper form", kategori: "Fiziksel"),
          Egzersiz(ad: "Squats", setTekrar: "100", youtubeArama: "100 bodyweight squats challenge", kategori: "Fiziksel"),
          Egzersiz(ad: "Running", setTekrar: "10 KM", youtubeArama: "how to run 10km beginners guide", kategori: "Fiziksel"),
        ],
      ),

      // ─── 2. PUSH / PULL / LEGS ───
      _AntrenmanSablonu(
        ad: "Push / Pull / Legs",
        aciklama: "The golden standard split for balanced hypertrophy.",
        zorluk: "A-RANK",
        ikon: Icons.fitness_center,
        renk: _sysBlue,
        egzersizler: [
          // PUSH
          Egzersiz(ad: "Bench Press", setTekrar: "4x8", youtubeArama: "bench press form tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Overhead Press", setTekrar: "3x10", youtubeArama: "overhead press tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Incline DB Press", setTekrar: "3x12", youtubeArama: "incline dumbbell press form", kategori: "Fiziksel"),
          Egzersiz(ad: "Cable Flyes", setTekrar: "3x15", youtubeArama: "cable fly chest exercise", kategori: "Fiziksel"),
          Egzersiz(ad: "Tricep Pushdown", setTekrar: "3x12", youtubeArama: "tricep pushdown form", kategori: "Fiziksel"),
          Egzersiz(ad: "Lateral Raises", setTekrar: "3x15", youtubeArama: "lateral raise proper form", kategori: "Fiziksel"),
          // PULL
          Egzersiz(ad: "Deadlift", setTekrar: "4x6", youtubeArama: "deadlift form tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Pull-Ups", setTekrar: "4xMAX", youtubeArama: "pull up tutorial beginners", kategori: "Fiziksel"),
          Egzersiz(ad: "Barbell Row", setTekrar: "3x10", youtubeArama: "barbell row form tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Face Pulls", setTekrar: "3x15", youtubeArama: "face pull exercise form", kategori: "Fiziksel"),
          Egzersiz(ad: "Barbell Curl", setTekrar: "3x12", youtubeArama: "barbell curl form", kategori: "Fiziksel"),
          Egzersiz(ad: "Hammer Curl", setTekrar: "3x12", youtubeArama: "hammer curl tutorial", kategori: "Fiziksel"),
          // LEGS
          Egzersiz(ad: "Barbell Squat", setTekrar: "4x8", youtubeArama: "barbell squat form tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Leg Press", setTekrar: "3x12", youtubeArama: "leg press proper form", kategori: "Fiziksel"),
          Egzersiz(ad: "Romanian Deadlift", setTekrar: "3x10", youtubeArama: "romanian deadlift tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Leg Curl", setTekrar: "3x12", youtubeArama: "leg curl machine form", kategori: "Fiziksel"),
          Egzersiz(ad: "Calf Raises", setTekrar: "4x15", youtubeArama: "calf raise exercise", kategori: "Fiziksel"),
          Egzersiz(ad: "Walking Lunges", setTekrar: "3x12", youtubeArama: "walking lunges form", kategori: "Fiziksel"),
        ],
      ),

      // ─── 3. CALISTHENICS ───
      _AntrenmanSablonu(
        ad: "Calisthenics",
        aciklama: "Master your own body. No equipment needed.",
        zorluk: "B-RANK",
        ikon: Icons.self_improvement,
        renk: _sysGreen,
        egzersizler: [
          Egzersiz(ad: "Push-Up Variations", setTekrar: "4x15", youtubeArama: "push up variations workout", kategori: "Fiziksel"),
          Egzersiz(ad: "Pull-Up Variations", setTekrar: "4xMAX", youtubeArama: "pull up variations tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Dips (Parallel Bar)", setTekrar: "3x12", youtubeArama: "parallel bar dips form", kategori: "Fiziksel"),
          Egzersiz(ad: "Pistol Squat", setTekrar: "3x8", youtubeArama: "pistol squat progression tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "L-Sit Hold", setTekrar: "3x20s", youtubeArama: "l sit hold tutorial beginners", kategori: "Fiziksel"),
          Egzersiz(ad: "Muscle-Up Practice", setTekrar: "5x3", youtubeArama: "muscle up tutorial step by step", kategori: "Fiziksel"),
          Egzersiz(ad: "Handstand Hold", setTekrar: "3x30s", youtubeArama: "handstand tutorial beginners", kategori: "Fiziksel"),
          Egzersiz(ad: "Planche Progression", setTekrar: "3x10s", youtubeArama: "planche progression guide", kategori: "Fiziksel"),
        ],
      ),

      // ─── 4. FULL BODY WARRIOR ───
      _AntrenmanSablonu(
        ad: "Full Body Warrior",
        aciklama: "Hit every muscle group in a single devastating session.",
        zorluk: "B-RANK",
        ikon: Icons.shield,
        renk: _sysGold,
        egzersizler: [
          Egzersiz(ad: "Squat", setTekrar: "4x10", youtubeArama: "squat proper form", kategori: "Fiziksel"),
          Egzersiz(ad: "Bench Press", setTekrar: "4x10", youtubeArama: "bench press form", kategori: "Fiziksel"),
          Egzersiz(ad: "Deadlift", setTekrar: "3x8", youtubeArama: "deadlift form for beginners", kategori: "Fiziksel"),
          Egzersiz(ad: "Pull-Ups", setTekrar: "3xMAX", youtubeArama: "pull up form tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Shoulder Press", setTekrar: "3x10", youtubeArama: "shoulder press dumbbell form", kategori: "Fiziksel"),
          Egzersiz(ad: "Barbell Curl", setTekrar: "3x12", youtubeArama: "barbell curl form", kategori: "Fiziksel"),
          Egzersiz(ad: "Plank", setTekrar: "3x60s", youtubeArama: "plank exercise form", kategori: "Fiziksel"),
          Egzersiz(ad: "Farmer's Walk", setTekrar: "3x40m", youtubeArama: "farmers walk exercise", kategori: "Fiziksel"),
        ],
      ),

      // ─── 5. SHADOW TRAINING (CARDIO) ───
      _AntrenmanSablonu(
        ad: "Shadow Training",
        aciklama: "Pure cardio annihilation. Burn fat like a furnace.",
        zorluk: "A-RANK",
        ikon: Icons.directions_run,
        renk: _sysPurple,
        egzersizler: [
          Egzersiz(ad: "HIIT Sprints", setTekrar: "10x30s", youtubeArama: "hiit sprint workout tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Jump Rope", setTekrar: "3x5min", youtubeArama: "jump rope workout beginners", kategori: "Fiziksel"),
          Egzersiz(ad: "Burpees", setTekrar: "5x20", youtubeArama: "burpee exercise proper form", kategori: "Fiziksel"),
          Egzersiz(ad: "Mountain Climbers", setTekrar: "4x30", youtubeArama: "mountain climbers exercise form", kategori: "Fiziksel"),
          Egzersiz(ad: "Box Jumps", setTekrar: "4x12", youtubeArama: "box jump tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Battle Ropes", setTekrar: "3x45s", youtubeArama: "battle ropes workout tutorial", kategori: "Fiziksel"),
          Egzersiz(ad: "Shuttle Run", setTekrar: "8x20m", youtubeArama: "shuttle run exercise", kategori: "Fiziksel"),
        ],
      ),

      // ─── 6. MIND & RECOVERY ───
      _AntrenmanSablonu(
        ad: "Mind & Recovery",
        aciklama: "Mental training and active recovery for the wise hunter.",
        zorluk: "C-RANK",
        ikon: Icons.psychology,
        renk: const Color(0xFF06B6D4),
        egzersizler: [
          Egzersiz(ad: "Guided Meditation", setTekrar: "15 min", youtubeArama: "guided meditation for focus", kategori: "Zihinsel"),
          Egzersiz(ad: "Deep Stretching", setTekrar: "20 min", youtubeArama: "full body deep stretch routine", kategori: "Fiziksel"),
          Egzersiz(ad: "Breathing Exercise (Box)", setTekrar: "5x4-4-4-4", youtubeArama: "box breathing technique tutorial", kategori: "Zihinsel"),
          Egzersiz(ad: "Yoga Flow", setTekrar: "30 min", youtubeArama: "yoga flow routine for athletes", kategori: "Fiziksel"),
          Egzersiz(ad: "Foam Rolling", setTekrar: "15 min", youtubeArama: "foam rolling routine full body", kategori: "Fiziksel"),
          Egzersiz(ad: "Cold Exposure Prep", setTekrar: "3 min", youtubeArama: "cold shower benefits and how to", kategori: "Zihinsel"),
        ],
      ),
    ];
  }
}

// ══════════════════════════════════════════════
// YARDIMCI VERİ SINIFI (Ekran İçi)
// ══════════════════════════════════════════════
class _AntrenmanSablonu {
  final String ad;
  final String aciklama;
  final String zorluk;
  final IconData ikon;
  final Color renk;
  List<Egzersiz> egzersizler;

  _AntrenmanSablonu({
    required this.ad,
    required this.aciklama,
    required this.zorluk,
    required this.ikon,
    required this.renk,
    required this.egzersizler,
  });
}
