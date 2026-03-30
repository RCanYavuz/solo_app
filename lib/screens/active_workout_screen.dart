// lib/screens/active_workout_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../core/sistem_gecisi.dart'; 
import 'boxing_timer_screen.dart'; 

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712);
  static const Color spotifyGreen = Color(0xFF1DB954);

  int gecenSaniye = 0;
  Timer? _kronometre;
  int bugunIndex = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    // Ekrana girer girmez kronometre başlar
    _kronometre = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        gecenSaniye++;
      });
    });
  }

  @override
  void dispose() {
    _kronometre?.cancel();
    super.dispose();
  }

  String _sureFormatla(int toplamSaniye) {
    int saat = toplamSaniye ~/ 3600;
    int dakika = (toplamSaniye % 3600) ~/ 60;
    int saniye = toplamSaniye % 60;
    
    String strSaat = saat.toString().padLeft(2, '0');
    String strDakika = dakika.toString().padLeft(2, '0');
    String strSaniye = saniye.toString().padLeft(2, '0');

    if (saat > 0) return "$strSaat:$strDakika:$strSaniye";
    return "$strDakika:$strSaniye";
  }

  void _zindandanCik() {
    _kronometre?.cancel();
    
    // Sistem Hafızasına işleyip raporu alıyoruz
    String rapor = SystemMemory.zindanAkiniBitir(gecenSaniye);
    
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF030712).withOpacity(0.95),
        shape: RoundedRectangleBorder(side: const BorderSide(color: sysBlue, width: 1), borderRadius: BorderRadius.circular(4)),
        title: Text('[ DUNGEON CLEARED ]', style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold)),
        content: Text(rapor, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [ 
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: sysBlue.withOpacity(0.2), side: const BorderSide(color: sysBlue)), 
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat
              Navigator.pop(context); // Zindan ekranından çık
            }, 
            child: const Text('CONFIRM', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold))
          ) 
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Gorev> bugununProgrami = SystemMemory.haftalikPlan[bugunIndex]!;

    return Scaffold(
      backgroundColor: sysDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ÜST BÖLÜM: KRONOMETRE VE ARAÇLAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                border: const Border(bottom: BorderSide(color: sysRed, width: 2)),
                boxShadow: [BoxShadow(color: sysRed.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)]
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sol Üst: Spotify Butonu
                  Positioned(
                    top: 0,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.queue_music, color: spotifyGreen, size: 28),
                      tooltip: 'Spotify',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('SYSTEM: Audio Interface connecting...'),
                          backgroundColor: sysBlue, duration: Duration(seconds: 2),
                        ));
                      },
                    ),
                  ),
                  
                  // Sağ Üst: Savaş Simülatörü Butonu
                  Positioned(
                    top: 0,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.sports_mma, color: sysRed, size: 28),
                      tooltip: 'Combat Sim',
                      onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const BoxingTimerScreen())),
                    ),
                  ),

                  // Orta: Kronometre
                  Column(
                    children: [
                      Text('ACTIVE RAID', style: GoogleFonts.orbitron(color: sysRed, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4)),
                      const SizedBox(height: 10),
                      Text(
                        _sureFormatla(gecenSaniye),
                        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold, shadows: [Shadow(color: sysRed.withOpacity(0.8), blurRadius: 20)]),
                      ),
                      const SizedBox(height: 5),
                      const Text('Dungeon Timer Running...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            // ORTA BÖLÜM: BUGÜNÜN GÖREVLERİ
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('ACTIVE QUESTS', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  if (bugununProgrami.isEmpty)
                    const Center(child: Text("No quests assigned for today.", style: TextStyle(color: Color(0xFF94A3B8)))),
                  
                  ...bugununProgrami.map((gorev) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B14).withOpacity(0.85),
                        border: Border.all(color: sysBlue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: CheckboxListTile(
                        title: Text(gorev.ad, style: TextStyle(color: gorev.yapildiMi ? const Color(0xFF94A3B8) : Colors.white, fontSize: 14, decoration: gorev.yapildiMi ? TextDecoration.lineThrough : null)),
                        subtitle: Text(gorev.tip == "Fiziksel" ? '[PHY]' : '[MNT]', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        value: gorev.yapildiMi,
                        activeColor: sysBlue, checkColor: sysDarkBg,
                        onChanged: (val) { 
                          setState(() { gorev.yapildiMi = val!; }); 
                          SystemMemory.kaydet(); 
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ALT BÖLÜM: ÇIKIŞ BUTONU
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _zindandanCik,
                  icon: const Icon(Icons.exit_to_app, color: sysRed),
                  label: const Text('EXIT DUNGEON', style: TextStyle(color: sysRed, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysRed.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: sysRed, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}