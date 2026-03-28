// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../widgets/hologram_card.dart';
import '../core/sistem_gecisi.dart'; // Geçiş için
import 'shop_screen.dart'; // MARKETE GİTMEK İÇİN

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _unvanBelirle(int level) {
    if (level < 5) return "Çaylak Avcı (E-Rank)"; 
    if (level < 10) return "Deneyimli Avcı (C-Rank)";
    if (level < 20) return "Elit Avcı (B-Rank)"; 
    if (level < 50) return "Ulusal Seviye Avcı (A-Rank)";
    return "Gölgelerin Efendisi (S-Rank)";
  }

  @override
  Widget build(BuildContext context) {
    // SİSTEM RENKLERİ (Anime Karartması)
    const Color systemBlue = Color(0xFF389EFF); 
    const Color physicalGold = Color(0xFFB08D57); 
    const Color mentalPurple = Color(0xFFA060E0); 
    const Color deepBlack = Colors.black; 
    const Color systemRed = Color(0xFFD32F2F);

    int bugun = DateTime.now().weekday;
    List<Gorev> bugununGorevleri = SystemMemory.haftalikPlan[bugun]!;
    
    double kaloriYuzdesi = 0;
    if (SystemMemory.gunlukHedefKalori > 0) {
      kaloriYuzdesi = SystemMemory.bugunAlinanKalori / SystemMemory.gunlukHedefKalori;
      if (kaloriYuzdesi > 1.0) kaloriYuzdesi = 1.0; 
    }
    bool kaloriAsildi = SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori;

    return Scaffold(
      backgroundColor: deepBlack,
      appBar: AppBar(
        title: Text('ANA KARARGAH', style: GoogleFonts.orbitron(color: systemBlue, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF050A10), elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. KARŞILAMA VE KİMLİK ÖZETİ ---
            HologramCard(
              neonRenk: systemBlue,
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, border: Border.all(color: systemBlue, width: 2),
                      image: SystemMemory.profilFotoByte != null ? DecorationImage(image: MemoryImage(SystemMemory.profilFotoByte!), fit: BoxFit.cover) : null,
                      color: const Color(0xFF101820)
                    ),
                    child: SystemMemory.profilFotoByte == null ? const Icon(Icons.person, size: 35, color: systemBlue) : null,
                  ),
                  const SizedBox(width: 15),
                  // İsim ve Unvan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOŞ GELDİN, OYUNCU', style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(_unvanBelirle(SystemMemory.level.value), style: GoogleFonts.orbitron(color: physicalGold, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('Sıradaki Seviyeye: ${SystemMemory.maxExp.value - SystemMemory.exp.value} EXP', style: const TextStyle(color: systemBlue, fontSize: 12)),
                      ],
                    ),
                  ),
                  // YENİ: DÜKKAN BUTONU EKLENDİ!
                  IconButton(
                    icon: const Icon(Icons.storefront, color: physicalGold, size: 35),
                    tooltip: 'Sistem Marketi',
                    onPressed: () {
                      Navigator.push(context, SistemGecisi(sayfa: const ShopScreen()));
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. ENERJİ VE VÜCUT MERKEZİ ---
            Row(
              children: [
                // Kalori Çemberi
                Expanded(
                  child: HologramCard(
                    neonRenk: kaloriAsildi ? systemRed : physicalGold,
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('GÜNLÜK ENERJİ', style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80, height: 80,
                                child: CircularProgressIndicator(
                                  value: kaloriYuzdesi, strokeWidth: 8,
                                  backgroundColor: const Color(0xFF101820),
                                  valueColor: AlwaysStoppedAnimation<Color>(kaloriAsildi ? systemRed : physicalGold),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_fire_department, color: kaloriAsildi ? systemRed : physicalGold, size: 20),
                                  Text('${SystemMemory.bugunAlinanKalori}', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Limit: ${SystemMemory.gunlukHedefKalori}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Statüler ve Vücut
                Expanded(
                  child: HologramCard(
                    neonRenk: mentalPurple,
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      height: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('FİZİKSEL DURUM', style: GoogleFonts.orbitron(color: mentalPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                          const Divider(color: Colors.white12),
                          _statSatiri(Icons.monitor_weight, 'Kilo', '${SystemMemory.kilo} kg'),
                          _statSatiri(Icons.accessibility_new, 'Sınıf', SystemMemory.vucutSinifi),
                          const Divider(color: Colors.white12),
                          _statSatiri(Icons.fitness_center, 'Güç (STR)', '${SystemMemory.str.value}'),
                          _statSatiri(Icons.psychology, 'Zeka (INT)', '${SystemMemory.intStat.value}'),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // --- 3. BUGÜNÜN GÖREV ÖZETİ ---
            Text('BUGÜNÜN PROTOKOLÜ', style: GoogleFonts.orbitron(color: systemBlue, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            HologramCard(
              neonRenk: Colors.white24,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: bugununGorevleri.isEmpty 
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Sistem Dinlenme Modunda. Görev Yok.", style: TextStyle(color: Colors.greenAccent))))
              : ListView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: bugununGorevleri.length,
                  itemBuilder: (context, index) {
                    Gorev g = bugununGorevleri[index];
                    return ListTile(
                      leading: Icon(g.yapildiMi ? Icons.check_circle : Icons.radio_button_unchecked, color: g.yapildiMi ? Colors.greenAccent : Colors.white38),
                      title: Text(g.ad, style: TextStyle(color: g.yapildiMi ? Colors.white54 : Colors.white, decoration: g.yapildiMi ? TextDecoration.lineThrough : null)),
                      trailing: Icon(g.tip == 'Fiziksel' ? Icons.fitness_center : Icons.psychology, color: g.tip == 'Fiziksel' ? systemBlue : mentalPurple, size: 16),
                    );
                  },
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statSatiri(IconData ikon, String baslik, String deger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [Icon(ikon, color: Colors.white54, size: 14), const SizedBox(width: 5), Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
        Text(deger, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}