// lib/screens/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 

import '../controllers/system_memory.dart'; 
import '../core/services/gemini_service.dart';
import '../core/audio_system.dart';
import 'welcome_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _aktifAdim = 0; // 0: Kimlik, 1: Fiziksel Tarama, 2: Disiplin & Ekipman, 3: Uyanış Testi

  // Adım 1: Kimlik
  final TextEditingController isimCtrl = TextEditingController();
  String secilenCinsiyet = 'Erkek';
  DateTime? secilenTarih;
  Uint8List? secilenFotoByte;
  final TextEditingController apiKeyCtrl = TextEditingController();
  bool _isObscure = true;
  bool _isTestingApi = false;
  String? _apiTestSonucu;
  bool _apiTestBasarili = false;

  // Adım 2: Fiziksel Tarama & Hedef
  final TextEditingController boyCtrl = TextEditingController();
  final TextEditingController kiloCtrl = TextEditingController();
  String secilenHedef = 'Kilo Ver (Yağ Yak)';
  String secilenZorluk = 'Normal';
  int secilenIdmanGunu = 3;

  // Detaylı Vücut Ölçümleri (cm)
  final TextEditingController gogusCtrl = TextEditingController();
  final TextEditingController belCtrl = TextEditingController();
  final TextEditingController kolCtrl = TextEditingController();
  final TextEditingController bacakCtrl = TextEditingController();

  // Adım 3: Disiplin & Ekipman
  bool dovusSporuYapiyorMu = false;
  String secilenDovusBransi = 'Boks';
  String secilenEkipman = 'Salon';
  String secilenTecrube = 'Başlangıç';
  List<String> secilenEklemKisitlari = [];

  // Adım 4: Uyanış / Güç Testi (Fitness / Gym)
  final TextEditingController benchCtrl = TextEditingController();
  final TextEditingController squatCtrl = TextEditingController();
  final TextEditingController deadliftCtrl = TextEditingController();
  final TextEditingController pushupCtrl = TextEditingController();
  final TextEditingController bwSquatCtrl = TextEditingController();
  final TextEditingController pullupCtrl = TextEditingController();
  bool testGirisModuReps = false;

  // Adım 4: Uyanış / Güç Testi (Dövüş / Boks Kondisyonu)
  final TextEditingController patlayiciSinavCtrl = TextEditingController();
  final TextEditingController burpeeCtrl = TextEditingController();
  final TextEditingController plankCtrl = TextEditingController();
  final TextEditingController combatBarfiksCtrl = TextEditingController();

  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 
  static const Color physicalGold = Color(0xFFEAB308);

  @override
  void initState() {
    super.initState();
    if (SystemMemory.geminiApiKey.isNotEmpty) {
      apiKeyCtrl.text = SystemMemory.geminiApiKey;
    }
    if (SystemMemory.oyuncuIsmi.isNotEmpty && SystemMemory.oyuncuIsmi != "PLAYER") {
      isimCtrl.text = SystemMemory.oyuncuIsmi;
    }
  }

  @override
  void dispose() {
    isimCtrl.dispose();
    apiKeyCtrl.dispose();
    boyCtrl.dispose();
    kiloCtrl.dispose();
    gogusCtrl.dispose();
    belCtrl.dispose();
    kolCtrl.dispose();
    bacakCtrl.dispose();
    benchCtrl.dispose();
    squatCtrl.dispose();
    deadliftCtrl.dispose();
    pushupCtrl.dispose();
    bwSquatCtrl.dispose();
    pullupCtrl.dispose();
    patlayiciSinavCtrl.dispose();
    burpeeCtrl.dispose();
    plankCtrl.dispose();
    combatBarfiksCtrl.dispose();
    super.dispose();
  }

  Future<void> _fotoSec() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500, maxHeight: 500, imageQuality: 80,
    );
    
    if (image != null) {
      final Uint8List fotoBytes = await image.readAsBytes();
      setState(() { secilenFotoByte = fotoBytes; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SYSTEM: Avatar Data Synchronized!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _tarihSec() async {
    DateTime? secilen = await showDatePicker(
      context: context, 
      initialDate: DateTime(2000), 
      firstDate: DateTime(1950), 
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: sysBlue, 
              onPrimary: Colors.black, 
              surface: Color(0xFF0F172A), 
              onSurface: Colors.white
            ),
            dialogTheme: const DialogThemeData(backgroundColor: sysDarkBg),
          ),
          child: child!,
        );
      },
    );

    if (secilen != null) {
      setState(() { secilenTarih = secilen; });
    }
  }

  Future<void> _testApiKey() async {
    final key = apiKeyCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter an API key first!'), backgroundColor: sysRed),
      );
      return;
    }

    SystemMemory.geminiApiKey = key;
    await SystemMemory.kaydet();

    setState(() {
      _isTestingApi = true;
      _apiTestSonucu = null;
    });
    final girilenIsim = isimCtrl.text.trim();
    final isim = girilenIsim.isNotEmpty ? girilenIsim.toUpperCase() : 'AVCI';

    final sonuc = await GeminiService.testBaglantisi(hunterName: isim);
    if (!mounted) return;
    setState(() {
      _isTestingApi = false;
      _apiTestBasarili = sonuc['basarili'] == true;
      _apiTestSonucu = sonuc['mesaj'] ?? '';
    });
  }

  String _hesaplaCanliRank() {
    double pKilo = double.tryParse(kiloCtrl.text.replaceAll(',', '.')) ?? 70.0;
    if (dovusSporuYapiyorMu) {
      int pSinav = int.tryParse(patlayiciSinavCtrl.text.trim()) ?? 0;
      int pBurpee = int.tryParse(burpeeCtrl.text.trim()) ?? 0;
      int pPlank = int.tryParse(plankCtrl.text.trim()) ?? 0;
      int pBarfiks = int.tryParse(combatBarfiksCtrl.text.trim()) ?? 0;
      if (pSinav == 0 && pBurpee == 0 && pPlank == 0 && pBarfiks == 0) {
        return "E-Rank (Rookie)";
      }
      return SystemMemory.hesaplaDovusRank(
        patlayiciSinav: pSinav,
        burpeeKondisyon: pBurpee,
        plankSaniye: pPlank,
        barfiks: pBarfiks,
      );
    } else {
      double pBench = 0, pSquat = 0, pDeadlift = 0;
      if (testGirisModuReps || secilenEkipman == 'Vucut-Agirligi') {
        double pR = double.tryParse(pushupCtrl.text.trim()) ?? 0;
        double sR = double.tryParse(bwSquatCtrl.text.trim()) ?? 0;
        double puR = double.tryParse(pullupCtrl.text.trim()) ?? 0;
        if (pR > 0) pBench = pKilo * (0.60 + (pR * 0.015));
        if (sR > 0) pSquat = pKilo * (0.75 + (sR * 0.02));
        if (puR > 0) pDeadlift = pKilo * (0.80 + (puR * 0.035));
      } else {
        pBench = double.tryParse(benchCtrl.text.trim()) ?? 0;
        pSquat = double.tryParse(squatCtrl.text.trim()) ?? 0;
        pDeadlift = double.tryParse(deadliftCtrl.text.trim()) ?? 0;
      }
      double pTotal = pBench + pSquat + pDeadlift;
      double pRatio = pKilo > 0 ? (pTotal / pKilo) : 0;
      if (pTotal == 0) return "E-Rank (Rookie)";
      if (pRatio >= 4.5) return "S-Rank (Monarch)";
      if (pRatio >= 3.75) return "A-Rank (National)";
      if (pRatio >= 3.0) return "B-Rank (Elite)";
      if (pRatio >= 2.25) return "C-Rank (Knight)";
      if (pRatio >= 1.5) return "D-Rank (Hunter)";
      return "E-Rank (Rookie)";
    }
  }

  void _ileriAdim() {
    if (_aktifAdim == 0) {
      if (secilenTarih == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Birth date is required for metabolic calibration!'), backgroundColor: sysRed),
        );
        return;
      }
    } else if (_aktifAdim == 1) {
      if (boyCtrl.text.trim().isEmpty || kiloCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Height and Weight are mandatory to configure System quests!'), backgroundColor: sysRed),
        );
        return;
      }
    }
    if (_aktifAdim < 3) {
      setState(() => _aktifAdim++);
    }
  }

  void _geriAdim() {
    if (_aktifAdim > 0) {
      setState(() => _aktifAdim--);
    }
  }

  Future<void> _analiziBaslat() async {
    if (secilenTarih == null || boyCtrl.text.isEmpty || kiloCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SYSTEM: Birth date, height and weight data are mandatory!'), backgroundColor: sysRed),
      );
      return;
    }

    if (isimCtrl.text.trim().isNotEmpty) {
      SystemMemory.oyuncuIsmi = isimCtrl.text.trim().toUpperCase();
    } else {
      SystemMemory.oyuncuIsmi = "PLAYER";
    }

    double boy = double.tryParse(boyCtrl.text.replaceAll(',', '.')) ?? 175.0;
    double kilo = double.tryParse(kiloCtrl.text.replaceAll(',', '.')) ?? 70.0;

    // Detaylı Vücut Ölçümleri
    SystemMemory.gogusCm = double.tryParse(gogusCtrl.text.replaceAll(',', '.')) ?? 0.0;
    SystemMemory.belCm = double.tryParse(belCtrl.text.replaceAll(',', '.')) ?? 0.0;
    SystemMemory.kolCm = double.tryParse(kolCtrl.text.replaceAll(',', '.')) ?? 0.0;
    SystemMemory.bacakCm = double.tryParse(bacakCtrl.text.replaceAll(',', '.')) ?? 0.0;

    if (apiKeyCtrl.text.trim().isNotEmpty) {
      SystemMemory.geminiApiKey = apiKeyCtrl.text.trim();
    }

    // Ana Oyuncu Analizini Yap
    SystemMemory.oyuncuyuAnalizEt(
      secilenCinsiyet,
      secilenTarih!,
      boy,
      kilo,
      secilenHedef,
      secilenZorluk,
      secilenFotoByte,
      secilenIdmanGunu,
      secilenEkipman,
      secilenTecrube,
      secilenEklemKisitlari,
    );

    // Rank & Antrenman Uyanışı
    if (dovusSporuYapiyorMu) {
      int pSinav = int.tryParse(patlayiciSinavCtrl.text.trim()) ?? 0;
      int pBurpee = int.tryParse(burpeeCtrl.text.trim()) ?? 0;
      int pPlank = int.tryParse(plankCtrl.text.trim()) ?? 0;
      int pBarfiks = int.tryParse(combatBarfiksCtrl.text.trim()) ?? 0;
      String combatRank = SystemMemory.hesaplaDovusRank(
        patlayiciSinav: pSinav,
        burpeeKondisyon: pBurpee,
        plankSaniye: pPlank,
        barfiks: pBarfiks,
      );

      SystemMemory.dovusTestiKaydet(
        patlayiciSinav: pSinav,
        burpeeKondisyon: pBurpee,
        plankSaniye: pPlank,
        barfiks: pBarfiks,
        rank: combatRank,
        brans: secilenDovusBransi,
        idmanGunu: secilenIdmanGunu,
      );
    } else {
      double testBench = 0;
      double testSquat = 0;
      double testDeadlift = 0;

      if (testGirisModuReps || secilenEkipman == 'Vucut-Agirligi') {
        double pReps = double.tryParse(pushupCtrl.text.trim()) ?? 0;
        double sReps = double.tryParse(bwSquatCtrl.text.trim()) ?? 0;
        double puReps = double.tryParse(pullupCtrl.text.trim()) ?? 0;
        if (pReps > 0) testBench = kilo * (0.60 + (pReps * 0.015));
        if (sReps > 0) testSquat = kilo * (0.75 + (sReps * 0.02));
        if (puReps > 0) testDeadlift = kilo * (0.80 + (puReps * 0.035));
      } else {
        testBench = double.tryParse(benchCtrl.text.trim()) ?? 0;
        testSquat = double.tryParse(squatCtrl.text.trim()) ?? 0;
        testDeadlift = double.tryParse(deadliftCtrl.text.trim()) ?? 0;
      }

      double total = testBench + testSquat + testDeadlift;
      double ratio = total / kilo;
      String baslangicRank;
      if (total == 0) {
        baslangicRank = "E-Rank (Rookie)";
        testBench = (kilo * 0.4).roundToDouble();
        testSquat = (kilo * 0.5).roundToDouble();
        testDeadlift = (kilo * 0.6).roundToDouble();
      } else if (ratio >= 4.5) {
        baslangicRank = "S-Rank (Monarch)";
      } else if (ratio >= 3.75) {
        baslangicRank = "A-Rank (National)";
      } else if (ratio >= 3.0) {
        baslangicRank = "B-Rank (Elite)";
      } else if (ratio >= 2.25) {
        baslangicRank = "C-Rank (Knight)";
      } else if (ratio >= 1.5) {
        baslangicRank = "D-Rank (Hunter)";
      } else {
        baslangicRank = "E-Rank (Rookie)";
      }

      SystemMemory.awakeningTestKaydet(
        bench: testBench,
        squat: testSquat,
        deadlift: testDeadlift,
        rank: baslangicRank,
        idmanGunu: secilenIdmanGunu,
      );
    }

    if (SystemMemory.geminiApiKey.isNotEmpty) {
      setState(() => _isTestingApi = true);
      final sonuc = await GeminiService.testBaglantisi(
        hunterName: SystemMemory.oyuncuIsmi,
      );
      if (!mounted) return;
      setState(() => _isTestingApi = false);

      final basarili = sonuc['basarili'] == true;
      final mesaj = sonuc['mesaj'] ?? '';
      final model = sonuc['model'];

      await _sistemUyanisDialoguGoster(basarili, mesaj, model);
      if (!mounted) return;
    }

    AudioSystem.playLevelUp();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
  }

  Future<void> _sistemUyanisDialoguGoster(bool basarili, String mesaj, String? model) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: basarili ? sysBlue : sysRed, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Row(
            children: [
              Icon(
                basarili ? Icons.auto_awesome : Icons.error_outline,
                color: basarili ? sysBlue : sysRed,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  basarili ? 'SYSTEM AWAKENED' : 'CORE DIAGNOSTIC FAILED',
                  style: GoogleFonts.orbitron(
                    color: basarili ? sysBlue : sysRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (basarili && model != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sysBlue.withValues(alpha: 0.1),
                    border: Border.all(color: sysBlue.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.memory, color: sysBlue, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'CORE MODEL: $model',
                        style: const TextStyle(
                          color: sysBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (basarili ? sysBlue : sysRed).withValues(alpha: 0.06),
                  border: Border(
                    left: BorderSide(
                      color: basarili ? sysBlue : sysRed,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  mesaj,
                  style: TextStyle(
                    color: basarili ? Colors.white : Colors.redAccent,
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: basarili ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              if (basarili) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text(
                      'Connection Established. System is Online.',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: (basarili ? sysBlue : sysRed).withValues(alpha: 0.2),
                side: BorderSide(color: basarili ? sysBlue : sysRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                basarili ? 'PROCEED TO SYSTEM' : 'CONTINUE OFFLINE',
                style: TextStyle(color: basarili ? sysBlue : sysRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14).withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sysBlue.withValues(alpha: 0.35), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: sysBlue.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStepperHeader(),
                const SizedBox(height: 20),
                if (_aktifAdim == 0) _buildStep0Identity(),
                if (_aktifAdim == 1) _buildStep1BodyScan(),
                if (_aktifAdim == 2) _buildStep2DisciplineAndGear(),
                if (_aktifAdim == 3) _buildStep3AwakeningTest(),
                const SizedBox(height: 25),
                _buildNavigationFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    final stepTitles = [
      'PHASE 01: IDENTITY',
      'PHASE 02: BODY CALIBRATION',
      'PHASE 03: COMBAT & GEAR',
      'PHASE 04: AWAKENING TEST',
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SYSTEM INITIALIZATION',
              style: GoogleFonts.orbitron(
                color: sysBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${_aktifAdim + 1} / 4',
              style: GoogleFonts.orbitron(
                color: physicalGold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            bool isActive = index <= _aktifAdim;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: isActive ? sysBlue : Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [BoxShadow(color: sysBlue.withValues(alpha: 0.5), blurRadius: 4)]
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            stepTitles[_aktifAdim],
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 0: HUNTER IDENTITY
  // ==========================================
  Widget _buildStep0Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _fotoSec,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: secilenFotoByte != null ? sysBlue : sysTextMuted,
                    width: 2,
                  ),
                  image: secilenFotoByte != null
                      ? DecorationImage(image: MemoryImage(secilenFotoByte!), fit: BoxFit.cover)
                      : null,
                  color: const Color(0xFF0F172A),
                ),
                child: secilenFotoByte == null
                    ? Icon(Icons.person, color: sysTextMuted.withValues(alpha: 0.5), size: 40)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: sysBlue, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: isimCtrl,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: _inputStili('Hunter Name / Codename (Optional)'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: secilenCinsiyet,
                dropdownColor: const Color(0xFF0F172A),
                decoration: _inputStili('Gender'),
                style: const TextStyle(color: Colors.white),
                items: ['Erkek', 'Kadın'].map((String c) {
                  return DropdownMenuItem(value: c, child: Text(c == 'Erkek' ? 'Male' : 'Female'));
                }).toList(),
                onChanged: (val) => setState(() => secilenCinsiyet = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _tarihSec,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: sysBlue.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    secilenTarih == null
                        ? 'Birth Date *'
                        : '${secilenTarih!.day.toString().padLeft(2, '0')}.${secilenTarih!.month.toString().padLeft(2, '0')}.${secilenTarih!.year}',
                    style: TextStyle(
                      color: secilenTarih == null ? sysTextMuted : Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: apiKeyCtrl,
          obscureText: _isObscure,
          style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'Gemini API Key (Optional)',
            labelStyle: const TextStyle(color: sysTextMuted),
            helperText: 'For System AI Voice & Dynamic Coaching',
            helperStyle: TextStyle(color: sysTextMuted.withValues(alpha: 0.6), fontSize: 10),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: sysBlue),
              borderRadius: BorderRadius.circular(4),
            ),
            suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, color: sysBlue, size: 18),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _isTestingApi ? null : _testApiKey,
            icon: _isTestingApi
                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: sysBlue))
                : const Icon(Icons.bolt, size: 15, color: sysBlue),
            label: Text(
              _isTestingApi ? 'TESTING...' : 'TEST CORE CONNECTION',
              style: const TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_apiTestSonucu != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _apiTestBasarili ? sysBlue.withValues(alpha: 0.1) : sysRed.withValues(alpha: 0.1),
              border: Border.all(color: _apiTestBasarili ? sysBlue : sysRed, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(_apiTestBasarili ? Icons.check_circle : Icons.error, color: _apiTestBasarili ? sysBlue : sysRed, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _apiTestSonucu!,
                    style: TextStyle(color: _apiTestBasarili ? Colors.white : sysRed, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // STEP 1: PHYSICAL CALIBRATION & MEASUREMENTS
  // ==========================================
  Widget _buildStep1BodyScan() {
    List<String> zorlukSeviyeleri = [];
    if (secilenHedef == 'Kilo Ver (Yağ Yak)') {
      zorlukSeviyeleri = ['Normal', 'Yüksek', 'Cehennem'];
    } else if (secilenHedef == 'Kilo Al (Kas İnşa Et)') {
      zorlukSeviyeleri = ['Normal', 'Yüksek', 'Canavar'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: boyCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStili('Height (cm) *'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: kiloCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStili('Weight (kg) *'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: secilenHedef,
          dropdownColor: const Color(0xFF0F172A),
          decoration: _inputStili('System Objective'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: ['Kilo Ver (Yağ Yak)', 'Kilo Koru (Dengede Kal)', 'Kilo Al (Kas İnşa Et)'].map((String c) {
            String label = c;
            if (c == 'Kilo Ver (Yağ Yak)') label = 'Lose Weight (Burn Fat)';
            if (c == 'Kilo Koru (Dengede Kal)') label = 'Maintain Weight (Balance)';
            if (c == 'Kilo Al (Kas İnşa Et)') label = 'Gain Weight (Build Muscle)';
            return DropdownMenuItem(value: c, child: Text(label));
          }).toList(),
          onChanged: (val) {
            setState(() {
              secilenHedef = val!;
              if (val != 'Kilo Koru (Dengede Kal)') {
                secilenZorluk = 'Normal';
              }
            });
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: secilenIdmanGunu,
                dropdownColor: const Color(0xFF0F172A),
                decoration: _inputStili('Weekly Training Days'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: [3, 4, 5, 6].map((int val) => DropdownMenuItem(value: val, child: Text('$val Days / Week'))).toList(),
                onChanged: (val) => setState(() => secilenIdmanGunu = val!),
              ),
            ),
            if (secilenHedef != 'Kilo Koru (Dengede Kal)') ...[
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: secilenZorluk,
                  dropdownColor: const Color(0xFF1A0505),
                  decoration: InputDecoration(
                    labelText: 'Dungeon Difficulty',
                    labelStyle: const TextStyle(color: sysRed, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: const Color(0xFF1A0505),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: sysRed.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: sysRed),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  style: const TextStyle(color: sysRed, fontWeight: FontWeight.bold),
                  items: zorlukSeviyeleri.map((String c) {
                    String label = c;
                    if (c == 'Normal') label = 'Normal';
                    if (c == 'Yüksek') label = 'High';
                    if (c == 'Cehennem') label = 'Hell';
                    if (c == 'Canavar') label = 'Monster';
                    return DropdownMenuItem(value: c, child: Text(label));
                  }).toList(),
                  onChanged: (val) => setState(() => secilenZorluk = val!),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: sysBlue.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.straighten, color: sysBlue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'BODY SCAN MEASUREMENTS (cm - Optional)',
                    style: GoogleFonts.orbitron(
                      color: sysBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: gogusCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputStili('Göğüs / Chest (cm)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: belCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputStili('Bel / Waist (cm)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: kolCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputStili('Kol / Arm (cm)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: bacakCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputStili('Bacak / Thigh (cm)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: DISCIPLINE & GEAR
  // ==========================================
  Widget _buildStep2DisciplineAndGear() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DÖVÜŞ SPORLARI TOGGLE
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: dovusSporuYapiyorMu ? const Color(0xFFEF4444).withValues(alpha: 0.12) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: dovusSporuYapiyorMu ? sysRed : sysBlue.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DÖVÜŞ SPORLARI / BOKS',
                          style: GoogleFonts.orbitron(
                            color: dovusSporuYapiyorMu ? sysRed : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dövüş sporları (Boks, Kickboks, MMA) yapıyor musunuz?',
                          style: TextStyle(color: sysTextMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: dovusSporuYapiyorMu,
                    activeThumbColor: sysRed,
                    onChanged: (val) => setState(() => dovusSporuYapiyorMu = val),
                  ),
                ],
              ),
              if (dovusSporuYapiyorMu) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: secilenDovusBransi,
                  dropdownColor: const Color(0xFF1E0A0A),
                  decoration: InputDecoration(
                    labelText: 'Dövüş Branşı / Combat Style',
                    labelStyle: const TextStyle(color: sysRed),
                    filled: true,
                    fillColor: const Color(0xFF1E0A0A),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysRed), borderRadius: BorderRadius.circular(4)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysRed, width: 2), borderRadius: BorderRadius.circular(4)),
                  ),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: ['Boks', 'Kickboks', 'Muay Thai', 'MMA', 'Güreş / BJJ'].map((String c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) => setState(() => secilenDovusBransi = val!),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          initialValue: secilenEkipman,
          dropdownColor: const Color(0xFF0F172A),
          decoration: _inputStili('Training Facility & Gear'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: const [
            DropdownMenuItem(value: 'Salon', child: Text('Gym (Tam Donanımlı Salon)')),
            DropdownMenuItem(value: 'Ev-Dambil', child: Text('Home / Dumbbells (Ev & Dambıl)')),
            DropdownMenuItem(value: 'Vucut-Agirligi', child: Text('Calisthenics (Vücut Ağırlığı)')),
          ],
          onChanged: (val) {
            setState(() {
              secilenEkipman = val!;
              if (val == 'Vucut-Agirligi') testGirisModuReps = true;
            });
          },
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          initialValue: secilenTecrube,
          dropdownColor: const Color(0xFF0F172A),
          decoration: _inputStili('Hunter Experience Level'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: const [
            DropdownMenuItem(value: 'Başlangıç', child: Text('Rookie (< 6 Ay Tecrübe)')),
            DropdownMenuItem(value: 'Orta', child: Text('Intermediate (6 Ay - 2 Yıl)')),
            DropdownMenuItem(value: 'İleri', child: Text('Veteran (2+ Yıl İleri Seviye)')),
          ],
          onChanged: (val) => setState(() => secilenTecrube = val!),
        ),
        const SizedBox(height: 14),

        Text(
          'Joint Sensitivity / Hassasiyet (Opsiyonel):',
          style: TextStyle(color: sysTextMuted.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: ['Omuz', 'Diz', 'Bel'].map((kisit) {
            bool secili = secilenEklemKisitlari.contains(kisit);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(kisit == 'Omuz' ? 'Shoulder' : (kisit == 'Diz' ? 'Knee' : 'Lower Back')),
                selected: secili,
                selectedColor: sysBlue.withValues(alpha: 0.25),
                checkmarkColor: sysBlue,
                backgroundColor: const Color(0xFF0F172A),
                side: BorderSide(color: secili ? sysBlue : Colors.white24),
                labelStyle: TextStyle(
                  color: secili ? sysBlue : sysTextMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (bool sel) {
                  setState(() {
                    if (sel) {
                      secilenEklemKisitlari.add(kisit);
                    } else {
                      secilenEklemKisitlari.remove(kisit);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: AWAKENING ASSESSMENT
  // ==========================================
  Widget _buildStep3AwakeningTest() {
    final previewRank = _hesaplaCanliRank();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: physicalGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: physicalGold.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: physicalGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    dovusSporuYapiyorMu ? 'COMBAT STAMINA & POWER TEST' : 'INITIAL AWAKENING ASSESSMENT',
                    style: GoogleFonts.orbitron(
                      color: physicalGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dovusSporuYapiyorMu
                    ? 'Dövüş sporcusu rütbenizi belirlemek için patlayıcı güç, 3 dakikalık raund kondisyonu ve core dayanıklılığınızı girin.'
                    : 'Başlangıç rütbenizi ve kişisel antrenman programınızı oluşturmak için mevcut gücünüzü girin (İsteğe bağlı, boş bırakılırsa E-Rank atanır).',
                style: const TextStyle(color: sysTextMuted, fontSize: 11, height: 1.3),
              ),
              const SizedBox(height: 12),

              if (dovusSporuYapiyorMu) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: patlayiciSinavCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputStili('Patlayıcı Şınav (Max Reps)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: burpeeCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputStili('3 Dk Burpee (Kondisyon)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: plankCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputStili('Max Plank (Saniye)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: combatBarfiksCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputStili('Max Barfiks (Pull-up)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => testGirisModuReps = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: !testGirisModuReps ? physicalGold.withValues(alpha: 0.2) : Colors.transparent,
                            border: Border.all(color: !testGirisModuReps ? physicalGold : Colors.white24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'BARBELL / DB 1RM',
                              style: TextStyle(
                                color: !testGirisModuReps ? physicalGold : sysTextMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => testGirisModuReps = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: testGirisModuReps ? physicalGold.withValues(alpha: 0.2) : Colors.transparent,
                            border: Border.all(color: testGirisModuReps ? physicalGold : Colors.white24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'CALISTHENICS REPS',
                              style: TextStyle(
                                color: testGirisModuReps ? physicalGold : sysTextMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!testGirisModuReps) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: benchCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputStili('Bench 1RM (kg)'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: squatCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputStili('Squat 1RM (kg)'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: deadliftCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputStili('Deadlift (kg)'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pushupCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputStili('Max Push-ups'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: bwSquatCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputStili('Max Air Squats'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: pullupCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputStili('Max Pull-ups'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 14),

              // Live Rank Preview Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: physicalGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dovusSporuYapiyorMu ? 'COMBAT RANK:' : 'PROJECTED RANK:',
                      style: const TextStyle(color: sysTextMuted, fontSize: 11),
                    ),
                    Text(
                      previewRank,
                      style: GoogleFonts.orbitron(
                        color: physicalGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FOOTER NAVIGATION
  // ==========================================
  Widget _buildNavigationFooter() {
    return Row(
      children: [
        if (_aktifAdim > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _geriAdim,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: sysBlue.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('<- PREVIOUS', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _aktifAdim == 3 ? _analiziBaslat : _ileriAdim,
            style: ElevatedButton.styleFrom(
              backgroundColor: _aktifAdim == 3 ? physicalGold.withValues(alpha: 0.25) : sysBlue.withValues(alpha: 0.15),
              side: BorderSide(color: _aktifAdim == 3 ? physicalGold : sysBlue, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              _aktifAdim == 3 ? 'AWAKEN THE SYSTEM' : 'NEXT PHASE ->',
              style: TextStyle(
                color: _aktifAdim == 3 ? physicalGold : sysBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputStili(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: sysTextMuted, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: sysBlue),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}