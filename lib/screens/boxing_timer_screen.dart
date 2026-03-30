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

class _BoxingTimerScreenState extends State<BoxingTimerScreen> {
  static const Color systemBlue = Color(0xFF38BDF8); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color deepBlack = Color(0xFF030712); 
  static const Color cardBg = Color(0xFF0F172A); 
  static const Color systemRed = Color(0xFFEF4444);
  static const Color systemRest = Color(0xFF94A3B8); 

  String anaMod = 'System Courses'; 
  String sistemTuru = 'Running (Speed)'; 
  
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

  @override
  void initState() {
    super.initState();
    _parkuruOlustur(); 
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
      if (sistemTuru == 'Jump Rope') {
        if (rank == 'E-Rank (Rookie)') {
          parkur.add(EgitimFazi("Warm-up", 60, systemRest, "Jump at a slow pace"));
          parkur.add(EgitimFazi("Workout", 180, systemBlue, "Moderate pace"));
          parkur.add(EgitimFazi("Rest", 60, systemRest, "Drop the rope, breathe"));
          parkur.add(EgitimFazi("Cooldown", 180, systemBlue, "Moderate pace"));
        } else if (rank == 'C-Rank (Elite)') {
          for(int i=0; i<3; i++) {
            parkur.add(EgitimFazi("Fast Pace", 180, systemRed, "Speed up! No stopping."));
            parkur.add(EgitimFazi("Active Rest", 60, systemBlue, "Jump slowly to rest."));
          }
        } else {
          parkur.add(EgitimFazi("Hell", 900, physicalGold, "15 Minutes Non-stop!")); 
        }
      } 
      else if (sistemTuru == 'Running (Speed)') {
        if (rank == 'E-Rank (Rookie)') {
          parkur.add(EgitimFazi("Walk", 120, systemRest, "Speed 4-5. Brisk walk."));
          parkur.add(EgitimFazi("Jog", 180, systemBlue, "Speed 7-8. Get used to it."));
          parkur.add(EgitimFazi("Cooldown", 120, systemRest, "Speed 4. Walk and breathe."));
        } else if (rank == 'C-Rank (Elite)') {
          parkur.add(EgitimFazi("Walk", 120, systemRest, "Speed 5. Prepare."));
          for(int i=0; i<3; i++) {
            parkur.add(EgitimFazi("Run", 120, systemBlue, "Speed 8-9. Stable run."));
            parkur.add(EgitimFazi("SPRINT", 60, systemRed, "SPEED 12+! RUN FROM SHADOWS!"));
            parkur.add(EgitimFazi("Walk", 60, systemRest, "Speed 4. Breathe."));
          }
        } else {
          parkur.add(EgitimFazi("Warm-up", 120, systemRest, "Speed 5."));
          for(int i=0; i<5; i++) {
            parkur.add(EgitimFazi("Death Run", 180, physicalGold, "Speed 10. Endurance Test."));
            parkur.add(EgitimFazi("SPRINT", 60, systemRed, "MAX SPEED!"));
          }
          parkur.add(EgitimFazi("Cooldown", 120, systemRest, "Speed 3. You survived."));
        }
      }
      else if (sistemTuru == 'Running (Incline)') {
        if (rank == 'E-Rank (Rookie)') {
          parkur.add(EgitimFazi("Flat Road", 120, systemRest, "Speed 5, Incline 0."));
          parkur.add(EgitimFazi("Slight Hill", 180, systemBlue, "Speed 5, Incline 5%."));
          parkur.add(EgitimFazi("Flat Road", 120, systemRest, "Reset incline."));
        } else if (rank == 'C-Rank (Elite)') {
          parkur.add(EgitimFazi("Flat Road", 120, systemRest, "Speed 5, Incline 0."));
          parkur.add(EgitimFazi("Hill", 120, systemBlue, "Speed 5, Incline 8%."));
          parkur.add(EgitimFazi("Mountain Climb", 120, physicalGold, "Speed 4.5, Incline 12%!"));
          parkur.add(EgitimFazi("Descent", 120, systemRest, "Reset incline."));
          parkur.add(EgitimFazi("Final Peak", 120, systemRed, "Speed 5, Incline 15%!"));
        } else {
          parkur.add(EgitimFazi("Warm-up", 60, systemRest, "Short warm-up."));
          for(int i=0; i<4; i++) {
            parkur.add(EgitimFazi("Mountain Base", 120, systemBlue, "Incline 10%, Speed 5."));
            parkur.add(EgitimFazi("DUNGEON PEAK", 120, systemRed, "INCLINE 15% (MAX)."));
          }
        }
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
        if (kalanSaniye > 0) { setState(() => kalanSaniye--); } else {
          AudioSystem.playBell(); 
          aktifFazIndex++;
          if (aktifFazIndex < parkur.length) {
            setState(() { kalanSaniye = parkur[aktifFazIndex].sureSaniye; });
          } else {
            _timer?.cancel();
            setState(() { calisiyor = false; });
            AudioSystem.playSuccess(); 
            _antrenmanBittiDialog();
          }
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
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    EgitimFazi? aktifFaz = parkur.isNotEmpty ? parkur[aktifFazIndex] : null;
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
                      // RANK GÖSTERGESİ
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
                      if (anaMod == 'System Courses') 
                        DropdownButtonFormField<String>(
                          value: sistemTuru, dropdownColor: cardBg, decoration: InputDecoration(labelText: 'Workout Type', labelStyle: const TextStyle(color: physicalGold), filled: true, fillColor: const Color(0xFF0F172A), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: physicalGold.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: physicalGold), borderRadius: BorderRadius.circular(4))),
                          style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold),
                          items: ['Jump Rope', 'Running (Speed)', 'Running (Incline)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) { setState(() { sistemTuru = val!; _parkuruOlustur(); }); },
                        ),
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