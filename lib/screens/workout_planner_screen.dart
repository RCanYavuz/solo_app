// lib/screens/workout_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../widgets/hologram_card.dart'; 

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({super.key});
  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  static const Color systemBlue = Color(0xFF389EFF); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color mentalPurple = Color(0xFFA060E0); 
  static const Color deepBlack = Colors.black; 
  static const Color cardBg = Color(0xFF0D0D0D); 
  static const Color systemRed = Color(0xFFD32F2F); 

  int seciliGun = 1; 
  String secilenTip = 'Fiziksel'; 
  
  // FİZİKSEL KATEGORİLER
  String secilenBolge = 'Göğüs';
  final List<String> bolgeler = [
    'Göğüs', 'Sırt', 'Omuz', 'Ön Kol (Biceps)', 'Arka Kol (Triceps)', 
    'Ön Bacak (Quads)', 'Arka Bacak (Hamstrings)', 'Kalf', 'Karın', 'Kardiyo (Dayanıklılık)'
  ];

  // YENİ: ZİHİNSEL KATEGORİLER
  String secilenZihinBolge = 'Kitap Okuma (Bilgi)';
  final List<String> zihinBolgeler = [
    'Kitap Okuma (Bilgi)', 'Meditasyon (Odak)', 'Dil Öğrenimi', 'Strateji / Satranç', 'Ders / Çalışma'
  ];

  final TextEditingController hareketKontrolcusu = TextEditingController();
  final Map<int, String> gunIsimleri = { 1: "Pazartesi", 2: "Salı", 3: "Çarşamba", 4: "Perşembe", 5: "Cuma", 6: "Cumartesi", 7: "Pazar" };

  void hareketEkle() {
    if (hareketKontrolcusu.text.isNotEmpty) {
      // YENİ: Seçilen tipe göre doğru etiketi yapıştır.
      String finalAd = secilenTip == 'Fiziksel' 
          ? "[$secilenBolge] ${hareketKontrolcusu.text}" 
          : "[$secilenZihinBolge] ${hareketKontrolcusu.text}";

      setState(() {
        SystemMemory.haftalikPlan[seciliGun]!.add(Gorev(finalAd, false, secilenTip));
        hareketKontrolcusu.clear();
      });
      SystemMemory.kaydet();
    }
  }

  void hareketSil(int index) {
    setState(() { SystemMemory.haftalikPlan[seciliGun]!.removeAt(index); });
    SystemMemory.kaydet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepBlack, 
      appBar: AppBar(
        title: Text('SİSTEM GÖREV PLANLAYICI', style: GoogleFonts.orbitron(color: systemBlue, fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFF050A10), 
        elevation: 0
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            HologramCard(
              neonRenk: systemBlue, 
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15), 
                    decoration: BoxDecoration(color: const Color(0xFF101820), border: Border.all(color: systemBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: seciliGun, dropdownColor: cardBg, isExpanded: true, 
                        icon: const Icon(Icons.arrow_drop_down, color: systemBlue),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        items: gunIsimleri.entries.map((e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value))).toList(),
                        onChanged: (yeni) => setState(() => seciliGun = yeni!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text('Fiziksel (STR/AGI)'), selected: secilenTip == 'Fiziksel',
                        selectedColor: systemBlue.withOpacity(0.15), labelStyle: TextStyle(color: secilenTip == 'Fiziksel' ? systemBlue : Colors.white38, fontWeight: FontWeight.bold),
                        backgroundColor: cardBg, onSelected: (val) => setState(() => secilenTip = 'Fiziksel'),
                      ),
                      ChoiceChip(
                        label: const Text('Zihinsel (INT/PER)'), selected: secilenTip == 'Zihinsel',
                        selectedColor: mentalPurple.withOpacity(0.15), labelStyle: TextStyle(color: secilenTip == 'Zihinsel' ? mentalPurple : Colors.white38, fontWeight: FontWeight.bold),
                        backgroundColor: cardBg, onSelected: (val) => setState(() => secilenTip = 'Zihinsel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            HologramCard(
              neonRenk: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple,
              child: Column(
                children: [
                  // FİZİKSEL MENÜ
                  if (secilenTip == 'Fiziksel') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15), 
                      decoration: BoxDecoration(color: const Color(0xFF101820), border: Border.all(color: physicalGold.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: secilenBolge, dropdownColor: cardBg, isExpanded: true, 
                          icon: const Icon(Icons.fitness_center, color: physicalGold), 
                          style: const TextStyle(color: physicalGold, fontSize: 16, fontWeight: FontWeight.bold),
                          items: bolgeler.map((b) => DropdownMenuItem<String>(value: b, child: Text(b))).toList(),
                          onChanged: (yeni) => setState(() => secilenBolge = yeni!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // YENİ: ZİHİNSEL MENÜ
                  if (secilenTip == 'Zihinsel') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15), 
                      decoration: BoxDecoration(color: const Color(0xFF101820), border: Border.all(color: mentalPurple.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: secilenZihinBolge, dropdownColor: cardBg, isExpanded: true, 
                          icon: const Icon(Icons.psychology, color: mentalPurple), 
                          style: const TextStyle(color: mentalPurple, fontSize: 16, fontWeight: FontWeight.bold),
                          items: zihinBolgeler.map((b) => DropdownMenuItem<String>(value: b, child: Text(b))).toList(),
                          onChanged: (yeni) => setState(() => secilenZihinBolge = yeni!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hareketKontrolcusu, style: const TextStyle(color: Colors.white), 
                          decoration: InputDecoration(
                            hintText: secilenTip == 'Fiziksel' ? 'Hareket Adı (Örn: Bench Press)' : 'Örn: 20 Sayfa', 
                            hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF0A0F14), 
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold.withOpacity(0.3) : mentalPurple.withOpacity(0.3))), 
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple))
                          )
                        )
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(color: secilenTip == 'Fiziksel' ? physicalGold.withOpacity(0.15) : mentalPurple.withOpacity(0.15), border: Border.all(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), borderRadius: BorderRadius.circular(5)), 
                        child: IconButton(icon: Icon(Icons.add, color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), onPressed: hareketEkle)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: SystemMemory.haftalikPlan[seciliGun]!.length,
                itemBuilder: (context, index) {
                  Gorev gorev = SystemMemory.haftalikPlan[seciliGun]![index];
                  bool fizikselMi = gorev.tip == 'Fiziksel';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: cardBg, border: Border.all(color: fizikselMi ? systemBlue.withOpacity(0.15) : mentalPurple.withOpacity(0.15)), borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: Icon(fizikselMi ? Icons.fitness_center : Icons.psychology, color: fizikselMi ? physicalGold : mentalPurple),
                      title: Text(gorev.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: systemRed), onPressed: () => hareketSil(index)),
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