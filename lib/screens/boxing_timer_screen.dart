// lib/screens/boxing_timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_system.dart'; 
import '../controllers/system_memory.dart'; 

class EgitimFazi {
  final String isim;
  final int sureSaniye;
  final Color renk;
  final String talimat;
  EgitimFazi(this.isim, this.sureSaniye, this.renk, this.talimat);
}

class BoxingTimerScreen extends StatefulWidget {
  const BoxingTimerScreen({super.key});
  @override
  State<BoxingTimerScreen> createState() => _BoxingTimerScreenState();
}

// 1. YENİ: "with WidgetsBindingObserver" EKLENDİ (Sistemi Dinlemek İçin)
class _BoxingTimerScreenState extends State<BoxingTimerScreen> with WidgetsBindingObserver {
  static const Color systemBlue = Color(0xFF38BDF8); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color deepBlack = Color(0xFF030712); 
  static const Color cardBg = Color(0xFF0F172A); 
  static const Color systemRed = Color(0xFFEF4444);
  static const Color systemRest = Color(0xFF94A3B8); 

  String anaMod = 'System Courses'; 
  String sistemTuru = 'Running (Speed)'; 
  
  int sistemSuresiDakika = 30;

  String get otomatikRank {
    int lvl = SystemMemory.level.value;
    if (lvl < 5) return 'E-Rank (Rookie)';
    if (lvl < 15) return 'C-Rank (Elite)';
    return 'A-Rank (Master)';
  }

  int raundSuresiSaniye = 180; 
  int dinlenmeSuresiSaniye = 60; 
  int toplamRaund = 3;

  List<EgitimFazi> parkur = [];
  int aktifFazIndex = 0;
  int kalanSaniye = 0; 
  bool calisiyor = false;
  Timer? _timer;

  // 2. YENİ: Arka plana düşüş zamanını kaydedeceğimiz değişken
  DateTime? _arkaPlanaGidisZamani;

  @override
  void initState() {
    super.initState();
    // 3. YENİ: Gözlemciyi başlat
    WidgetsBinding.instance.addObserver(this);
    _parkuruOlustur(); 
  }

  @override
  void dispose() {
    // 4. YENİ: Gözlemciyi yok et
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel(); 
    super.dispose(); 
  }

  // 5. YENİ: ZAMAN FARKI HESAPLAYICI VE FAST-FORWARD MOTORU
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Ekran kilitlendi veya arka plana alındı
      if (calisiyor) {
        _arkaPlanaGidisZamani = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Uygulamaya geri dönüldü
      if (_arkaPlanaGidisZamani != null && calisiyor) {
        int farkSaniye = DateTime.now().difference(_arkaPlanaGidisZamani!).inSeconds;
        _zamanFarkiniUygula(farkSaniye);
        _arkaPlanaGidisZamani = null;
      }
    }
  }

  // 6. YENİ: KAYIP SANİYELERİ TÜKETEREK RAUNT ATLATMA FONKSİYONU
  void _zamanFarkiniUygula(int gecenKayiplar) {
    setState(() {
      while (gecenKayiplar > 0 && calisiyor) {
        if (gecenKayiplar >= kalanSaniye) {
          gecenKayiplar -= kalanSaniye;
          kalanSaniye = 0;
          _sonrakiFazaGec(calisiyorIkenAtla: true);
        } else {
          kalanSaniye -= gecenKayiplar;
          gecenKayiplar = 0;
        }
      }
    });
  }

  // YARDIMCI METOT: Faza Geçiş Mantığını Ayırmak İçin (Tekrarı önler)
  void _sonrakiFazaGec({bool calisiyorIkenAtla = false}) {
    aktifFazIndex++;
    if (aktifFazIndex < parkur.length) {
      kalanSaniye = parkur[aktifFazIndex].sureSaniye;
      if (!calisiyorIkenAtla) {
        AudioSystem.playBell();
      }
    } else {
      _timer?.cancel();
      calisiyor = false;
      if (!calisiyorIkenAtla) {
        AudioSystem.playSuccess();
        _antrenmanBittiDialog();
      }
    }
  }

  void _parkuruOlustur() {
    parkur.clear();
    String rank = otomatikRank; 

    if (anaMod == 'Free Settings') {
      for (int i = 0; i < toplamRaund; i++) {
        parkur.add(EgitimFazi("ROUND ${i+1}", raundSuresiSaniye, systemRed, "FIGHT/WORKOUT!"));
        if (i < toplamRaund - 1 && dinlenmeSuresiSaniye > 0) {
          parkur.add(EgitimFazi("REST", dinlenmeSuresiSaniye, systemRest, "HEAL AND BREATHE")); 
        }
      }
    } else {
      int toplamSaniye = sistemSuresiDakika * 60;
      int isinmaSaniye = (toplamSaniye * 0.1).toInt();
      if (isinmaSaniye > 300) isinmaSaniye = 300; 
      int sogumaSaniye = isinmaSaniye; 
      
      int aktifSaniye = toplamSaniye - isinmaSaniye - sogumaSaniye;

      if (sistemTuru == 'Jump Rope') {
        parkur.add(EgitimFazi("Warm-up", isinmaSaniye, systemRest, "Slow steady jump."));
        
        if (rank == 'E-Rank (Rookie)') {
          parkur.add(EgitimFazi("Steady Jump", aktifSaniye, systemBlue, "Moderate pace. Keep going."));
        } else if (rank == 'C-Rank (Elite)') {
          int turSayisi = aktifSaniye ~/ 240; 
          int kalanZaman = aktifSaniye % 240;
          for(int i=0; i<turSayisi; i++) {
            parkur.add(EgitimFazi("Fast Pace", 180, systemRed, "Speed up!"));
            parkur.add(EgitimFazi("Active Rest", 60, systemBlue, "Slow jump."));
          }
          if (kalanZaman > 0) parkur.add(EgitimFazi("Fast Pace", kalanZaman, systemRed, "Keep pushing!"));
        } else { 
          int turSayisi = aktifSaniye ~/ 360; 
          int kalanZaman = aktifSaniye % 360;
          for(int i=0; i<turSayisi; i++) {
            parkur.add(EgitimFazi("Hell Pace", 300, physicalGold, "Max Speed!"));
            parkur.add(EgitimFazi("Breathe", 60, systemRest, "Don't drop the rope."));
          }
          if (kalanZaman > 0) parkur.add(EgitimFazi("Hell Pace", kalanZaman, physicalGold, "Survive!"));
        }
        parkur.add(EgitimFazi("Cooldown", sogumaSaniye, systemRest, "Breathe and relax."));
      } 
      else if (sistemTuru == 'Running (Speed)') {
        parkur.add(EgitimFazi("Walk (Warm-up)", isinmaSaniye, systemRest, "Speed 4-5."));
        
        if (rank == 'E-Rank (Rookie)') {
          parkur.add(EgitimFazi("Jog", aktifSaniye, systemBlue, "Speed 6-7. Keep breath steady."));
        } else if (rank == 'C-Rank (Elite)') {
          int turSayisi = aktifSaniye ~/ 240; 
          int kalanZaman = aktifSaniye % 240;
          for(int i=0; i<turSayisi; i++) {
            parkur.add(EgitimFazi("Run", 120, systemBlue, "Speed 8-9."));
            parkur.add(EgitimFazi("SPRINT", 60, systemRed, "Speed 12+. RUN!"));
            parkur.add(EgitimFazi("Walk", 60, systemRest, "Speed 4-5. Recover."));
          }
          if (kalanZaman > 0) parkur.add(EgitimFazi("Run", kalanZaman, systemBlue, "Push to the end!"));
        } else { 
          int turSayisi = aktifSaniye ~/ 240; 
          int kalanZaman = aktifSaniye % 240;
          for(int i=0; i<turSayisi; i++) {
            parkur.add(EgitimFazi("Death Run", 180, physicalGold, "Speed 10+. Endurance."));
            parkur.add(EgitimFazi("MAX SPRINT", 60, systemRed, "ALL OUT! RUN FROM SHADOWS!"));
          }
          if (kalanZaman > 0) parkur.add(EgitimFazi("Death Run", kalanZaman, physicalGold, "Don't look back!"));
        }
        parkur.add(EgitimFazi("Walk (Cooldown)", sogumaSaniye, systemRest, "Speed 3-4. Recover."));
      }
      else if (sistemTuru == 'Running (Incline)') {
        parkur.add(EgitimFazi("Flat Walk", isinmaSaniye, systemRest, "Speed 5, Incline 0."));
        
        if (rank == 'E-Rank (Rookie)') {
          parkur.add(EgitimFazi("Hill Walk", aktifSaniye, systemBlue, "Speed 5, Incline 5%."));
        } else if (rank == 'C-Rank (Elite)') {
          int turSayisi = aktifSaniye ~/ 300; 
          int kalanZaman = aktifSaniye % 300;
          for(int i=0; i<turSayisi; i++) {
            parkur.add(EgitimFazi("Hill", 120, systemBlue, "Speed 5, Incline 8%."));
            parkur.add(EgitimFazi("Mountain", 120, physicalGold, "Speed 4.5, Incline 12%."));
            parkur.add(EgitimFazi("Flat Road", 60, systemRest, "Speed 5, Incline 0."));
          }
          if (kalanZaman > 0) parkur.add(EgitimFazi("Mountain", kalanZaman, physicalGold, "Keep climbing!"));
        } else { 
          int turSayisi = aktifSaniye ~/ 300; 
          int kalanZaman = aktifSaniye % 300;
          for(int i=0; i<turSayisi; i++) {
            parkur.add(EgitimFazi("Mountain Base", 180, systemBlue, "Speed 5, Incline 12%."));
            parkur.add(EgitimFazi("DUNGEON PEAK", 120, systemRed, "Speed 4, Incline 15% (MAX)."));
          }
          if (kalanZaman > 0) parkur.add(EgitimFazi("DUNGEON PEAK", kalanZaman, systemRed, "Reach the summit!"));
        }
        parkur.add(EgitimFazi("Flat Walk", sogumaSaniye, systemRest, "Incline 0. Cooldown."));
      }
    }
    
    aktifFazIndex = 0;
    if (parkur.isNotEmpty) kalanSaniye = parkur[0].sureSaniye;
  }

  void _baslatDuraklat() {
    if (calisiyor) {
      _timer?.cancel();
      setState(() => calisiyor = false);
    } else {
      if (parkur.isEmpty) return;
      setState(() => calisiyor = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (kalanSaniye > 0) { 
          setState(() => kalanSaniye--); 
        } else {
          AudioSystem.playBell();
          _sonrakiFazaGec();
        }
      });
    }
  }

  void _sifirla() { _timer?.cancel(); setState(() { calisiyor = false; _parkuruOlustur(); }); }

  void _antrenmanBittiDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: deepBlack,
        shape: RoundedRectangleBorder(side: const BorderSide(color: physicalGold), borderRadius: BorderRadius.circular(4)),
        title: Text('[ DUNGEON CLEARED ]', style: GoogleFonts.orbitron(color: physicalGold, fontWeight: FontWeight.bold)),
        content: Text("You have completed the course for your rank.\nThe System is watching.", style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [ ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: physicalGold.withOpacity(0.2), side: const BorderSide(color: physicalGold)), onPressed: () { Navigator.pop(context); _sifirla(); }, child: const Text('CONFIRM', style: TextStyle(color: physicalGold, fontWeight: FontWeight.bold))) ],
      ),
    );
  }

  String _sureFormatla(int saniye) {
    int dk = saniye ~/ 60; int sn = saniye % 60;
    return '${dk.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  Widget _ayarButonu(String baslik, String degerMetni, VoidCallback azalt, VoidCallback artir) {
    return Column(
      children: [
        Text(baslik, style: const TextStyle(color: systemRest, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline, color: systemBlue), onPressed: calisiyor ? null : azalt),
            Text(degerMetni, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle_outline, color: systemBlue), onPressed: calisiyor ? null : artir),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    EgitimFazi? aktifFaz = parkur.isNotEmpty && aktifFazIndex < parkur.length ? parkur[aktifFazIndex] : null;
    EgitimFazi? siradakiFaz = (parkur.isNotEmpty && aktifFazIndex + 1 < parkur.length) ? parkur[aktifFazIndex + 1] : null;
    Color fazRengi = aktifFaz?.renk ?? systemBlue;

    return Scaffold(
      backgroundColor: deepBlack,
      appBar: AppBar(title: Text('C O M B A T   S I M', style: GoogleFonts.rajdhani(color: systemRed, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: systemRed)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!calisiyor)
                Container(
                  margin: const EdgeInsets.all(15), padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF070B14).withOpacity(0.85), border: Border.all(color: systemRed.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield, color: systemRed, size: 20),
                          const SizedBox(width: 10),
                          Text("SYSTEM RANK: ", style: GoogleFonts.orbitron(color: systemRest, fontSize: 14)),
                          Text(otomatikRank, style: GoogleFonts.orbitron(color: systemRed, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SegmentedButton<String>(
                        segments: const [ButtonSegment(value: 'Free Settings', label: Text('FREE SETTINGS')), ButtonSegment(value: 'System Courses', label: Text('COURSES'))],
                        selected: {anaMod},
                        onSelectionChanged: (set) { setState(() { anaMod = set.first; _parkuruOlustur(); }); },
                        style: SegmentedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), selectedBackgroundColor: systemRed.withOpacity(0.2), selectedForegroundColor: systemRed, foregroundColor: systemRest),
                      ),
                      const SizedBox(height: 15),
                      
                      if (anaMod == 'System Courses') ...[
                        DropdownButtonFormField<String>(
                          value: sistemTuru, dropdownColor: cardBg, 
                          decoration: InputDecoration(labelText: 'Workout Type', labelStyle: const TextStyle(color: physicalGold), filled: true, fillColor: const Color(0xFF0F172A), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: physicalGold.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: physicalGold), borderRadius: BorderRadius.circular(4))),
                          style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold),
                          items: ['Jump Rope', 'Running (Speed)', 'Running (Incline)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) { setState(() { sistemTuru = val!; _parkuruOlustur(); }); },
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<int>(
                          value: sistemSuresiDakika, dropdownColor: cardBg, 
                          decoration: InputDecoration(labelText: 'Total Duration', labelStyle: const TextStyle(color: systemBlue), filled: true, fillColor: const Color(0xFF0F172A), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: systemBlue.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: systemBlue), borderRadius: BorderRadius.circular(4))),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: [15, 20, 30, 45, 60, 90, 120].map((e) => DropdownMenuItem(value: e, child: Text('$e Minutes'))).toList(),
                          onChanged: (val) { setState(() { sistemSuresiDakika = val!; _parkuruOlustur(); }); },
                        ),
                      ],

                      if (anaMod == 'Free Settings') 
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ayarButonu('Work', _sureFormatla(raundSuresiSaniye), () { if(raundSuresiSaniye > 15) setState(() { raundSuresiSaniye -= 30; _parkuruOlustur(); }); }, () { setState(() { raundSuresiSaniye += 30; _parkuruOlustur(); }); }),
                              const SizedBox(width: 10),
                              _ayarButonu('Rest', _sureFormatla(dinlenmeSuresiSaniye), () { if(dinlenmeSuresiSaniye > 0) setState(() { dinlenmeSuresiSaniye -= 10; _parkuruOlustur(); }); }, () { setState(() { dinlenmeSuresiSaniye += 10; _parkuruOlustur(); }); }),
                              const SizedBox(width: 10),
                              _ayarButonu('Round', toplamRaund.toString().padLeft(2, '0'), () { if(toplamRaund > 1) setState(() { toplamRaund--; _parkuruOlustur(); }); }, () { setState(() { toplamRaund++; _parkuruOlustur(); }); }),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    if (aktifFaz != null) ...[
                      Text(aktifFaz.isim.toUpperCase(), style: GoogleFonts.rajdhani(color: fazRengi, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Text("Step: ${aktifFazIndex + 1} / ${parkur.length}", style: const TextStyle(color: systemRest, fontSize: 14)),
                      const SizedBox(height: 20),
                    ],
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 240, height: 240, child: CircularProgressIndicator(value: aktifFaz != null ? (kalanSaniye / aktifFaz.sureSaniye) : 0, strokeWidth: 8, backgroundColor: cardBg, valueColor: AlwaysStoppedAnimation<Color>(fazRengi))),
                        Text(_sureFormatla(kalanSaniye), style: GoogleFonts.orbitron(color: Colors.white, fontSize: 55, fontWeight: FontWeight.bold, shadows: [Shadow(color: fazRengi.withOpacity(0.6), blurRadius: 25)])),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (aktifFaz != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: fazRengi.withOpacity(0.1), border: Border.all(color: fazRengi, width: 1), borderRadius: BorderRadius.circular(4)),
                        child: Text(aktifFaz.talimat, textAlign: TextAlign.center, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    const SizedBox(height: 15),
                    if (siradakiFaz != null) Text('Next: ${siradakiFaz.isim}', style: const TextStyle(color: systemRest, fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.refresh, color: systemRest, size: 30), onPressed: _sifirla),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: _baslatDuraklat,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: calisiyor ? physicalGold.withOpacity(0.2) : systemRed.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: calisiyor ? physicalGold : systemRed, width: 2)),
                        child: Icon(calisiyor ? Icons.pause : Icons.play_arrow, color: calisiyor ? physicalGold : systemRed, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}