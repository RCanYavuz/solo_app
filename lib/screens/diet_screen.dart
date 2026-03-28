import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart'; // Yeni adres
import '../models/food_model.dart';         // Yeni adres
import '../widgets/hologram_card.dart';     // Kendi modülümüz

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
    bool sinirAsildi = SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text('SİSTEM: DİYET (ENVANTER)', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)), backgroundColor: const Color(0xFF0A0E17), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Tarih: $bugununTarihi", style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            const Text("Tüketilen besinleri giriniz:", style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 20),

            // Kalori Göstergesi Hologramı
            HologramCard(
              neonRenk: sinirAsildi ? Colors.redAccent : Colors.amberAccent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(sinirAsildi ? Icons.warning_amber_rounded : Icons.local_fire_department, color: sinirAsildi ? Colors.redAccent : Colors.amberAccent, size: 30),
                      const SizedBox(width: 10),
                      Text('GÜNLÜK KALORİ: ${SystemMemory.bugunAlinanKalori} / ${SystemMemory.gunlukHedefKalori}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: sinirAsildi ? Colors.redAccent : Colors.amberAccent)),
                    ],
                  ),
                  if (sinirAsildi) const Padding(padding: EdgeInsets.only(top: 10), child: Text("SİSTEM UYARISI: KALORİ SINIRI AŞILDI! GÜN SONU HP CEZASI UYGULANACAK.", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(flex: 2, child: TextField(controller: adKontrolcusu, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Yemek Adı (Örn: Yulaf)', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: const Color(0xFF1F2937), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent))))),
                const SizedBox(width: 10),
                Expanded(flex: 1, child: TextField(controller: kaloriKontrolcusu, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Kcal', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: const Color(0xFF1F2937), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent))))),
                const SizedBox(width: 10),
                Container(decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.2), border: Border.all(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(5)), child: IconButton(icon: const Icon(Icons.add, color: Colors.cyanAccent), onPressed: yemekEkle)),
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                itemCount: SystemMemory.bugununYemekleri.length,
                itemBuilder: (context, index) {
                  return HologramCard(
                    neonRenk: Colors.white12,
                    padding: const EdgeInsets.all(5),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.amberAccent),
                      title: Text(SystemMemory.bugununYemekleri[index].ad, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text('${SystemMemory.bugununYemekleri[index].kalori} kcal', style: const TextStyle(color: Colors.cyanAccent)),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => yemekSil(index)),
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