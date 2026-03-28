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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİSTEM: Görüntü Verisi Algılandı!'), backgroundColor: Colors.green));
      }
    }
  }

  Future<void> _tarihSec() async {
    DateTime? secilen = await showDatePicker(
      context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent, onPrimary: Colors.black, surface: Color(0xFF111827), onSurface: Colors.white),
            dialogBackgroundColor: const Color(0xFF0A0E17),
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
    if (secilenTarih != null && boyCtrl.text.isNotEmpty && kiloCtrl.text.isNotEmpty && secilenFotoByte != null) {
      double boy = double.parse(boyCtrl.text);
      double kilo = double.parse(kiloCtrl.text);

      SystemMemory.oyuncuyuAnalizEt(secilenCinsiyet, secilenTarih!, boy, kilo, secilenHedef, secilenZorluk, secilenFotoByte);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİSTEM: Doğum tarihi, boy, kilo ve Fotoğraf zorunludur!'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> zorlukSeviyeleri = [];
    if (secilenHedef == 'Kilo Ver (Yağ Yak)') zorlukSeviyeleri = ['Normal', 'Yüksek', 'Cehennem'];
    else if (secilenHedef == 'Kilo Al (Kas İnşa Et)') zorlukSeviyeleri = ['Normal', 'Yüksek', 'Canavar'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: const Color(0xFF111827).withOpacity(0.9), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.cyanAccent, width: 2), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)]),
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
                          shape: BoxShape.circle, border: Border.all(color: secilenFotoByte != null ? Colors.cyanAccent : Colors.redAccent, width: 2),
                          image: secilenFotoByte != null ? DecorationImage(image: MemoryImage(secilenFotoByte!), fit: BoxFit.cover) : null,
                          color: const Color(0xFF1F2937),
                          boxShadow: [BoxShadow(color: (secilenFotoByte != null ? Colors.cyanAccent : Colors.redAccent).withOpacity(0.3), blurRadius: 15)]
                        ),
                        child: secilenFotoByte == null ? Icon(Icons.add_a_photo, color: Colors.redAccent.withOpacity(0.5), size: 40) : null,
                      ),
                      Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.black, size: 16))
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text('BEDEN TARAMASI', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 20),

                // 1. SATIR: CİNSİYET VE DOĞUM TARİHİ
                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(value: secilenCinsiyet, dropdownColor: const Color(0xFF1F2937), decoration: _inputStili('Cinsiyet'), style: const TextStyle(color: Colors.white), items: ['Erkek', 'Kadın'].map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setState(() => secilenCinsiyet = val!))),
                    const SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        onTap: _tarihSec,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                          decoration: BoxDecoration(color: const Color(0xFF1F2937), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)), borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            secilenTarih == null ? 'Doğum Tarihi' : '${secilenTarih!.day.toString().padLeft(2,'0')}.${secilenTarih!.month.toString().padLeft(2,'0')}.${secilenTarih!.year}',
                            style: TextStyle(color: secilenTarih == null ? Colors.cyanAccent : Colors.white, fontSize: 16),
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
                    Expanded(child: TextField(controller: boyCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputStili('Boy (cm)'))),
                    const SizedBox(width: 15),
                    Expanded(child: TextField(controller: kiloCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputStili('Kilo (kg)'))),
                  ],
                ),
                const SizedBox(height: 30),

                // 3. HEDEFLER
                DropdownButtonFormField<String>(
                  value: secilenHedef, dropdownColor: const Color(0xFF1F2937), decoration: _inputStili('Sistem Hedefi'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: ['Kilo Ver (Yağ Yak)', 'Kilo Koru (Dengede Kal)', 'Kilo Al (Kas İnşa Et)'].map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) { setState(() { secilenHedef = val!; if (val != 'Kilo Koru (Dengede Kal)') secilenZorluk = 'Normal'; }); },
                ),
                const SizedBox(height: 15),

                if (secilenHedef != 'Kilo Koru (Dengede Kal)')
                  DropdownButtonFormField<String>(
                    value: secilenZorluk, dropdownColor: const Color(0xFF1A0505),
                    decoration: InputDecoration(labelText: 'Zindan Zorluğu', labelStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold), filled: true, fillColor: const Color(0xFF1A0505), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent))),
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    items: zorlukSeviyeleri.map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => secilenZorluk = val!),
                  ),
                const SizedBox(height: 30),

                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _analiziBaslat, style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withOpacity(0.2), side: const BorderSide(color: Colors.cyanAccent), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('ANALİZİ BAŞLAT', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2))))
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStili(String label) {
    return InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.cyanAccent), filled: true, fillColor: const Color(0xFF1F2937), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)));
  }
}