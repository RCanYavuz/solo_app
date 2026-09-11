// lib/screens/workout_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart'; 
import '../core/sistem_gecisi.dart';
import '../core/services/gemini_service.dart';
import 'dart:convert';
import 'workout_library_screen.dart'; 

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

  // YENİ: ÇOKLU GÜN SEÇİCİ SETİ (Varsayılan olarak bugünü seçili başlatır)
  Set<int> seciliGunler = {DateTime.now().weekday}; 

  String secilenTip = 'Fiziksel'; 
  String secilenBolge = 'Chest';
  final List<String> bolgeler = ['Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Quads', 'Hamstrings', 'Calves', 'Core / Abs', 'Cardio'];

  String secilenZihinBolge = 'Reading';
  final List<String> zihinBolgeler = ['Reading', 'Meditation', 'Language', 'Strategy', 'Studying'];

  final TextEditingController hareketKontrolcusu = TextEditingController();
  
  final Map<int, String> gunKisaIsimleri = { 1: "MON", 2: "TUE", 3: "WED", 4: "THU", 5: "FRI", 6: "SAT", 7: "SUN" };
  final Map<int, String> gunTamIsimleri = { 1: "MONDAY", 2: "TUESDAY", 3: "WEDNESDAY", 4: "THURSDAY", 5: "FRIDAY", 6: "SATURDAY", 7: "SUNDAY" };

  // --- YENİ: ÇOKLU EKLENTİ MOTORU ---
  void hareketEkle() {
    if (hareketKontrolcusu.text.isNotEmpty && seciliGunler.isNotEmpty) {
      String finalAd = secilenTip == 'Fiziksel' 
          ? "[${secilenBolge.toUpperCase()}] ${hareketKontrolcusu.text}" 
          : "[${secilenZihinBolge.toUpperCase()}] ${hareketKontrolcusu.text}";

      setState(() {
        for (int gun in seciliGunler) {
          SystemMemory.haftalikPlan[gun]!.add(Gorev(finalAd, false, secilenTip));
        }
        hareketKontrolcusu.clear();
      });
      SystemMemory.kaydet();
      AudioSystem.playTransition();
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('SYSTEM: Quest added to ${seciliGunler.length} day(s)!'),
        backgroundColor: sysBlue, duration: const Duration(seconds: 1)
      ));
    } else if (seciliGunler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SYSTEM WARNING: Select at least one day!'),
        backgroundColor: sysRed, duration: Duration(seconds: 1)
      ));
    }
  }

  void hareketSil(int gun, int index) {
    setState(() { SystemMemory.haftalikPlan[gun]!.removeAt(index); });
    SystemMemory.kaydet();
  }

  // --- FAZ 6: AI SMART TRAINER ---
  void _aiTrainerDialog() {
    TextEditingController talepCtrl = TextEditingController();
    bool yukleniyor = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: mentalPurple, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              title: Row(
                children: [
                  const Icon(Icons.psychology, color: mentalPurple, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'AI SMART TRAINER',
                    style: GoogleFonts.orbitron(color: mentalPurple, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Rank: ${SystemMemory.hunterRank} | Vücut Sınıfı: ${SystemMemory.vucutSinifi}",
                    style: const TextStyle(color: physicalGold, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sistem, istatistiklerine göre sana uygun bir idman çıkaracak. İstersen spesifik bir istek girebilirsin (Örn: Sadece dambıl ile kol).',
                    style: TextStyle(color: sysTextMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: talepCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Hunter Request (Optional)',
                      labelStyle: const TextStyle(color: sysTextMuted, fontSize: 12),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: mentalPurple.withValues(alpha: 0.5))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mentalPurple)),
                    ),
                  ),
                  if (yukleniyor) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator(color: mentalPurple)),
                    const SizedBox(height: 10),
                    const Center(child: Text("Sistem antrenmanı hesaplıyor...", style: TextStyle(color: mentalPurple, fontSize: 12))),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: yukleniyor ? null : () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mentalPurple.withValues(alpha: 0.2),
                    side: const BorderSide(color: mentalPurple),
                  ),
                  onPressed: yukleniyor ? null : () async {
                    if (seciliGunler.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen önce gün seçin (Örn: Pzt, Çar)."), backgroundColor: sysRed));
                      return;
                    }
                    setDialogState(() => yukleniyor = true);
                    AudioSystem.playTransition();
                    String? jsonCevap = await GeminiService.akilliAntrenor(
                      talepCtrl.text.trim(), 
                      SystemMemory.vucutSinifi, 
                      SystemMemory.hunterRank, 
                      SystemMemory.maxBench, 
                      SystemMemory.maxSquat, 
                      SystemMemory.maxDeadlift,
                      SystemMemory.kilo
                    );
                    setDialogState(() => yukleniyor = false);

                    if (mounted) {
                      Navigator.pop(context); // Dialogu kapat
                      if (jsonCevap != null && jsonCevap.isNotEmpty) {
                        _reviewAndEditDialog(jsonCevap);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sistem hata verdi, lütfen tekrar dene."), backgroundColor: sysRed));
                      }
                    }
                  },
                  child: const Text('GENERATE', style: TextStyle(color: mentalPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _reviewAndEditDialog(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      String planAdi = data['planAdi'] ?? "Unknown Plan";
      String sistemMesaji = data['sistemMesaji'] ?? "";
      List<dynamic> rawGorevler = data['gorevler'] ?? [];
      
      List<Map<String, String>> taslakListesi = [];
      for (var g in rawGorevler) {
        taslakListesi.add({
          "isim": g['isim'].toString(),
          "set_tekrar": g['set_tekrar'].toString(),
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: sysBlue, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(planAdi.toUpperCase(), style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                    if (sistemMesaji.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(sistemMesaji, style: const TextStyle(color: sysTextMuted, fontSize: 10, fontStyle: FontStyle.italic)),
                    ]
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount: taslakListesi.length,
                    itemBuilder: (context, index) {
                      final item = taslakListesi[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sysBlue.withValues(alpha: 0.1),
                          border: Border.all(color: sysBlue.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['isim']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(item['set_tekrar']!, style: const TextStyle(color: physicalGold, fontSize: 11)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: sysRed, size: 18),
                              onPressed: () {
                                setDialogState(() {
                                  taslakListesi.removeAt(index);
                                });
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('DISCARD', style: TextStyle(color: sysRed)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sysBlue.withValues(alpha: 0.2),
                      side: const BorderSide(color: sysBlue),
                    ),
                    onPressed: () {
                      setState(() {
                        for (int gun in seciliGunler) {
                          for (var task in taslakListesi) {
                            String finalTitle = "${task['isim']} - ${task['set_tekrar']}";
                            SystemMemory.haftalikPlan[gun]!.add(Gorev(finalTitle, false, "Fiziksel"));
                          }
                        }
                      });
                      SystemMemory.kaydet();
                      AudioSystem.playSuccess();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('SYSTEM: $planAdi applied to ${seciliGunler.length} day(s)!'),
                        backgroundColor: Colors.green
                      ));
                    },
                    child: const Text('CONFIRM & SYNC', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            }
          );
        }
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Format Hatası: $e"), backgroundColor: sysRed));
    }
  }

  // --- YENİ: SİSTEM ŞABLONLARI ---
  void _sablonUygula(String sablonAdi) {
    setState(() {
      if (sablonAdi == 'Saitama (S-Rank)') {
        for (int i = 1; i <= 7; i++) {
          SystemMemory.haftalikPlan[i]!.clear(); // Eski programı sil
          SystemMemory.haftalikPlan[i]!.addAll([
            Gorev("[CHEST] 100 Push-ups", false, "Fiziksel"),
            Gorev("[CORE / ABS] 100 Sit-ups", false, "Fiziksel"),
            Gorev("[QUADS] 100 Squats", false, "Fiziksel"),
            Gorev("[CARDIO] 10 KM Run", false, "Fiziksel"),
          ]);
        }
      } 
      else if (sablonAdi == 'Full Body (B-Rank)') {
        for (int i = 1; i <= 7; i++) {
          SystemMemory.haftalikPlan[i]!.clear();
        }
        List<int> gunler = [1, 3, 5]; // Pzt, Çarş, Cuma
        for (int g in gunler) {
          SystemMemory.haftalikPlan[g]!.addAll([
            Gorev("[CHEST] Bench / Push-ups", false, "Fiziksel"),
            Gorev("[BACK] Pull-ups / Rows", false, "Fiziksel"),
            Gorev("[QUADS] Squats", false, "Fiziksel"),
            Gorev("[CORE / ABS] Plank (3 Min)", false, "Fiziksel"),
          ]);
        }
      }
      else if (sablonAdi == 'Monarch Mind') {
        for (int i = 1; i <= 7; i++) {
          SystemMemory.haftalikPlan[i]!.clear();
          SystemMemory.haftalikPlan[i]!.addAll([
            Gorev("[MEDITATION] 30 Mins Focus", false, "Zihinsel"),
            Gorev("[READING] 20 Pages Book", false, "Zihinsel"),
            Gorev("[STRATEGY] Planning / Journal", false, "Zihinsel"),
          ]);
        }
      }
    });
    
    SystemMemory.kaydet();
    AudioSystem.playSuccess();
    Navigator.pop(context); // Dialogu kapat
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SYSTEM: $sablonAdi template applied to all week!'), backgroundColor: Colors.green));
  }

  void _sablonSecimDialog() {
    AudioSystem.playTransition();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(side: const BorderSide(color: sysBlue, width: 1), borderRadius: BorderRadius.circular(4)),
          title: Text('SYSTEM TEMPLATES', style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("WARNING: Applying a template will OVERWRITE your current weekly quests for the related days.", style: TextStyle(color: sysRed, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _sablonButonu('Saitama (S-Rank)', 'Everyday: 100 Push-ups, Squats, Sit-ups, 10km Run', physicalGold),
              const SizedBox(height: 10),
              _sablonButonu('Full Body (B-Rank)', 'Mon/Wed/Fri: Chest, Back, Legs, Core', physicalGold),
              const SizedBox(height: 10),
              _sablonButonu('Monarch Mind', 'Everyday: Meditation, Reading, Strategy', mentalPurple),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)))],
        );
      }
    );
  }

  Widget _sablonButonu(String ad, String aciklama, Color renk) {
    return InkWell(
      onTap: () => _sablonUygula(ad),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), border: Border.all(color: renk.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ad, style: GoogleFonts.orbitron(color: renk, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(aciklama, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualSelector(List<String> items, String currentSelection, Function(String) onSelect, Color themeColor) {
    return Wrap(
      spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
      children: items.map((item) {
        bool isSelected = currentSelection == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? themeColor.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: isSelected ? themeColor : Colors.white12, width: 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isSelected ? [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 8)] : [],
            ),
            child: Text(item.toUpperCase(), style: GoogleFonts.orbitron(color: isSelected ? themeColor : sysTextMuted, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, letterSpacing: 1)),
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
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: sysBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center, color: sysBlue),
            tooltip: 'Workout Library',
            onPressed: () => Navigator.push(
              context,
              SistemGecisi(sayfa: const WorkoutLibraryScreen()),
            ).then((_) => setState(() {})),
          ),
          IconButton(
            icon: const Icon(Icons.psychology, color: mentalPurple), 
            tooltip: 'AI Smart Trainer', 
            onPressed: _aiTrainerDialog
          ),
          IconButton(icon: const Icon(Icons.auto_awesome, color: physicalGold), tooltip: 'System Templates', onPressed: _sablonSecimDialog),
          const SizedBox(width: 10)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            HologramCard(
              neonRenk: sysBlue, 
              child: Column(
                children: [
                  // --- YENİ: ÇOKLU GÜN SEÇİCİ ---
                  Text("SELECT DAYS TO SYNC", style: GoogleFonts.orbitron(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: gunKisaIsimleri.entries.map((e) {
                      bool isSelected = seciliGunler.contains(e.key);
                      return GestureDetector(
                        onTap: () {
                          AudioSystem.playTransition();
                          setState(() {
                            if (isSelected) {
                              if (seciliGunler.length > 1) seciliGunler.remove(e.key); 
                            } else {
                              seciliGunler.add(e.key);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200), width: 38, height: 38,
                          decoration: BoxDecoration(color: isSelected ? sysBlue : cardBg, shape: BoxShape.circle, border: Border.all(color: isSelected ? sysBlue : sysTextMuted)),
                          child: Center(child: Text(e.value, style: GoogleFonts.rajdhani(color: isSelected ? Colors.black : sysTextMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text('PHYSICAL (STR/AGI)'), selected: secilenTip == 'Fiziksel', selectedColor: physicalGold.withValues(alpha: 0.2), 
                        labelStyle: GoogleFonts.orbitron(color: secilenTip == 'Fiziksel' ? physicalGold : sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold),
                        backgroundColor: cardBg, side: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold : Colors.white12),
                        onSelected: (val) => setState(() => secilenTip = 'Fiziksel'),
                      ),
                      ChoiceChip(
                        label: const Text('MENTAL (INT/PER)'), selected: secilenTip == 'Zihinsel', selectedColor: mentalPurple.withValues(alpha: 0.2), 
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
                            hintText: 'Quest Name (e.g. 50 Push-ups)', hintStyle: const TextStyle(color: sysTextMuted), filled: true, fillColor: const Color(0xFF070B14), 
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold.withValues(alpha: 0.3) : mentalPurple.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)), 
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), borderRadius: BorderRadius.circular(4))
                          )
                        )
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(color: secilenTip == 'Fiziksel' ? physicalGold.withValues(alpha: 0.15) : mentalPurple.withValues(alpha: 0.15), border: Border.all(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), borderRadius: BorderRadius.circular(4)), 
                        child: IconButton(icon: Icon(Icons.add, color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple), onPressed: hareketEkle)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- YENİ: SEÇİLİ GÜNLERİN GÖREV LİSTESİ ---
            Expanded(
              child: ListView.builder(
                itemCount: seciliGunler.length,
                itemBuilder: (context, index) {
                  // Seçili günleri sırayla al (Örn: 1-Pzt, 3-Çarş, 5-Cuma)
                  List<int> siraliGunler = seciliGunler.toList()..sort();
                  int sGun = siraliGunler[index]; 
                  List<Gorev> gununGorevleri = SystemMemory.haftalikPlan[sGun]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        child: Text(gunTamIsimleri[sGun]!, style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ),
                      if (gununGorevleri.isEmpty)
                        const Padding(padding: EdgeInsets.only(bottom: 15), child: Text("No quests assigned.", style: TextStyle(color: sysTextMuted, fontSize: 12))),
                      
                      ...gununGorevleri.asMap().entries.map((entry) {
                        int gIndex = entry.key; Gorev gorev = entry.value;
                        bool fizikselMi = gorev.tip == 'Fiziksel';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(color: const Color(0xFF070B14).withValues(alpha: 0.85), border: Border.all(color: fizikselMi ? physicalGold.withValues(alpha: 0.3) : mentalPurple.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)),
                          child: ListTile(
                            leading: Icon(fizikselMi ? Icons.fitness_center : Icons.psychology, color: fizikselMi ? physicalGold : mentalPurple, size: 20),
                            title: Text(gorev.ad, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            trailing: IconButton(icon: const Icon(Icons.close, color: sysRed, size: 18), onPressed: () => hareketSil(sGun, gIndex)),
                          ),
                        );
                      }),
                    ],
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