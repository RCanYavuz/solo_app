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
import '../widgets/advanced_exercise_selector_modal.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final DateTime Function()? nowProvider;
  const ActiveWorkoutScreen({super.key, this.nowProvider});

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
  late final DateTime _dungeonBaslangicZamani;
  Timer? _kronometre;
  int bugunIndex = DateTime.now().weekday;
  final Set<int> _acikSetler = {};

  DateTime get _now => widget.nowProvider != null ? widget.nowProvider!() : DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dungeonBaslangicZamani = _now;
    
    _kronometre = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          gecenSaniye = _now.difference(_dungeonBaslangicZamani).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _kronometre?.cancel();
    super.dispose();
  }

  // ZAMAN FARKI HESAPLAYICI (Ekran kilitlendiğinde, alta alındığında veya geri dönüldüğünde)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          gecenSaniye = _now.difference(_dungeonBaslangicZamani).inSeconds;
        });
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

  Future<void> _sablonUygula(String sablonAdi, {required bool ekleModu}) async {
    List<Gorev> gorevler = [];

    if (sablonAdi == 'Saitama (S-Rank)') {
      gorevler = [
        Gorev("[CHEST] 100 Push-ups", false, "Fiziksel"),
        Gorev("[CORE / ABS] 100 Sit-ups", false, "Fiziksel"),
        Gorev("[QUADS] 100 Squats", false, "Fiziksel"),
        Gorev("[CARDIO] 10 KM Run", false, "Fiziksel"),
      ];
    } 
    else if (sablonAdi == 'Full Body & Hypertrophy (B-Rank)') {
      gorevler = [
        Gorev("[PHY] Barbell Bench Press (5 Set x 10)", false, "Fiziksel"),
        Gorev("[PHY] Lat Pulldown / Pull-ups (5 Set x 10)", false, "Fiziksel"),
        Gorev("[PHY] Barbell Squat (5 Set x 8)", false, "Fiziksel"),
        Gorev("[PHY] Romanian Deadlift (4 Set x 10)", false, "Fiziksel"),
        Gorev("[PHY] Overhead Shoulder Press (4 Set x 10)", false, "Fiziksel"),
        Gorev("[PHY] Barbell Bicep Curl & Triceps Super-set (4 Set x 12)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Hanging Leg Raise & Plank (4 Set)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı Zone 2 & Sprint", false, "Fiziksel"),
      ];
    }
    else if (sablonAdi == 'Cardio & MetCon Burn') {
      gorevler = [
        Gorev("[CARDIO] 5 KM Avcı Tempolu Koşusu (Zone 3-4)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama (HIIT 45sn/15sn)", false, "Fiziksel"),
        Gorev("[COMBAT-CARDIO] Burpee & Sprawl Kondisyon (5 Set x 15)", false, "Fiziksel"),
        Gorev("[CARDIO] 15 Dk İnterval Sprint / Kürek Ergometresi", false, "Fiziksel"),
        Gorev("[CORE / ABS] Plank to Push-up & Hollow Body (4 Set)", false, "Fiziksel"),
        Gorev("[CARDIO] 10 Dk Bisiklet Soğuma & Esneme", false, "Fiziksel"),
      ];
    }
    else if (sablonAdi == 'Combat Striker Finisher') {
      gorevler = [
        Gorev("[COMBAT] Gölge Boksu / Şampiyon Raundları (6 Raund x 3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT] Ağır Kum Torbası Kombinasyonları (6 Raund x 3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT] Hızlı İp Atlama & Ayak Çalışması (20 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT] Burpee Sprawl & Darbe Direnci (5 Set x 15)", false, "Fiziksel"),
        Gorev("[COMBAT] Rotasyonel Landmine & Russian Twist (4 Set)", false, "Fiziksel"),
        Gorev("[CARDIO] 15 Dk Dövüş Kondisyon Koşusu (Zone 4)", false, "Fiziksel"),
      ];
    }
    else if (sablonAdi == 'Hunter 5K/10K Cardio') {
      gorevler = [
        Gorev("[CARDIO] 5 KM Avcı Tempolu Koşusu", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama (5 Raund x 3 Dk)", false, "Fiziksel"),
        Gorev("[CARDIO] 15 Dk Eğimli Koşu Bandı (Incline %12)", false, "Fiziksel"),
        Gorev("[COMBAT-CARDIO] Burpee Sprawl & Sıçrama (5 Set x 15)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Asılı Bacak Kaldırma & Plank (4 Set)", false, "Fiziksel"),
      ];
    }
    else if (sablonAdi == 'Tabata & MetCon Burn') {
      gorevler = [
        Gorev("[CARDIO] 8 Tur Tabata Sprint (20sn Tam Efor / 10sn Dinlenme)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı Yağ Yakımı", false, "Fiziksel"),
        Gorev("[COMBAT-CARDIO] 5 Raund Kum Torbası / Gölge Boksu Kardiyosu", false, "Fiziksel"),
        Gorev("[CARDIO] 15 Dk Concept 2 Kürek Ergometresi", false, "Fiziksel"),
        Gorev("[CORE / ABS] Dragon Flag & Russian Twist (4 Set)", false, "Fiziksel"),
      ];
    }
    else if (sablonAdi == 'Combat Shadow & Combos') {
      gorevler = SystemMemory.dovusGolgeBoksuKombinasyonlari(brans: SystemMemory.dovusBransi);
    }
    else if (sablonAdi == 'Monarch Mind') {
      gorevler = [
        Gorev("[MEDITATION] 30 Mins Focus", false, "Zihinsel"),
        Gorev("[READING] 20 Pages Book", false, "Zihinsel"),
        Gorev("[STRATEGY] Planning / Journal", false, "Zihinsel"),
      ];
    }
    else if (sablonAdi == 'AI Booster') {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SİSTEM: AI Avcı Booster hesaplanıyor...'),
          backgroundColor: Color(0xFFA855F7),
          duration: Duration(seconds: 1),
        ),
      );

      final boosterGorevler = await SystemMemory.aiEkIdmanBoosterUret(
        gun: bugunIndex,
        sadeceBunuYap: !ekleModu,
      );

      setState(() {});
      AudioSystem.playSuccess();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ekleModu
                ? 'SİSTEM: ${boosterGorevler.length} hareketlik AI Booster mevcut idmana eklendi!'
                : 'SİSTEM: ${boosterGorevler.length} hareketlik AI Booster zindana yüklendi!',
          ),
          backgroundColor: const Color(0xFF22C55E),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (!ekleModu) {
        SystemMemory.haftalikPlan[bugunIndex]!.clear();
        _acikSetler.clear();
      }
      SystemMemory.haftalikPlan[bugunIndex]!.addAll(gorevler);
    });

    SystemMemory.kaydet();
    AudioSystem.playSuccess();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ekleModu
              ? 'SİSTEM: "$sablonAdi" mevcut idmanınıza eklendi!'
              : 'SİSTEM: "$sablonAdi" zindana yüklendi!',
        ),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sablonSecimDialog() {
    AudioSystem.playTransition();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.98),
          shape: RoundedRectangleBorder(side: const BorderSide(color: sysBlue, width: 1), borderRadius: BorderRadius.circular(6)),
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: sysBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'INSTANT WORKOUT TEMPLATES',
                  style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İstediğiniz şablonu mevcut idmanınızın üzerine ekleyebilir (+ Append) veya sadece o şablonu yapabilirsiniz (🔄 Reset).',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  _sablonKarti(
                    ad: '🤖 AI AVCI ÖZEL BOOSTER',
                    aciklama: 'Rank, branş ve odak bölgene özel anlık 3-4 hareketlik akıllı finisher/takviye.',
                    renk: const Color(0xFFA855F7),
                    iconText: '🤖',
                    sablonKodu: 'AI Booster',
                  ),
                  _sablonKarti(
                    ad: 'Saitama (S-Rank)',
                    aciklama: '100 Push-ups, 100 Squats, 100 Sit-ups, 10 KM Run.',
                    renk: physicalGold,
                    iconText: '👊',
                  ),
                  _sablonKarti(
                    ad: 'Full Body & Hypertrophy (B-Rank)',
                    aciklama: 'Bench Press, Lat Pulldown, Squat, Shoulder Press, Arms, Plank & Kardiyo (7 Hareket).',
                    renk: const Color(0xFF38BDF8),
                    iconText: '⚔️',
                  ),
                  _sablonKarti(
                    ad: 'Cardio & MetCon Burn',
                    aciklama: '5 KM Koşu, 20 Dk İp Atlama HIIT, 5 Set Burpee Sprawl & Plank Soğuma (6 Hareket).',
                    renk: const Color(0xFF22C55E),
                    iconText: '🔥',
                  ),
                  _sablonKarti(
                    ad: '🏃 Avcı 5K/10K Koşu & HIIT',
                    sablonKodu: 'Hunter 5K/10K Cardio',
                    aciklama: '5 KM Avcı Temposu Koşu, 20 Dk İp Atlama, 15 Dk Eğimli Koşu Bandı, Burpee Sprawl & Core.',
                    renk: const Color(0xFF10B981),
                    iconText: '🏃',
                  ),
                  _sablonKarti(
                    ad: '⚡ Tabata & MetCon Extreme Burn',
                    sablonKodu: 'Tabata & MetCon Burn',
                    aciklama: '8 Tur Tabata Sprint, 20 Dk Eğimli Koşu, 5 Raund Kum Torbası Kardiyosu & 15 Dk Kürek Ergometresi.',
                    renk: const Color(0xFFF59E0B),
                    iconText: '⚡',
                  ),
                  _sablonKarti(
                    ad: 'Combat Striker Finisher',
                    aciklama: '6 Raund Gölge Boksu, 6 Raund Kum Torbası, 20 Dk İp Atlama & Dövüş Kondisyon Koşusu.',
                    renk: sysRed,
                    iconText: '🥊',
                  ),
                  _sablonKarti(
                    ad: 'Gölge Boksu & Kombinasyonlar (5 Raund)',
                    sablonKodu: 'Combat Shadow & Combos',
                    aciklama: 'Seçili branşa (${SystemMemory.dovusBransi}) özel 5 Raund x 3 Dk şampiyonluk kombinasyonları (Peek-a-boo, Dutch, Muay Thai veya MMA).',
                    renk: const Color(0xFFEF4444),
                    iconText: '🥋',
                  ),
                  _sablonKarti(
                    ad: 'Monarch Mind',
                    aciklama: 'Meditation, Reading, Strategy Journal.',
                    renk: mentalPurple,
                    iconText: '🧠',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('KAPAT', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          ],
        );
      },
    );
  }

  Widget _sablonKarti({
    required String ad,
    required String aciklama,
    required Color renk,
    required String iconText,
    String? sablonKodu,
  }) {
    final kod = sablonKodu ?? ad;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.08),
        border: Border.all(color: renk.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(iconText, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ad,
                  style: GoogleFonts.orbitron(color: renk, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(aciklama, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sablonUygula(kod, ekleModu: true),
                  icon: const Icon(Icons.add, size: 12, color: Color(0xFF22C55E)),
                  label: const Text('+ İDMANA EKLE', style: TextStyle(color: Color(0xFF22C55E), fontSize: 9, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF22C55E).withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sablonUygula(kod, ekleModu: false),
                  icon: const Icon(Icons.sync, size: 12, color: sysRed),
                  label: const Text('🔄 SIFIRLA VE YÜKLE', style: TextStyle(color: sysRed, fontSize: 9, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: sysRed.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _gorevSil(int index) {
    final bugununProgrami = SystemMemory.haftalikPlan[bugunIndex]!;
    if (index >= 0 && index < bugununProgrami.length) {
      final silinen = bugununProgrami[index].ad;
      setState(() {
        bugununProgrami.removeAt(index);
        _acikSetler.remove(index);
      });
      SystemMemory.kaydet();
      AudioSystem.playTransition();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SİSTEM: "$silinen" zindan görevlerinden kaldırıldı.'),
          backgroundColor: sysRed,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _ekHareketEkleDialog() {
    AdvancedExerciseSelectorModal.show(
      context,
      baslik: 'ZİNDANA EK HAREKET ENJEKTE ET',
      onayButonMetni: 'ZİNDANA EKLE',
      onEklendi: (yeniGorev) {
        setState(() {
          SystemMemory.haftalikPlan[bugunIndex]!.add(yeniGorev);
        });
        SystemMemory.kaydet();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SİSTEM: "${yeniGorev.ad}" zindana başarıyla eklendi!'),
            backgroundColor: const Color(0xFF22C55E),
            duration: const Duration(seconds: 2),
          ),
        );
      },
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
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          SistemGecisi(
                            sayfa: BoxingTimerScreen(
                              isInsideDungeonRaid: true,
                              dungeonBaslangicZamani: _dungeonBaslangicZamani,
                              nowProvider: widget.nowProvider,
                            ),
                          ),
                        );
                        if (mounted) {
                          setState(() {
                            gecenSaniye = _now.difference(_dungeonBaslangicZamani).inSeconds;
                          });
                        }
                      },
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
                            onPressed: _ekHareketEkleDialog,
                            icon: const Icon(Icons.add, color: Color(0xFF22C55E), size: 14),
                            label: const Text('+ EKLE', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
                              side: const BorderSide(color: Color(0xFF22C55E), width: 1),
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

                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                    child: OutlinedButton.icon(
                      onPressed: _ekHareketEkleDialog,
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF22C55E), size: 16),
                      label: Text(
                        '+ EK HAREKET ENJEKTE ET',
                        style: GoogleFonts.orbitron(
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF22C55E).withValues(alpha: 0.5), width: 1),
                        backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.05),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
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
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white30, size: 18),
                  tooltip: 'Görevi Kaldır',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () => _gorevSil(index),
                ),
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