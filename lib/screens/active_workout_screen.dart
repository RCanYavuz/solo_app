// lib/screens/active_workout_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../core/sistem_gecisi.dart'; 
import '../core/audio_system.dart'; 
import 'boxing_timer_screen.dart'; 
import '../core/youtube_helper.dart'; 
import '../widgets/exercise_detail_modal.dart';
import '../widgets/rest_timer_dialog.dart'; 

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

// 1. YENİ: "with WidgetsBindingObserver" EKLENDİ (Sistemi Dinlemek İçin)
class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> with WidgetsBindingObserver {
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712);
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color mentalPurple = Color(0xFFA060E0); 

  int gecenSaniye = 0;
  Timer? _kronometre;
  int bugunIndex = DateTime.now().weekday;
  final Set<int> _acikSetler = {};

  // 2. YENİ: Arka plana düşüş zamanını kaydedeceğimiz değişken
  DateTime? _arkaPlanaGidisZamani;

  @override
  void initState() {
    super.initState();
    // 3. YENİ: Gözlemciyi başlat
    WidgetsBinding.instance.addObserver(this);
    
    _kronometre = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        gecenSaniye++;
      });
    });
  }

  @override
  void dispose() {
    // 4. YENİ: Gözlemciyi yok et
    WidgetsBinding.instance.removeObserver(this);
    _kronometre?.cancel();
    super.dispose();
  }

  // 5. YENİ: ZAMAN FARKI HESAPLAYICI (Ekran kilitlendiğinde veya alta alındığında çalışır)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Uygulama arka plana atıldı veya ekran kilitlendi
      _arkaPlanaGidisZamani = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // Uygulamaya geri dönüldü
      if (_arkaPlanaGidisZamani != null) {
        final fark = DateTime.now().difference(_arkaPlanaGidisZamani!).inSeconds;
        setState(() {
          gecenSaniye += fark; // Aradan geçen kayıp saniyeleri sayaca ekle
        });
        _arkaPlanaGidisZamani = null;
      }
    }
  }

  String _sureFormatla(int toplamSaniye) {
    int saat = toplamSaniye ~/ 3600;
    int dakika = (toplamSaniye % 3600) ~/ 60;
    int saniye = toplamSaniye % 60;
    
    String strSaat = saat.toString().padLeft(2, '0');
    String strDakika = dakika.toString().padLeft(2, '0');
    String strSaniye = saniye.toString().padLeft(2, '0');

    if (saat > 0) return "$strSaat:$strDakika:$strSaniye";
    return "$strDakika:$strSaniye";
  }

  void _zindandanCik() {
    _kronometre?.cancel();
    
    String rapor = SystemMemory.zindanAkiniBitir(gecenSaniye);
    
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(side: const BorderSide(color: sysBlue, width: 1), borderRadius: BorderRadius.circular(4)),
        title: Text('[ DUNGEON CLEARED ]', style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold)),
        content: Text(rapor, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [ 
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: sysBlue.withValues(alpha: 0.2), side: const BorderSide(color: sysBlue)), 
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            }, 
            child: const Text('CONFIRM', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold))
          ) 
        ],
      ),
    );
  }

  void _sablonUygula(String sablonAdi) {
    setState(() {
      SystemMemory.haftalikPlan[bugunIndex]!.clear(); 
      
      if (sablonAdi == 'Saitama (S-Rank)') {
        SystemMemory.haftalikPlan[bugunIndex]!.addAll([
          Gorev("[CHEST] 100 Push-ups", false, "Fiziksel"),
          Gorev("[CORE / ABS] 100 Sit-ups", false, "Fiziksel"),
          Gorev("[QUADS] 100 Squats", false, "Fiziksel"),
          Gorev("[CARDIO] 10 KM Run", false, "Fiziksel"),
        ]);
      } 
      else if (sablonAdi == 'Full Body (B-Rank)') {
        SystemMemory.haftalikPlan[bugunIndex]!.addAll([
          Gorev("[CHEST] Bench / Push-ups", false, "Fiziksel"),
          Gorev("[BACK] Pull-ups / Rows", false, "Fiziksel"),
          Gorev("[QUADS] Squats", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank (3 Min)", false, "Fiziksel"),
        ]);
      }
      else if (sablonAdi == 'Monarch Mind') {
        SystemMemory.haftalikPlan[bugunIndex]!.addAll([
          Gorev("[MEDITATION] 30 Mins Focus", false, "Zihinsel"),
          Gorev("[READING] 20 Pages Book", false, "Zihinsel"),
          Gorev("[STRATEGY] Planning / Journal", false, "Zihinsel"),
        ]);
      }
    });
    
    SystemMemory.kaydet();
    AudioSystem.playSuccess();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SYSTEM: $sablonAdi loaded into current session!'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)));
  }

  void _sablonSecimDialog() {
    AudioSystem.playTransition();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(side: const BorderSide(color: sysBlue, width: 1), borderRadius: BorderRadius.circular(4)),
          title: Text('INSTANT TEMPLATES', style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("WARNING: Loading a template will REPLACE today's active quests.", style: TextStyle(color: sysRed, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _sablonButonu('Saitama (S-Rank)', '100 Push-ups, Squats, Sit-ups, 10km Run', physicalGold),
              const SizedBox(height: 10),
              _sablonButonu('Full Body (B-Rank)', 'Chest, Back, Legs, Core', physicalGold),
              const SizedBox(height: 10),
              _sablonButonu('Monarch Mind', 'Meditation, Reading, Strategy', mentalPurple),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8))))],
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

  @override
  Widget build(BuildContext context) {
    List<Gorev> bugununProgrami = SystemMemory.haftalikPlan[bugunIndex]!;

    return Scaffold(
      backgroundColor: sysDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                border: const Border(bottom: BorderSide(color: sysRed, width: 2)),
                boxShadow: [BoxShadow(color: sysRed.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)]
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.sports_mma, color: sysRed, size: 28),
                      tooltip: 'Combat Sim',
                      onPressed: () => Navigator.push(context, SistemGecisi(sayfa: const BoxingTimerScreen())),
                    ),
                  ),

                  Column(
                    children: [
                      Text('ACTIVE RAID', style: GoogleFonts.orbitron(color: sysRed, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4)),
                      const SizedBox(height: 10),
                      Text(
                        _sureFormatla(gecenSaniye),
                        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold, shadows: [Shadow(color: sysRed.withValues(alpha: 0.8), blurRadius: 20)]),
                      ),
                      const SizedBox(height: 5),
                      const Text('Dungeon Timer Running...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ACTIVE QUESTS', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => RestTimerDialog.show(context),
                            icon: const Icon(Icons.timer_outlined, color: sysBlue, size: 14),
                            label: const Text('REST', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sysBlue.withValues(alpha: 0.1),
                              side: const BorderSide(color: sysBlue, width: 1),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: _sablonSecimDialog, 
                            icon: const Icon(Icons.auto_awesome, color: physicalGold, size: 14),
                            label: const Text('TEMPLATES', style: TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: physicalGold.withValues(alpha: 0.1),
                              side: const BorderSide(color: physicalGold, width: 1),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  if (bugununProgrami.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text("No quests assigned. Load a template or return to planner.", style: TextStyle(color: Color(0xFF94A3B8))),
                    )),
                  
                  ...bugununProgrami.asMap().entries.map((entry) {
                    return _buildQuestCard(entry.value, entry.key);
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _zindandanCik,
                  icon: const Icon(Icons.exit_to_app, color: sysRed),
                  label: const Text('EXIT DUNGEON', style: TextStyle(color: sysRed, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysRed.withValues(alpha: 0.1), padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: sysRed, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(Gorev gorev, int index) {
    final bool acik = _acikSetler.contains(index);
    final bool fiziksel = gorev.tip == "Fiziksel";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.85),
        border: Border.all(
          color: gorev.yapildiMi ? sysBlue.withValues(alpha: 0.2) : sysBlue.withValues(alpha: 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            leading: Checkbox(
              value: gorev.yapildiMi,
              activeColor: sysBlue,
              checkColor: sysDarkBg,
              onChanged: (val) {
                setState(() {
                  gorev.yapildiMi = val ?? false;
                });
                SystemMemory.kaydet();
                if (val == true) {
                  AudioSystem.playTransition();
                  RestTimerDialog.show(context, exerciseName: gorev.ad);
                }
              },
            ),
            title: GestureDetector(
              onTap: () => ExerciseDetailModal.show(
                context,
                gorevAdi: gorev.ad,
                gun: bugunIndex,
                index: index,
                onSwapped: () => setState(() {}),
              ),
              child: Text(
                gorev.ad,
                style: TextStyle(
                  color: gorev.yapildiMi ? const Color(0xFF94A3B8) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: gorev.yapildiMi ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            subtitle: GestureDetector(
              onTap: () => ExerciseDetailModal.show(
                context,
                gorevAdi: gorev.ad,
                gun: bugunIndex,
                index: index,
                onSwapped: () => setState(() {}),
              ),
              child: Row(
                children: [
                  Text(
                    fiziksel ? '[PHY]' : '[MNT]',
                    style: TextStyle(
                      color: fiziksel ? sysBlue.withValues(alpha: 0.7) : mentalPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('• Dokun: Taktik / Alternatif', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fiziksel)
                  IconButton(
                    icon: Icon(
                      acik ? Icons.expand_less : Icons.playlist_add_check,
                      color: physicalGold,
                      size: 20,
                    ),
                    tooltip: 'Set & Ağırlık Takibi',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        if (acik) {
                          _acikSetler.remove(index);
                        } else {
                          _acikSetler.add(index);
                        }
                      });
                    },
                  ),
                YoutubeHelper.buildYouTubeButton(gorevAdi: gorev.ad, size: 20),
              ],
            ),
          ),
          if (fiziksel && acik) ...[
            const Divider(color: Colors.white10, height: 1),
            _buildSetListesi(gorev),
          ],
        ],
      ),
    );
  }

  Widget _buildSetListesi(Gorev gorev) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SET & OVERLOAD LOG',
                style: GoogleFonts.orbitron(
                  color: physicalGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    gorev.setler.add(SetKaydi(
                      setNo: gorev.setler.length + 1,
                      kilo: gorev.setler.isNotEmpty ? gorev.setler.last.kilo : 0,
                      tekrar: gorev.setler.isNotEmpty ? gorev.setler.last.tekrar : 10,
                    ));
                  });
                  SystemMemory.kaydet();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: physicalGold.withValues(alpha: 0.15),
                    border: Border.all(color: physicalGold.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: physicalGold, size: 12),
                      SizedBox(width: 3),
                      Text(
                        'SET EKLE',
                        style: TextStyle(color: physicalGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (gorev.setler.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Henüz set eklenmedi. "SET EKLE" butonuna basarak ağırlık kaydedin.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            )
          else
            ...gorev.setler.asMap().entries.map((entry) {
              final int sIdx = entry.key;
              final SetKaydi s = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: s.tamamlandi ? sysBlue.withValues(alpha: 0.5) : Colors.white12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      'SET ${s.setNo}',
                      style: GoogleFonts.orbitron(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _setDuzenleDialog(gorev, sIdx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${s.kilo > 0 ? "${s.kilo.toStringAsFixed(s.kilo.truncateToDouble() == s.kilo ? 0 : 1)} kg" : "BW"} x ${s.tekrar} rep',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        s.tamamlandi ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: s.tamamlandi ? sysBlue : const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          s.tamamlandi = !s.tamamlandi;
                        });
                        SystemMemory.kaydet();
                        if (s.tamamlandi) {
                          AudioSystem.playTransition();
                          RestTimerDialog.show(context, exerciseName: '${gorev.ad} (Set ${s.setNo})');
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.close, color: sysRed, size: 14),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          gorev.setler.removeAt(sIdx);
                        });
                        SystemMemory.kaydet();
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _setDuzenleDialog(Gorev gorev, int sIdx) {
    final s = gorev.setler[sIdx];
    final kiloCtrl = TextEditingController(text: s.kilo > 0 ? s.kilo.toString() : '');
    final repCtrl = TextEditingController(text: s.tekrar.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF070B14),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: sysBlue, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        title: Text(
          'SET ${s.setNo} DÜZENLE',
          style: GoogleFonts.orbitron(color: sysBlue, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kiloCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Ağırlık (kg - Vücut ağırlığı için boş bırakın)',
                labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: repCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tekrar Sayısı (Reps)',
                labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: sysBlue.withValues(alpha: 0.2),
              side: const BorderSide(color: sysBlue),
            ),
            onPressed: () {
              setState(() {
                s.kilo = double.tryParse(kiloCtrl.text) ?? 0.0;
                s.tekrar = int.tryParse(repCtrl.text) ?? s.tekrar;
              });
              SystemMemory.kaydet();
              Navigator.pop(ctx);
            },
            child: const Text('KAYDET', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}