// lib/screens/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 

import '../controllers/system_memory.dart'; 
import '../core/services/gemini_service.dart';
import 'welcome_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String secilenCinsiyet = 'Erkek';
  String secilenHedef = 'Kilo Ver (Yağ Yak)';
  String secilenZorluk = 'Normal';
  int secilenIdmanGunu = 3;

  DateTime? secilenTarih;
  Uint8List? secilenFotoByte; 

  final TextEditingController boyCtrl = TextEditingController();
  final TextEditingController kiloCtrl = TextEditingController();
  
  // YENİ: İsim girişi için kontrolcü
  final TextEditingController isimCtrl = TextEditingController(); 

  // Gemini API Key kontrolcüsü
  final TextEditingController apiKeyCtrl = TextEditingController();
  bool _isObscure = true;
  bool _isTestingApi = false;
  String? _apiTestSonucu;
  bool _apiTestBasarili = false;

  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 

  Future<void> _testApiKey() async {
    final key = apiKeyCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Önce bir API anahtarı giriniz!'), backgroundColor: sysRed),
      );
      return;
    }

    // Anahtarı önce SystemMemory'ye kaydet, yoksa servis bulamaz
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
    boyCtrl.dispose();
    kiloCtrl.dispose();
    isimCtrl.dispose();
    apiKeyCtrl.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİSTEM: Avatar Verisi Algılandı!'), backgroundColor: Colors.green));
      }
    }
  }

  Future<void> _tarihSec() async {
    DateTime? secilen = await showDatePicker(
      context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: sysBlue, onPrimary: Colors.black, surface: Color(0xFF0F172A), onSurface: Colors.white),
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

  Future<void> _analiziBaslat() async {
    if (secilenTarih != null && boyCtrl.text.isNotEmpty && kiloCtrl.text.isNotEmpty) {
      
      // İsim girişi boşsa "PLAYER" olarak kaydet, doluysa girilen ismi kaydet
      if (isimCtrl.text.trim().isNotEmpty) {
        SystemMemory.oyuncuIsmi = isimCtrl.text.trim().toUpperCase();
      } else {
        SystemMemory.oyuncuIsmi = "PLAYER";
      }

      double boy = double.tryParse(boyCtrl.text.replaceAll(',', '.')) ?? 175.0;
      double kilo = double.tryParse(kiloCtrl.text.replaceAll(',', '.')) ?? 70.0;

      // Gemini API Key kaydı (İsteğe bağlı)
      if (apiKeyCtrl.text.trim().isNotEmpty) {
        SystemMemory.geminiApiKey = apiKeyCtrl.text.trim();
      }

      SystemMemory.oyuncuyuAnalizEt(secilenCinsiyet, secilenTarih!, boy, kilo, secilenHedef, secilenZorluk, secilenFotoByte, secilenIdmanGunu);

      // API anahtarı girildiyse → Sistem uyanış testi yap
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

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİSTEM: Doğum tarihi, boy ve kilo verileri zorunludur!'), backgroundColor: sysRed));
    }
  }

  /// Gemini bağlantı sonucunu sinematik RPG tarzı bir dialog ile gösterir.
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
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (basarili ? sysBlue : sysRed).withValues(alpha: 0.15),
                  side: BorderSide(color: basarili ? sysBlue : sysRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  basarili ? 'ENTER THE SYSTEM' : 'ACKNOWLEDGE',
                  style: TextStyle(
                    color: basarili ? sysBlue : sysRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> zorlukSeviyeleri = [];
    if (secilenHedef == 'Kilo Ver (Yağ Yak)') {
      zorlukSeviyeleri = ['Normal', 'Yüksek', 'Cehennem'];
    } else if (secilenHedef == 'Kilo Al (Kas İnşa Et)') {
      zorlukSeviyeleri = ['Normal', 'Yüksek', 'Canavar'];
    }

    return Scaffold(
      backgroundColor: sysDarkBg, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14).withValues(alpha: 0.85), 
              borderRadius: BorderRadius.circular(4), 
              border: Border.all(color: sysBlue.withValues(alpha: 0.4), width: 1.0), 
              boxShadow: [BoxShadow(color: sysBlue.withValues(alpha: 0.08), blurRadius: 10, spreadRadius: 1)]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _fotoSec,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          border: Border.all(color: secilenFotoByte != null ? sysBlue : sysTextMuted, width: 2),
                          image: secilenFotoByte != null ? DecorationImage(image: MemoryImage(secilenFotoByte!), fit: BoxFit.cover) : null,
                          color: const Color(0xFF0F172A),
                        ),
                        child: secilenFotoByte == null ? Icon(Icons.person, color: sysTextMuted.withValues(alpha: 0.5), size: 40) : null, 
                      ),
                      Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: sysBlue, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.black, size: 16))
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text('SYSTEM INIT', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
                const SizedBox(height: 20),

                // YENİ: İSİM GİRİŞ ALANI
                TextField(
                  controller: isimCtrl, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
                  decoration: _inputStili('Hunter Name (Optional)')
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(initialValue: secilenCinsiyet, dropdownColor: const Color(0xFF0F172A), decoration: _inputStili('Gender'), style: const TextStyle(color: Colors.white), items: ['Erkek', 'Kadın'].map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setState(() => secilenCinsiyet = val!))),
                    const SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        onTap: _tarihSec,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: sysBlue.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)), 
                          child: Text(
                            secilenTarih == null ? 'Birth Date' : '${secilenTarih!.day.toString().padLeft(2,'0')}.${secilenTarih!.month.toString().padLeft(2,'0')}.${secilenTarih!.year}',
                            style: TextStyle(color: secilenTarih == null ? sysTextMuted : Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: TextField(controller: boyCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputStili('Height (cm)'))),
                    const SizedBox(width: 15),
                    Expanded(child: TextField(controller: kiloCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputStili('Weight (kg)'))),
                  ],
                ),
                const SizedBox(height: 30),

                DropdownButtonFormField<String>(
                  initialValue: secilenHedef, dropdownColor: const Color(0xFF0F172A), decoration: _inputStili('System Objective'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: ['Kilo Ver (Yağ Yak)', 'Kilo Koru (Dengede Kal)', 'Kilo Al (Kas İnşa Et)'].map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) { setState(() { secilenHedef = val!; if (val != 'Kilo Koru (Dengede Kal)') { secilenZorluk = 'Normal'; } }); },
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<int>(
                  initialValue: secilenIdmanGunu, dropdownColor: const Color(0xFF0F172A), decoration: _inputStili('Weekly Training Days'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: [3, 4, 5, 6].map((int val) => DropdownMenuItem(value: val, child: Text('$val Days / Week'))).toList(),
                  onChanged: (val) { setState(() { secilenIdmanGunu = val!; }); },
                ),
                const SizedBox(height: 15),

                if (secilenHedef != 'Kilo Koru (Dengede Kal)')
                  DropdownButtonFormField<String>(
                    initialValue: secilenZorluk, dropdownColor: const Color(0xFF1A0505),
                    decoration: InputDecoration(labelText: 'Dungeon Difficulty', labelStyle: const TextStyle(color: sysRed, fontWeight: FontWeight.bold), filled: true, fillColor: const Color(0xFF1A0505), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysRed.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(4)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysRed), borderRadius: BorderRadius.circular(4))),
                    style: const TextStyle(color: sysRed, fontWeight: FontWeight.bold),
                    items: zorlukSeviyeleri.map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => secilenZorluk = val!),
                  ),
                const SizedBox(height: 15),

                // Gemini API Key (İsteğe Bağlı)
                TextField(
                  controller: apiKeyCtrl,
                  obscureText: _isObscure,
                  style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key (Optional)',
                    labelStyle: const TextStyle(color: sysTextMuted),
                    helperText: 'For System AI Voice & Smart Nutrition (Leave blank for classic mode)',
                    helperStyle: TextStyle(color: sysTextMuted.withValues(alpha: 0.6), fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysBlue), borderRadius: BorderRadius.circular(4)),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, color: sysBlue, size: 20),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _isTestingApi ? null : _testApiKey,
                    icon: _isTestingApi 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: sysBlue))
                        : const Icon(Icons.bolt, size: 16, color: sysBlue),
                    label: Text(
                      _isTestingApi ? 'SİSTEM TEST EDİLİYOR...' : 'TEST SİSTEM BAĞLANTISI',
                      style: const TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
                if (_apiTestSonucu != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _apiTestBasarili ? sysBlue.withValues(alpha: 0.1) : sysRed.withValues(alpha: 0.1),
                      border: Border.all(color: _apiTestBasarili ? sysBlue : sysRed, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_apiTestBasarili ? Icons.check_circle : Icons.error, color: _apiTestBasarili ? sysBlue : sysRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _apiTestSonucu!,
                            style: TextStyle(color: _apiTestBasarili ? Colors.white : sysRed, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: _analiziBaslat, 
                    style: ElevatedButton.styleFrom(backgroundColor: sysBlue.withValues(alpha: 0.1), side: const BorderSide(color: sysBlue), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), 
                    child: const Text('INITIALIZE SYSTEM', style: TextStyle(color: sysBlue, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2))
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStili(String label) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: sysTextMuted), 
      filled: true, fillColor: const Color(0xFF0F172A), 
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)), 
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysBlue), borderRadius: BorderRadius.circular(4))
    );
  }
}