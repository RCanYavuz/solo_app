// lib/screens/diet_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart'; 
import '../models/food_model.dart';
import '../widgets/hologram_card.dart';

class YemekEkrani extends StatefulWidget {
  const YemekEkrani({super.key});
  @override
  State<YemekEkrani> createState() => _YemekEkraniState();
}

class _YemekEkraniState extends State<YemekEkrani> {
  final TextEditingController adKontrolcusu = TextEditingController();
  final TextEditingController kaloriKontrolcusu = TextEditingController();

  void yemekEkle() {
    if (adKontrolcusu.text.isNotEmpty && kaloriKontrolcusu.text.isNotEmpty) {
      setState(() {
        int girilenKalori = int.tryParse(kaloriKontrolcusu.text) ?? 0;
        // HATA BURADAYDI, DÜZELTİLDİ! (ad: ve kalori: etiketleri kaldırıldı)
        SystemMemory.bugununYemekleri.add(TuketilenYemek(adKontrolcusu.text, girilenKalori));
        SystemMemory.bugunAlinanKalori += girilenKalori;
        adKontrolcusu.clear(); kaloriKontrolcusu.clear();
      });
      SystemMemory.kaydet();
    }
  }

  void yemekSil(int index) {
    setState(() {
      SystemMemory.bugunAlinanKalori -= SystemMemory.bugununYemekleri[index].kalori;
      SystemMemory.bugununYemekleri.removeAt(index);
    });
    SystemMemory.kaydet();
  }

  String get bugununTarihi {
    DateTime bugun = DateTime.now();
    return "${bugun.day.toString().padLeft(2, '0')}.${bugun.month.toString().padLeft(2, '0')}.${bugun.year}";
  }

  @override
  Widget build(BuildContext context) {
    // --- ORİJİNAL SİSTEM RENKLERİ ---
    const Color sysBlue = Color(0xFF38BDF8); 
    const Color sysDarkBg = Color(0xFF030712); 
    const Color sysRed = Color(0xFFEF4444); 
    const Color sysTextMuted = Color(0xFF94A3B8); 

    bool sinirAsildi = SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori;

    return Scaffold(
      backgroundColor: sysDarkBg, 
      appBar: AppBar(
        title: Text('I N V E N T O R Y', style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Text("DATE: $bugununTarihi", style: GoogleFonts.orbitron(color: sysTextMuted, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 5),
            const Text("Log consumed items:", style: TextStyle(color: sysTextMuted, fontSize: 12)),
            const SizedBox(height: 20),

            HologramCard(
              neonRenk: sinirAsildi ? sysRed : sysBlue,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(sinirAsildi ? Icons.warning_amber_rounded : Icons.local_fire_department, color: sinirAsildi ? sysRed : Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Text('CALORIES: ${SystemMemory.bugunAlinanKalori} / ${SystemMemory.gunlukHedefKalori}', style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: sinirAsildi ? sysRed : Colors.white)),
                    ],
                  ),
                  if (sinirAsildi) 
                    const Padding(
                      padding: EdgeInsets.only(top: 10), 
                      child: Text("WARNING: LIMIT EXCEEDED. PENALTY WILL BE APPLIED.", style: TextStyle(color: sysRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))
                    )
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: adKontrolcusu,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Item Name', hintStyle: TextStyle(color: sysTextMuted.withOpacity(0.5)),
                      filled: true, fillColor: const Color(0xFF0F172A),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)), 
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysBlue), borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: kaloriKontrolcusu, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Kcal', hintStyle: TextStyle(color: sysTextMuted.withOpacity(0.5)),
                      filled: true, fillColor: const Color(0xFF0F172A),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysBlue), borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: sysBlue.withOpacity(0.1), border: Border.all(color: sysBlue), borderRadius: BorderRadius.circular(4)),
                  child: IconButton(icon: const Icon(Icons.add, color: sysBlue), onPressed: yemekEkle),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                itemCount: SystemMemory.bugununYemekleri.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B14).withOpacity(0.85),
                      border: Border.all(color: Colors.white12, width: 0.5), 
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: sysTextMuted, size: 20),
                      title: Text(SystemMemory.bugununYemekleri[index].ad, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${SystemMemory.bugununYemekleri[index].kalori} kcal', style: const TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          IconButton(icon: const Icon(Icons.close, color: sysRed, size: 18), onPressed: () => yemekSil(index)),
                        ],
                      )
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}