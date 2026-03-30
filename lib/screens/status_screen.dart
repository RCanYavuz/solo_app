// lib/screens/status_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart'; 
import '../models/task_model.dart';
import '../core/sistem_gecisi.dart'; 
import '../core/audio_system.dart';  

import 'workout_planner_screen.dart'; 
import 'boxing_timer_screen.dart'; 

class StatusWindow extends StatefulWidget {
  const StatusWindow({super.key});
  @override
  State<StatusWindow> createState() => _StatusWindowState();
}

class _StatusWindowState extends State<StatusWindow> {

  // Not: Buton kaldırıldı ancak ileride otomatik gece sıfırlaması (Cron Job) 
  // eklenebileceği için algoritma (beyin) kodun içinde yedekte tutuluyor.
  void _gunuBitirVeYargila() {
    String rapor = SystemMemory.gunSonuHesaplasmasi();
    AudioSystem.playSuccess();
    
    showDialog(
      context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        bool cezaVarMi = rapor.contains("[PENALTY]"); 
        const Color sysBlue = Color(0xFF38BDF8);
        const Color sysRed = Color(0xFFEF4444);
        Color dialogColor = cezaVarMi ? sysRed : sysBlue;

        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withOpacity(0.95),
          shape: RoundedRectangleBorder(side: BorderSide(color: dialogColor, width: 1), borderRadius: BorderRadius.circular(4)),
          title: Text(cezaVarMi ? '[ SYSTEM WARNING ]' : '[ DAILY QUEST COMPLETED ]', style: GoogleFonts.orbitron(color: dialogColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          content: Text(rapor, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2, height: 1.5)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: dialogColor.withOpacity(0.1), side: BorderSide(color: dialogColor)),
              onPressed: () { Navigator.pop(context); setState(() {}); },
              child: Text('CONFIRM', style: TextStyle(color: dialogColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sysBlue = Color(0xFF38BDF8); 
    const Color sysDarkBg = Color(0xFF030712); 
    const Color sysRed = Color(0xFFEF4444); 
    const Color sysTextMuted = Color(0xFF94A3B8); 
    const Color spotifyGreen = Color(0xFF1DB954); // YENİ: Spotify Yeşili (Sistem tonuna uyumlu)

    int bugunIndex = DateTime.now().weekday;
    List<Gorev> bugununProgrami = SystemMemory.haftalikPlan[bugunIndex]!;

    return Scaffold(
      backgroundColor: sysDarkBg,
      appBar: AppBar(
        title: Text('S T A T U S', style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        actions: [
          // --- YENİ: SPOTIFY (MÜZİK) BUTONU ---
          IconButton(
            icon: const Icon(Icons.queue_music, color: spotifyGreen, size: 28),
            tooltip: 'Audio Interface (Spotify)',
            onPressed: () {
              // İleride buraya url_launcher paketi ile direkt "spotify://" linki bağlanabilir.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('SYSTEM: Audio Interface connecting...'),
                backgroundColor: sysBlue, duration: Duration(seconds: 2),
              ));
            },
          ),
          // --- SAVAŞ SİMÜLASYONU BUTONU ---
          IconButton(
            icon: const Icon(Icons.sports_mma, color: sysRed, size: 28),
            tooltip: 'Combat Simulation',
            onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const BoxingTimerScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: AnimatedBuilder(
          animation: Listenable.merge([SystemMemory.hp, SystemMemory.mp, SystemMemory.fatigue, SystemMemory.level, SystemMemory.exp, SystemMemory.ap, SystemMemory.str, SystemMemory.agi, SystemMemory.vit, SystemMemory.intStat, SystemMemory.per]),
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 0. LEVEL VE EXP BARI ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${SystemMemory.level.value}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1)),
                    const SizedBox(width: 10),
                    const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('LEVEL', style: TextStyle(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2))),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EXP', style: GoogleFonts.rajdhani(color: sysTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          Container(
                            height: 6, width: double.infinity,
                            decoration: BoxDecoration(border: Border.all(color: sysBlue.withOpacity(0.5), width: 1), borderRadius: BorderRadius.circular(2)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft, widthFactor: (SystemMemory.exp.value / SystemMemory.maxExp.value).clamp(0.0, 1.0),
                              child: Container(decoration: BoxDecoration(color: sysBlue, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: sysBlue.withOpacity(0.5), blurRadius: 5)])),
                            ),
                          ),
                          Align(alignment: Alignment.centerRight, child: Text('${SystemMemory.exp.value} / ${SystemMemory.maxExp.value}', style: const TextStyle(color: sysTextMuted, fontSize: 10))),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // --- 1. HP / MP KUTUSU ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(color: const Color(0xFF070B14).withOpacity(0.85), border: Border.all(color: sysBlue.withOpacity(0.4), width: 1), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Column(children: [const Icon(Icons.add_box, color: Colors.white, size: 24), Text('HP', style: GoogleFonts.rajdhani(color: sysTextMuted, fontWeight: FontWeight.bold, fontSize: 14))]),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Container(height: 8, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: sysBlue.withOpacity(0.5), width: 1), borderRadius: BorderRadius.circular(2)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: (SystemMemory.hp.value / SystemMemory.maxHp).clamp(0.0, 1.0), child: Container(decoration: BoxDecoration(color: sysBlue, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: sysBlue.withOpacity(0.5), blurRadius: 5)])))),
                        const SizedBox(height: 5), Text('${SystemMemory.hp.value}/${SystemMemory.maxHp}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ])),
                      const SizedBox(width: 20),
                      Column(children: [const Icon(Icons.science, color: Colors.white, size: 24), Text('MP', style: GoogleFonts.rajdhani(color: sysTextMuted, fontWeight: FontWeight.bold, fontSize: 14))]),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Container(height: 8, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: sysBlue.withOpacity(0.5), width: 1), borderRadius: BorderRadius.circular(2)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: (SystemMemory.mp.value / SystemMemory.maxMp).clamp(0.0, 1.0), child: Container(decoration: BoxDecoration(color: sysBlue, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: sysBlue.withOpacity(0.5), blurRadius: 5)])))),
                        const SizedBox(height: 5), Text('${SystemMemory.mp.value}/${SystemMemory.maxMp}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ])),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 2. STATÜ GRID KUTUSU ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF070B14).withOpacity(0.85), border: Border.all(color: sysBlue.withOpacity(0.4), width: 1), borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_StatRow(Icons.fitness_center, 'STR', SystemMemory.str.value, sysBlue), _StatRow(Icons.favorite, 'VIT', SystemMemory.vit.value, sysBlue)]),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_StatRow(Icons.directions_run, 'AGI', SystemMemory.agi.value, sysBlue), _StatRow(Icons.psychology, 'INT', SystemMemory.intStat.value, sysBlue)]),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _StatRow(Icons.visibility, 'PER', SystemMemory.per.value, sysBlue),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('Available Pts:', textAlign: TextAlign.right, style: TextStyle(color: sysTextMuted, fontSize: 10, letterSpacing: 1)), 
                          Text('${SystemMemory.ap.value}', style: GoogleFonts.orbitron(color: SystemMemory.ap.value > 0 ? sysBlue : sysTextMuted, fontSize: 24, fontWeight: FontWeight.bold))
                        ])
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- 3. GÜNLÜK GÖREV PANOSU ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('QUESTS', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    IconButton(icon: const Icon(Icons.edit_square, color: sysBlue, size: 20), onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const WorkoutPlannerScreen())).then((value) => setState((){})) )
                  ],
                ),
                const SizedBox(height: 10),
                
                Container(
                  decoration: BoxDecoration(border: Border.all(color: sysBlue.withOpacity(0.4), width: 1), borderRadius: BorderRadius.circular(4), color: const Color(0xFF070B14).withOpacity(0.85)),
                  child: bugununProgrami.isEmpty
                    ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No quests today.", style: TextStyle(color: sysTextMuted))))
                    : Column(
                        children: bugununProgrami.map<Widget>((gorev) { 
                          return Container(
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5))),
                            child: CheckboxListTile(
                              secondary: Icon(gorev.tip == "Fiziksel" ? Icons.fitness_center : Icons.psychology, color: sysTextMuted, size: 18),
                              title: Text(gorev.ad, style: TextStyle(color: gorev.yapildiMi ? sysTextMuted : Colors.white, fontSize: 14, decoration: gorev.yapildiMi ? TextDecoration.lineThrough : null)),
                              value: gorev.yapildiMi, activeColor: sysBlue, checkColor: sysDarkBg,
                              onChanged: (val) { setState((){ gorev.yapildiMi = val!; }); SystemMemory.kaydet(); },
                            ),
                          );
                        }).toList(),
                      ),
                ),
                const SizedBox(height: 20),

                // --- 4. TEMEL İHTİYAÇLAR (Uyku) ---
                Text('REQUIREMENTS', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: sysBlue.withOpacity(0.4), width: 1), borderRadius: BorderRadius.circular(4), color: const Color(0xFF070B14).withOpacity(0.85)),
                  child: ListTile(
                    title: const Text('Sleep Duration (Hrs)', style: TextStyle(color: sysTextMuted, fontSize: 14)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.remove, color: sysBlue), onPressed: () { if(SystemMemory.uyunanSaat>0) { setState(() => SystemMemory.uyunanSaat--); SystemMemory.kaydet(); } }),
                      Text('${SystemMemory.uyunanSaat}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add, color: sysBlue), onPressed: () { setState(() => SystemMemory.uyunanSaat++); SystemMemory.kaydet(); }),
                    ]),
                  ),
                ),
                // ESKİ "GÜNÜ BİTİR" BUTONU BURADAN KALDIRILDI.
                const SizedBox(height: 40), // Alt boşluk bırakıldı
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _StatRow(IconData icon, String label, int value, Color sysBlue) {
    bool canUpgrade = SystemMemory.ap.value > 0;
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          Icon(icon, color: sysBlue, size: 16), const SizedBox(width: 8),
          Text('$label:', style: GoogleFonts.rajdhani(color: const Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.bold)), const Spacer(),
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          if (canUpgrade) ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () { SystemMemory.statuYukselt(label); setState((){}); }, 
              child: Container(
                padding: const EdgeInsets.all(2), 
                decoration: BoxDecoration(color: sysBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(2)), 
                child: Icon(Icons.add, color: sysBlue, size: 14) 
              )
            )
          ]
        ],
      ),
    );
  }
}