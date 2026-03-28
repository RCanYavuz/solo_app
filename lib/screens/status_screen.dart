import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart'; 
import '../models/task_model.dart';
import '../core/sistem_gecisi.dart'; 
import '../core/audio_system.dart';  

// KENDİ ÜRETTİĞİMİZ MODÜLLER
import '../widgets/hologram_card.dart';
import '../widgets/stat_bar.dart';

import 'workout_planner_screen.dart'; 
import 'boxing_timer_screen.dart'; 

class StatusWindow extends StatefulWidget {
  const StatusWindow({super.key});
  @override
  State<StatusWindow> createState() => _StatusWindowState();
}

class _StatusWindowState extends State<StatusWindow> {

  void _gunuBitirVeYargila() {
    String rapor = SystemMemory.gunSonuHesaplasmasi();
    AudioSystem.playSuccess();
    
    showDialog(
      context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        bool cezaVarMi = rapor.contains("[CEZA]"); 
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E17),
          shape: RoundedRectangleBorder(side: BorderSide(color: cezaVarMi ? Colors.redAccent : Colors.cyanAccent, width: 2), borderRadius: BorderRadius.circular(15)),
          title: Text(cezaVarMi ? '[ SİSTEM UYARISI ]' : '[ GÜNLÜK GÖREV TAMAMLANDI ]', style: GoogleFonts.orbitron(color: cezaVarMi ? Colors.redAccent : Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          content: Text(rapor, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2, height: 1.5)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: cezaVarMi ? Colors.red[900]!.withOpacity(0.3) : Colors.cyan[900]!.withOpacity(0.3), side: BorderSide(color: cezaVarMi ? Colors.redAccent : Colors.cyanAccent)),
              onPressed: () { Navigator.pop(context); setState(() {}); },
              child: Text('ONAYLA', style: TextStyle(color: cezaVarMi ? Colors.redAccent : Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int bugunIndex = DateTime.now().weekday;
    List<Gorev> bugununProgrami = SystemMemory.haftalikPlan[bugunIndex]!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('SİSTEM: DURUM', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)), 
        backgroundColor: const Color(0xFF0A0E17), elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.sports_mma, color: Colors.redAccent, size: 28), tooltip: 'Savaş Simülasyonu', onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const BoxingTimerScreen()))),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: AnimatedBuilder(
          animation: Listenable.merge([SystemMemory.hp, SystemMemory.mp, SystemMemory.fatigue, SystemMemory.level, SystemMemory.exp, SystemMemory.ap, SystemMemory.str, SystemMemory.agi, SystemMemory.vit, SystemMemory.intStat, SystemMemory.per]),
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 0. LEVEL VE EXP BARI ---
                Row(
                  children: [
                    Text('LEVEL: ${SystemMemory.level.value}', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EXP', style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                          Container(
                            height: 8, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.amberAccent, width: 1), borderRadius: BorderRadius.circular(5)),
                            child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: (SystemMemory.exp.value / SystemMemory.maxExp.value).clamp(0.0, 1.0), child: Container(decoration: BoxDecoration(color: Colors.amberAccent, borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: Colors.amberAccent.withOpacity(0.8), blurRadius: 10)]))),
                          ),
                          Align(alignment: Alignment.centerRight, child: Text('${SystemMemory.exp.value} / ${SystemMemory.maxExp.value}', style: const TextStyle(color: Colors.white54, fontSize: 10))),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),

                // --- 1. HP / MP KUTUSU (Yeni Hologram ve StatBar ile 5 satıra düştü!) ---
                HologramCard(
                  neonRenk: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(child: StatBar(label: 'HP', icon: Icons.add_box, color: Colors.cyanAccent, current: SystemMemory.hp.value, max: SystemMemory.maxHp)),
                      const SizedBox(width: 20),
                      Expanded(child: StatBar(label: 'MP', icon: Icons.science, color: Colors.blueAccent, current: SystemMemory.mp.value, max: SystemMemory.maxMp)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 2. STATÜ GRID KUTUSU ---
                HologramCard(
                  neonRenk: Colors.purpleAccent,
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_StatRow(Icons.fitness_center, 'STR', SystemMemory.str.value), _StatRow(Icons.favorite, 'VIT', SystemMemory.vit.value)]),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_StatRow(Icons.directions_run, 'AGI', SystemMemory.agi.value), _StatRow(Icons.psychology, 'INT', SystemMemory.intStat.value)]),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _StatRow(Icons.visibility, 'PER', SystemMemory.per.value),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('Available Pts:', textAlign: TextAlign.right, style: TextStyle(color: SystemMemory.ap.value > 0 ? Colors.amberAccent : Colors.white54, fontSize: 12)), 
                          Text('${SystemMemory.ap.value}', style: GoogleFonts.orbitron(color: SystemMemory.ap.value > 0 ? Colors.amberAccent : Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold))
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
                    Text('SİSTEM GÖREVLERİ', style: GoogleFonts.orbitron(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.edit_calendar, color: Colors.cyanAccent), onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const WorkoutPlannerScreen())).then((value) => setState((){})) )
                  ],
                ),
                const SizedBox(height: 10),
                
                if (bugununProgrami.isEmpty)
                  HologramCard(neonRenk: Colors.greenAccent, child: const Center(child: Text("BUGÜN DİNLENME GÜNÜ. Sistem görev beklemiyor.", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center))),
                
                if (bugununProgrami.isNotEmpty)
                  HologramCard(
                    neonRenk: Colors.white12, padding: EdgeInsets.zero,
                    child: Column(
                      children: bugununProgrami.map((gorev) {
                        bool fizikselMi = gorev.tip == "Fiziksel";
                        return CheckboxListTile(
                          secondary: Icon(fizikselMi ? Icons.fitness_center : Icons.psychology, color: fizikselMi ? Colors.cyanAccent : Colors.purpleAccent),
                          title: Text(gorev.ad, style: TextStyle(color: gorev.yapildiMi ? Colors.white38 : Colors.white, decoration: gorev.yapildiMi ? TextDecoration.lineThrough : null)),
                          value: gorev.yapildiMi, activeColor: fizikselMi ? Colors.cyanAccent : Colors.purpleAccent, checkColor: Colors.black,
                          onChanged: (val) { setState((){ gorev.yapildiMi = val!; }); SystemMemory.kaydet(); },
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),

                // --- 4. TEMEL İHTİYAÇLAR (Uyku) ---
                Text('SABİT İHTİYAÇLAR', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                HologramCard(
                  neonRenk: Colors.white12, padding: EdgeInsets.zero,
                  child: ListTile(
                    title: const Text('Uyunan Süre (Saat)', style: TextStyle(color: Colors.white)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.cyanAccent), onPressed: () { if(SystemMemory.uyunanSaat>0) { setState(() => SystemMemory.uyunanSaat--); SystemMemory.kaydet(); } }),
                      Text('${SystemMemory.uyunanSaat}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent), onPressed: () { setState(() => SystemMemory.uyunanSaat++); SystemMemory.kaydet(); }),
                    ]),
                  ),
                ),
                const SizedBox(height: 30),

                // --- GÜNÜ BİTİR BUTONU ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _gunuBitirVeYargila,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900]!.withOpacity(0.8), padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: Colors.redAccent, width: 2), shadowColor: Colors.redAccent, elevation: 10,
                    ),
                    child: const Text('GÜNÜ BİTİR (YARGILAMA)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _StatRow(IconData icon, String label, int value) {
    bool canUpgrade = SystemMemory.ap.value > 0;
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 22), const SizedBox(width: 8),
          Text('$label:', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(),
          Text('$value', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 22)),
          if (canUpgrade) ...[
            const SizedBox(width: 5),
            GestureDetector(onTap: () { SystemMemory.statuYukselt(label); setState((){}); }, child: const Icon(Icons.add_box, color: Colors.amberAccent, size: 20))
          ]
        ],
      ),
    );
  }
}