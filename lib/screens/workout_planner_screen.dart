// lib/screens/workout_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart'; 
import '../core/sistem_gecisi.dart';
import 'workout_library_screen.dart'; 
import '../core/translation_manager.dart';
import '../widgets/exercise_detail_modal.dart';

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
  
  Map<int, String> get gunKisaIsimleri => TranslationManager.isTurkish
      ? { 1: "PZT", 2: "SAL", 3: "ÇAR", 4: "PER", 5: "CUM", 6: "CTS", 7: "PAZ" }
      : { 1: "MON", 2: "TUE", 3: "WED", 4: "THU", 5: "FRI", 6: "SAT", 7: "SUN" };
  Map<int, String> get gunTamIsimleri => TranslationManager.isTurkish
      ? { 1: "PAZARTESİ", 2: "SALI", 3: "ÇARŞAMBA", 4: "PERŞEMBE", 5: "CUMA", 6: "CUMARTESİ", 7: "PAZAR" }
      : { 1: "MONDAY", 2: "TUESDAY", 3: "WEDNESDAY", 4: "THURSDAY", 5: "FRIDAY", 6: "SATURDAY", 7: "SUNDAY" };

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
            final String disciplineInfo = SystemMemory.dovusSporuYapiyorMu 
                ? "Dövüş: ${SystemMemory.dovusBransi}" 
                : "Ekipman: ${SystemMemory.ekipmanTuru}";
            final String focusInfo = SystemMemory.odakBolgeleri.isNotEmpty 
                ? "Odak: ${SystemMemory.odakBolgeleri.join(', ')}" 
                : "";

            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.96),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: mentalPurple, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              title: Row(
                children: [
                  const Icon(Icons.psychology, color: mentalPurple, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI SMART TRAINER',
                      style: GoogleFonts.orbitron(color: mentalPurple, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mentalPurple.withValues(alpha: 0.1),
                        border: Border.all(color: mentalPurple.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rank: ${SystemMemory.hunterRank} | $disciplineInfo",
                            style: const TextStyle(color: physicalGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          if (focusInfo.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              focusInfo,
                              style: const TextStyle(color: sysBlue, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sistem yapay zekası avcı profilinize, dövüş branşınıza, sakatlık korumanıza ve odak bölgelerinize göre antrenman üretir.',
                      style: TextStyle(color: sysTextMuted, fontSize: 11, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: talepCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'Özel Not / Talep (Opsiyonel)',
                        hintText: 'Örn: Bu hafta omzum yorgun, bacaklarıma odaklan...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                        labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: mentalPurple.withValues(alpha: 0.4))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mentalPurple)),
                      ),
                    ),
                    if (yukleniyor) ...[
                      const SizedBox(height: 18),
                      const Center(child: CircularProgressIndicator(color: mentalPurple, strokeWidth: 2.5)),
                      const SizedBox(height: 8),
                      const Center(child: Text("Sistem antrenman protokolünü hesaplıyor...", style: TextStyle(color: mentalPurple, fontSize: 11))),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: yukleniyor ? null : () => Navigator.pop(context),
                  child: const Text('İPTAL', style: TextStyle(color: sysTextMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysBlue.withValues(alpha: 0.2),
                    side: const BorderSide(color: sysBlue),
                  ),
                  onPressed: yukleniyor ? null : () async {
                    setDialogState(() => yukleniyor = true);
                    AudioSystem.playTransition();

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    final bool basarili = await SystemMemory.aiPrograminiUygula(
                      ozelTalep: talepCtrl.text.trim(),
                    );
                    setDialogState(() => yukleniyor = false);

                    if (!mounted) return;
                    navigator.pop();
                    setState(() {});

                    if (basarili) {
                      AudioSystem.playLevelUp();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('⚡ SİSTEM: Haftalık antrenman programı Gemini AI tarafından başarıyla yenilendi!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      AudioSystem.playSuccess();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ SİSTEM: Yerel kural motoru devreye alındı (Çevrimdışı/Yedek mod).'),
                          backgroundColor: physicalGold,
                        ),
                      );
                    }
                  },
                  child: const Text('TÜM HAFTAYI YENİLE', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            );
          }
        );
      }
    );
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
    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: sysDarkBg, 
          appBar: AppBar(
            title: Text(TranslationManager.get('planner_title'), style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
            backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: sysBlue),
            actions: [
              IconButton(
                icon: const Icon(Icons.fitness_center, color: sysBlue),
                tooltip: TranslationManager.get('status_workout_lib_tooltip'),
                onPressed: () => Navigator.push(
                  context,
                  SistemGecisi(sayfa: const WorkoutLibraryScreen()),
                ).then((_) => setState(() {})),
              ),
              IconButton(
                icon: const Icon(Icons.psychology, color: mentalPurple), 
                tooltip: TranslationManager.get('planner_ai_btn'), 
                onPressed: _aiTrainerDialog
              ),
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: physicalGold), 
                tooltip: TranslationManager.get('planner_templates'), 
                onPressed: _sablonSecimDialog
              ),
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
                      Text(TranslationManager.get('planner_select_days'), style: GoogleFonts.orbitron(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
                            label: Text(TranslationManager.get('planner_physical')), selected: secilenTip == 'Fiziksel', selectedColor: physicalGold.withValues(alpha: 0.2), 
                            labelStyle: GoogleFonts.orbitron(color: secilenTip == 'Fiziksel' ? physicalGold : sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            backgroundColor: cardBg, side: BorderSide(color: secilenTip == 'Fiziksel' ? physicalGold : Colors.white12),
                            onSelected: (val) => setState(() => secilenTip = 'Fiziksel'),
                          ),
                          ChoiceChip(
                            label: Text(TranslationManager.get('planner_mental')), selected: secilenTip == 'Zihinsel', selectedColor: mentalPurple.withValues(alpha: 0.2), 
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
                          Text(TranslationManager.get('planner_target_area'), style: GoogleFonts.orbitron(color: secilenTip == 'Fiziksel' ? physicalGold : mentalPurple, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
                                hintText: TranslationManager.get('planner_exercise_hint'), hintStyle: const TextStyle(color: sysTextMuted), filled: true, fillColor: const Color(0xFF070B14), 
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
                            Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(TranslationManager.get('planner_no_quests'), style: const TextStyle(color: sysTextMuted, fontSize: 12))),
                          
                          ...gununGorevleri.asMap().entries.map((entry) {
                            int gIndex = entry.key; Gorev gorev = entry.value;
                            bool fizikselMi = gorev.tip == 'Fiziksel';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(color: const Color(0xFF070B14).withValues(alpha: 0.85), border: Border.all(color: fizikselMi ? physicalGold.withValues(alpha: 0.3) : mentalPurple.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)),
                              child: ListTile(
                                leading: Icon(fizikselMi ? Icons.fitness_center : Icons.psychology, color: fizikselMi ? physicalGold : mentalPurple, size: 20),
                                title: GestureDetector(
                                  onTap: () => ExerciseDetailModal.show(
                                    context,
                                    gorevAdi: gorev.ad,
                                    gun: sGun,
                                    index: gIndex,
                                    onSwapped: () => setState(() {}),
                                  ),
                                  child: Text(gorev.ad, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ExerciseTacticalButtons(
                                      gorevAdi: gorev.ad,
                                      gun: sGun,
                                      index: gIndex,
                                      onSwapped: () => setState(() {}),
                                      size: 18,
                                    ),
                                    IconButton(icon: const Icon(Icons.close, color: sysRed, size: 18), onPressed: () => hareketSil(sGun, gIndex)),
                                  ],
                                ),
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
      },
    );
  }

  @override
  void dispose() {
    hareketKontrolcusu.dispose();
    super.dispose();
  }
}