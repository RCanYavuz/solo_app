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
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color mentalPurple = Color(0xFFA060E0); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color cardBg = Color(0xFF0F172A); 
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysTextMuted = Color(0xFF94A3B8);

  int seciliGun = 1; 
  String secilenTip = 'Fiziksel'; // Backend için hala 'Fiziksel' tutuyoruz, UI'da 'Physical' yazacak.
  
  // FİZİKSEL BÖLGELER (İNGİLİZCE)
  String secilenBolge = 'Chest';
  final List<String> bolgeler = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 
    'Quads', 'Hamstrings', 'Calves', 'Core / Abs', 'Cardio'
  ];

  // ZİHİNSEL BÖLGELER (İNGİLİZCE)
  String secilenZihinBolge = 'Reading';
  final List<String> zihinBolgeler = [
    'Reading', 'Meditation', 'Language', 'Strategy', 'Studying'
  ];

  final TextEditingController hareketKontrolcusu = TextEditingController();
  final Map<int, String> gunIsimleri = { 
    1: "MONDAY", 2: "TUESDAY", 3: "WEDNESDAY", 4: "THURSDAY", 5: "FRIDAY", 6: "SATURDAY", 7: "SUNDAY" 
  };

  void hareketEkle() {
    if (hareketKontrolcusu.text.isNotEmpty) {
      String finalAd = secilenTip == 'Fiziksel' 
          ? "[${secilenBolge.toUpperCase()}] ${hareketKontrolcusu.text}" 
          : "[${secilenZihinBolge.toUpperCase()}] ${hareketKontrolcusu.text}";

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

  // YENİ: GÖRSEL VÜCUT / ZİHİN SEÇİCİ (VISUAL SELECTOR)
  Widget _buildVisualSelector(List<String> items, String currentSelection, Function(String) onSelect, Color themeColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        bool isSelected = currentSelection == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? themeColor.withOpacity(0.2) : Colors.transparent,
              border: Border.all(color: isSelected ? themeColor : Colors.white12, width: 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isSelected ? [BoxShadow(color: themeColor.withOpacity(0.2), blurRadius: 8)] : [],
            ),
            child: Text(
              item.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: isSelected ? themeColor : sysTextMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg, 
      appBar: AppBar(
        title: Text('Q U E S T   P L A N N E R', style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: sysBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            HologramCard(
              neonRenk: sysBlue, 
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15), 
                    decoration: BoxDecoration(color: cardBg, border: Border.all(color: sysBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: seciliGun, dropdownColor: cardBg, isExpanded: true, 
                        icon: const Icon(Icons.arrow_drop_down, color: sysBlue),
                        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
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
                        label: const Text('PHYSICAL (STR/AGI)'), selected: secilenTip == 'Fiziksel',
                        selectedColor: physicalGold.withOpacity(0.2), 
                        labelStyle: GoogleFonts.orbitron(color: secilenTip == 'Fiziksel' ? physicalGold : sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold),
                        backgroundColor: cardBg, side: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold : Colors.white12),
                        onSelected: (val) => setState(() => secilenTip = 'Fiziksel'),
                      ),
                      ChoiceChip(
                        label: const Text('MENTAL (INT/PER)'), selected: secilenTip == 'Zihinsel',
                        selectedColor: mentalPurple.withOpacity(0.2), 
                        labelStyle: GoogleFonts.orbitron(color: secilenTip == 'Zihinsel' ? mentalPurple : sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold),
                        backgroundColor: cardBg, side: BorderSide(color: secilenTip == 'Zihinsel' ? mentalPurple : Colors.white12),
                        onSelected: (val) => setState(() => secilenTip = 'Zihinsel'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(secilenTip == 'Fiziksel' ? Icons.accessibility_new : Icons.psychology, color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple, size: 20),
                      const SizedBox(width: 10),
                      Text("TARGET AREA", style: GoogleFonts.orbitron(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // GÖRSEL SEÇİCİ BURADA ÇAĞRILIYOR
                  if (secilenTip == 'Fiziksel')
                    _buildVisualSelector(bolgeler, secilenBolge, (val) => setState(() => secilenBolge = val), physicalGold)
                  else
                    _buildVisualSelector(zihinBolgeler, secilenZihinBolge, (val) => setState(() => secilenZihinBolge = val), mentalPurple),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hareketKontrolcusu, style: const TextStyle(color: Colors.white, fontSize: 14), 
                          decoration: InputDecoration(
                            hintText: 'Quest Name (e.g. 50 Push-ups)', 
                            hintStyle: const TextStyle(color: sysTextMuted), filled: true, fillColor: const Color(0xFF070B14), 
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold.withOpacity(0.3) : mentalPurple.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)), 
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), borderRadius: BorderRadius.circular(4))
                          )
                        )
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(color: secilenTip == 'Fiziksel' ? physicalGold.withOpacity(0.15) : mentalPurple.withOpacity(0.15), border: Border.all(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), borderRadius: BorderRadius.circular(4)), 
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
                    decoration: BoxDecoration(color: const Color(0xFF070B14).withOpacity(0.85), border: Border.all(color: fizikselMi ? physicalGold.withOpacity(0.3) : mentalPurple.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                      leading: Icon(fizikselMi ? Icons.fitness_center : Icons.psychology, color: fizikselMi ? physicalGold : mentalPurple, size: 20),
                      title: Text(gorev.ad, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      trailing: IconButton(icon: const Icon(Icons.close, color: sysRed, size: 18), onPressed: () => hareketSil(index)),
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