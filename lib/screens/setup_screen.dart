// lib/screens/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 

import '../controllers/system_memory.dart'; 
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

  DateTime? secilenTarih;
  Uint8List? secilenFotoByte; 

  final TextEditingController boyCtrl = TextEditingController();
  final TextEditingController kiloCtrl = TextEditingController();

  // --- ORİJİNAL SİSTEM RENKLERİ ---
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 

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
            dialogBackgroundColor: sysDarkBg,
          ),
          child: child!,
        );
      },
    );

    if (secilen != null) {
      setState(() { secilenTarih = secilen; });
    }
  }

  void _analiziBaslat() {
    // YENİ: FOTOĞRAF ZORUNLULUĞU KALDIRILDI! Sadece temel bilgiler (Boy/Kilo/Tarih) şart.
    if (secilenTarih != null && boyCtrl.text.isNotEmpty && kiloCtrl.text.isNotEmpty) {
      double boy = double.parse(boyCtrl.text);
      double kilo = double.parse(kiloCtrl.text);

      SystemMemory.oyuncuyuAnalizEt(secilenCinsiyet, secilenTarih!, boy, kilo, secilenHedef, secilenZorluk, secilenFotoByte);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİSTEM: Doğum tarihi, boy ve kilo verileri zorunludur!'), backgroundColor: sysRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> zorlukSeviyeleri = [];
    if (secilenHedef == 'Kilo Ver (Yağ Yak)') zorlukSeviyeleri = ['Normal', 'Yüksek', 'Cehennem'];
    else if (secilenHedef == 'Kilo Al (Kas İnşa Et)') zorlukSeviyeleri = ['Normal', 'Yüksek', 'Canavar'];

    return Scaffold(
      backgroundColor: sysDarkBg, // Zifiri Karanlık
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14).withOpacity(0.85), // Cam Tasarımı
              borderRadius: BorderRadius.circular(4), // Keskin köşeler
              border: Border.all(color: sysBlue.withOpacity(0.4), width: 1.0), 
              boxShadow: [BoxShadow(color: sysBlue.withOpacity(0.08), blurRadius: 10, spreadRadius: 1)]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- AVATAR SEÇİM ALANI ---
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
                        child: secilenFotoByte == null ? Icon(Icons.person, color: sysTextMuted.withOpacity(0.5), size: 40) : null, // Kırmızı uyarı ikonu kaldırıldı, sade insan ikonu eklendi.
                      ),
                      Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: sysBlue, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.black, size: 16))
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text('SYSTEM INIT', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
                const SizedBox(height: 20),

                // 1. SATIR: CİNSİYET VE DOĞUM TARİHİ
                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(value: secilenCinsiyet, dropdownColor: const Color(0xFF0F172A), decoration: _inputStili('Gender'), style: const TextStyle(color: Colors.white), items: ['Erkek', 'Kadın'].map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setState(() => secilenCinsiyet = val!))),
                    const SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        onTap: _tarihSec,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: sysBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)), // Keskin
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

                // 2. SATIR: BOY VE KİLO
                Row(
                  children: [
                    Expanded(child: TextField(controller: boyCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputStili('Height (cm)'))),
                    const SizedBox(width: 15),
                    Expanded(child: TextField(controller: kiloCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputStili('Weight (kg)'))),
                  ],
                ),
                const SizedBox(height: 30),

                // 3. HEDEFLER
                DropdownButtonFormField<String>(
                  value: secilenHedef, dropdownColor: const Color(0xFF0F172A), decoration: _inputStili('System Objective'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: ['Kilo Ver (Yağ Yak)', 'Kilo Koru (Dengede Kal)', 'Kilo Al (Kas İnşa Et)'].map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) { setState(() { secilenHedef = val!; if (val != 'Kilo Koru (Dengede Kal)') secilenZorluk = 'Normal'; }); },
                ),
                const SizedBox(height: 15),

                if (secilenHedef != 'Kilo Koru (Dengede Kal)')
                  DropdownButtonFormField<String>(
                    value: secilenZorluk, dropdownColor: const Color(0xFF1A0505),
                    decoration: InputDecoration(labelText: 'Dungeon Difficulty', labelStyle: const TextStyle(color: sysRed, fontWeight: FontWeight.bold), filled: true, fillColor: const Color(0xFF1A0505), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysRed.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysRed), borderRadius: BorderRadius.circular(4))),
                    style: const TextStyle(color: sysRed, fontWeight: FontWeight.bold),
                    items: zorlukSeviyeleri.map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => secilenZorluk = val!),
                  ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: _analiziBaslat, 
                    style: ElevatedButton.styleFrom(backgroundColor: sysBlue.withOpacity(0.1), side: const BorderSide(color: sysBlue), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), 
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
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)), 
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: sysBlue), borderRadius: BorderRadius.circular(4))
    );
  }
}