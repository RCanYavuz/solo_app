// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'active_workout_screen.dart';
import '../controllers/system_memory.dart'; 
import '../models/task_model.dart';
import '../widgets/hologram_card.dart';
import '../core/sistem_gecisi.dart'; 
import 'shop_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  String _unvanBelirle(int level) {
    if (level < 5) return "Rookie Hunter (E-Rank)"; 
    if (level < 10) return "Experienced Hunter (C-Rank)";
    if (level < 20) return "Elite Hunter (B-Rank)"; 
    if (level < 50) return "National Level Hunter (A-Rank)";
    return "Shadow Monarch (S-Rank)";
  }

  // --- YENİ: DİNAMİK BAŞARIM HESAPLAMA MOTORU ---
  // Mevcut değere bakarak sıradaki hedefi ve Roma rakamı seviyesini belirler.
  Map<String, dynamic> _kademeHesapla(int mevcut, List<int> hedefler) {
    for (int i = 0; i < hedefler.length; i++) {
      if (mevcut < hedefler[i]) {
        return {'hedef': hedefler[i], 'kademe': i};
      }
    }
    // Tüm hedefler aşıldıysa son hedefte kal ve %100 parlasın
    return {'hedef': hedefler.last, 'kademe': hedefler.length - 1}; 
  }

  // Başarımların yanına eklenecek havalı Roma rakamları (I, II, III...)
  String _romaRakam(int index) {
    const roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (index >= 0 && index < roman.length) return roman[index];
    return "MAX";
  }

  @override
  Widget build(BuildContext context) {
    const Color sysBlue = Color(0xFF38BDF8); 
    const Color sysDarkBg = Color(0xFF030712); 
    const Color sysRed = Color(0xFFEF4444); 
    const Color sysTextMuted = Color(0xFF94A3B8); 

    int bugun = DateTime.now().weekday;
    List<Gorev> bugununGorevleri = SystemMemory.haftalikPlan[bugun]!;
    
    DateTime simdi = DateTime.now();
    List<Map<String, dynamic>> bugununIdmanlari = SystemMemory.idmanGecmisi.where((idman) {
      DateTime idmanTarihi = DateTime.parse(idman['tarih']);
      return idmanTarihi.year == simdi.year && idmanTarihi.month == simdi.month && idmanTarihi.day == simdi.day;
    }).toList();

    double kaloriYuzdesi = 0;
    if (SystemMemory.gunlukHedefKalori > 0) {
      kaloriYuzdesi = SystemMemory.bugunAlinanKalori / SystemMemory.gunlukHedefKalori;
      if (kaloriYuzdesi > 1.0) kaloriYuzdesi = 1.0; 
    }
    bool kaloriAsildi = SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori;

    SystemMemory.bossGuncelle();

    // --- BAŞARIM KADEMELERİNİ (HEDEFLERİ) BELİRLE ---
    var bStreak = _kademeHesapla(SystemMemory.streakGunSayisi, [7, 14, 30, 60, 100, 365]);
    var bGorev = _kademeHesapla(SystemMemory.bitenGorevSayisi, [50, 100, 250, 500, 1000, 5000]);
    var bLevel = _kademeHesapla(SystemMemory.level.value, [10, 20, 30, 50, 80, 100]);
    var bStr = _kademeHesapla(SystemMemory.str.value, [30, 50, 100, 150, 200, 300]);
    var bAgi = _kademeHesapla(SystemMemory.agi.value, [30, 50, 100, 150, 200, 300]);
    var bInt = _kademeHesapla(SystemMemory.intStat.value, [30, 50, 100, 150, 200, 300]);
    var bAltin = _kademeHesapla(SystemMemory.altin.value, [2000, 5000, 10000, 50000, 100000, 500000]);
    
    int kiloFarki = (SystemMemory.baslangicKilosu - SystemMemory.kilo).abs().toInt();
    var bKilo = _kademeHesapla(kiloFarki, [5, 10, 15, 20, 30, 50]);

    return Scaffold(
      backgroundColor: sysDarkBg, 
      appBar: AppBar(
        title: Text('S T A T U S', style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. OYUNCU KİMLİĞİ ---
            HologramCard(
              neonRenk: sysBlue,
              child: Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: sysBlue.withOpacity(0.5), width: 1),
                      image: SystemMemory.profilFotoByte != null ? DecorationImage(image: MemoryImage(SystemMemory.profilFotoByte!), fit: BoxFit.cover) : null,
                      color: const Color(0xFF0F172A)
                    ),
                    child: SystemMemory.profilFotoByte == null ? const Icon(Icons.person, size: 35, color: sysBlue) : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${SystemMemory.level.value}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1)),
                            const SizedBox(width: 8),
                            const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('LEVEL', style: TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2))),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('TITLE: ${_unvanBelirle(SystemMemory.level.value)}', style: GoogleFonts.rajdhani(color: sysTextMuted, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.storefront, color: sysBlue, size: 30),
                    onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const ShopScreen())),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. DURUM VE ENERJİ ---
            IntrinsicHeight( 
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HologramCard(
                      neonRenk: kaloriAsildi ? sysRed : sysBlue,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ENERGY', style: GoogleFonts.orbitron(color: sysTextMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          const SizedBox(height: 15),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70, height: 70,
                                child: CircularProgressIndicator(
                                  value: kaloriYuzdesi, strokeWidth: 4,
                                  backgroundColor: const Color(0xFF0F172A),
                                  valueColor: AlwaysStoppedAnimation<Color>(kaloriAsildi ? sysRed : sysBlue),
                                ),
                              ),
                              Text('${SystemMemory.bugunAlinanKalori}', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('${SystemMemory.gunlukHedefKalori} MAX', style: const TextStyle(color: sysTextMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: HologramCard(
                      neonRenk: sysBlue,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('PHYSICAL', style: GoogleFonts.orbitron(color: sysTextMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          const Divider(color: Colors.white12, thickness: 1),
                          _statSatiri('STR', '${SystemMemory.str.value}', sysBlue),
                          _statSatiri('INT', '${SystemMemory.intStat.value}', sysBlue),
                          _statSatiri('AGI', '${SystemMemory.agi.value}', sysBlue),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 3. BAŞARIMLAR VİTRİNİ (DİNAMİK KADEMELİ) ---
            Text('ACHIEVEMENTS', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            SizedBox(
              height: 135,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _basarimKarti("Iron Will ${_romaRakam(bStreak['kademe'])}", "${bStreak['hedef']} Day Streak", SystemMemory.streakGunSayisi, bStreak['hedef'], Icons.shield, sysBlue, sysTextMuted),
                  _basarimKarti("Unbreakable ${_romaRakam(bGorev['kademe'])}", "${bGorev['hedef']} Quests Done", SystemMemory.bitenGorevSayisi, bGorev['hedef'], Icons.hardware, sysBlue, sysTextMuted),
                  _basarimKarti("Awakening ${_romaRakam(bLevel['kademe'])}", "Level ${bLevel['hedef']}", SystemMemory.level.value, bLevel['hedef'], Icons.flash_on, sysBlue, sysTextMuted),
                  _basarimKarti("Warrior ${_romaRakam(bStr['kademe'])}", "Reach ${bStr['hedef']} STR", SystemMemory.str.value, bStr['hedef'], Icons.fitness_center, sysBlue, sysTextMuted),
                  _basarimKarti("Shadow Step ${_romaRakam(bAgi['kademe'])}", "Reach ${bAgi['hedef']} AGI", SystemMemory.agi.value, bAgi['hedef'], Icons.directions_run, sysBlue, sysTextMuted),
                  _basarimKarti("Sage ${_romaRakam(bInt['kademe'])}", "Reach ${bInt['hedef']} INT", SystemMemory.intStat.value, bInt['hedef'], Icons.psychology, sysBlue, sysTextMuted),
                  _basarimKarti("Merchant ${_romaRakam(bAltin['kademe'])}", "${bAltin['hedef']} Gold", SystemMemory.altin.value, bAltin['hedef'], Icons.monetization_on, sysBlue, sysTextMuted),
                  _basarimKarti(
                    "${SystemMemory.aktifHedef == 'Kilo Al (Kas İnşa Et)' ? 'Titan' : 'Fat Burner'} ${_romaRakam(bKilo['kademe'])}", 
                    "${bKilo['hedef']} KG Change", 
                    kiloFarki, 
                    bKilo['hedef'], 
                    Icons.monitor_weight, sysBlue, sysTextMuted
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 4. HAFTALIK BOSS (ZİNDAN KAPISI) ---
            Text('DUNGEON GATE', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            
            if (SystemMemory.bossMaxHP > 0)
              ValueListenableBuilder<int>(
                valueListenable: SystemMemory.bossHP,
                builder: (context, guncelHP, child) {
                  bool bossOldu = guncelHP <= 0;
                  Color bossRenk = bossOldu ? sysBlue : sysRed; 
                  
                  return HologramCard(
                    neonRenk: bossRenk,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(bossOldu ? Icons.check_circle : Icons.warning_amber_rounded, color: bossRenk, size: 28),
                            const SizedBox(width: 10),
                            Text(bossOldu ? 'BOSS DEFEATED' : 'WARNING: BOSS ACTIVE', style: GoogleFonts.orbitron(color: bossRenk, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Icon(SystemMemory.bossTuru == 'Fiziksel' ? Icons.pets : Icons.ac_unit, color: bossRenk.withOpacity(0.5), size: 60),
                        const SizedBox(height: 10),
                        Text(SystemMemory.bossIsim.toUpperCase(), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        Text('Weakness: ${SystemMemory.bossTuru == "Fiziksel" ? "Physical" : "Mental"} Quests', style: const TextStyle(color: sysTextMuted, fontSize: 12)),
                        const SizedBox(height: 15),
                        
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(height: 20, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4), border: Border.all(color: bossRenk.withOpacity(0.5)))),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (guncelHP / SystemMemory.bossMaxHP).clamp(0.0, 1.0),
                              child: Container(
                                height: 20, 
                                decoration: BoxDecoration(
                                  color: bossRenk.withOpacity(0.8), 
                                  borderRadius: BorderRadius.circular(4), 
                                  boxShadow: bossOldu ? [] : [BoxShadow(color: bossRenk.withOpacity(0.5), blurRadius: 10)]
                                )
                              ),
                            ),
                            Text('$guncelHP / ${SystemMemory.bossMaxHP} HP', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.black, blurRadius: 2)])),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              HologramCard(
                neonRenk: sysTextMuted.withOpacity(0.3),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.door_sliding, color: sysTextMuted.withOpacity(0.5), size: 40),
                      const SizedBox(height: 10),
                      Text('GATE IS DORMANT', style: GoogleFonts.orbitron(color: sysTextMuted, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 5),
                      const Text('The Weekly Boss will appear on Sunday.', style: TextStyle(color: sysTextMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // --- 5. GÜNLÜK GÖREVLER ---
            Text('DAILY QUESTS', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            HologramCard(
              neonRenk: sysBlue,
              padding: EdgeInsets.zero,
              child: bugununGorevleri.isEmpty 
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No active quests.", style: TextStyle(color: sysTextMuted))))
              : ListView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: bugununGorevleri.length,
                  itemBuilder: (context, index) {
                    Gorev g = bugununGorevleri[index];
                    return Container(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5))),
                      child: ListTile(
                        leading: Icon(g.yapildiMi ? Icons.check_box : Icons.check_box_outline_blank, color: g.yapildiMi ? sysBlue : sysTextMuted, size: 20),
                        title: Text(g.ad, style: TextStyle(color: g.yapildiMi ? sysTextMuted : Colors.white, fontSize: 14, decoration: g.yapildiMi ? TextDecoration.lineThrough : null)),
                        trailing: Text(g.tip == 'Fiziksel' ? '[PHY]' : '[MNT]', style: TextStyle(color: sysBlue.withOpacity(0.5), fontSize: 10)),
                      ),
                    );
                  },
                ),
            ),
            const SizedBox(height: 20),

            // --- 6. BUGÜNÜN ZİNDAN (İDMAN) KAYITLARI ---
            Text('TODAY\'S DUNGEON LOGS', style: GoogleFonts.orbitron(color: sysRed, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            HologramCard(
              neonRenk: sysRed,
              padding: EdgeInsets.zero,
              child: bugununIdmanlari.isEmpty 
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No raids completed today.", style: TextStyle(color: sysTextMuted))))
              : ListView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: bugununIdmanlari.length,
                  itemBuilder: (context, index) {
                    var idman = bugununIdmanlari[index];
                    DateTime t = DateTime.parse(idman['tarih']);
                    String saat = "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
                    return Container(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5))),
                      child: ListTile(
                        leading: const Icon(Icons.whatshot, color: sysRed, size: 24),
                        title: Text('Dungeon Raid at $saat', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text('Duration: ${idman['dakika']} Min | Quests Done: ${idman['gorevSayisi']}', style: const TextStyle(color: sysTextMuted, fontSize: 12)),
                      ),
                    );
                  },
                ),
            ),
            const SizedBox(height: 20),

            // --- 7. ZİNDANA GİRİŞ BUTONU (ACTIVE WORKOUT) ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const ActiveWorkoutScreen())).then((_) => setState((){})),
                icon: const Icon(Icons.flash_on, color: sysRed, size: 24),
                label: const Text('ENTER DUNGEON (START WORKOUT)', style: TextStyle(color: sysRed, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sysRed.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 20),
                  side: const BorderSide(color: sysRed, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  shadowColor: sysRed.withOpacity(0.5), elevation: 10
                ),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _statSatiri(String baslik, String deger, Color renk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(deger, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _basarimKarti(String baslik, String aciklama, int mevcut, int hedef, IconData ikon, Color sysBlue, Color sysTextMuted) {
    double progress = (mevcut / hedef).clamp(0.0, 1.0);
    bool tamamlandiMi = progress >= 1.0;
    Color aktifRenk = tamamlandiMi ? sysBlue : sysTextMuted.withOpacity(0.3);

    return Container(
      width: 130, // İsimler "I, II, III" ile uzayacağı için genişlik 110'dan 130'a çıkarıldı.
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withOpacity(0.85),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: aktifRenk, width: 1),
        boxShadow: tamamlandiMi ? [BoxShadow(color: sysBlue.withOpacity(0.2), blurRadius: 10)] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, color: aktifRenk, size: 30),
          const SizedBox(height: 8),
          Text(baslik, style: GoogleFonts.rajdhani(color: tamamlandiMi ? Colors.white : sysTextMuted, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(aciklama, style: TextStyle(color: sysTextMuted.withOpacity(0.8), fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(2))),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(height: 4, decoration: BoxDecoration(color: sysBlue, borderRadius: BorderRadius.circular(2), boxShadow: tamamlandiMi ? [BoxShadow(color: sysBlue, blurRadius: 4)] : [])),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${(progress * 100).toInt()}%', style: TextStyle(color: aktifRenk, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}