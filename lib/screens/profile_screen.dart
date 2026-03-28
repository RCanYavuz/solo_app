import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data'; // Fotoğraf baytları için eklendi
import 'package:image_picker/image_picker.dart'; // Fotoğraf seçmek için eklendi

import '../controllers/system_memory.dart'; // Yeni adres
import '../widgets/hologram_card.dart';     // Kendi modülümüz!

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  // --- YENİ: FOTOĞRAF GÜNCELLEME FONKSİYONU ---
  Future<void> _fotoGuncelle() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500, maxHeight: 500, imageQuality: 80,
    );

    if (image != null) {
      final Uint8List imgBytes = await image.readAsBytes();
      setState(() {
        // Beyindeki (Memory) fotoğraf baytlarını anında günceller!
        SystemMemory.profilFotoByte = imgBytes; 
      });
      SystemMemory.kaydet(); // Hafızaya anında yazar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SİSTEM: Görüntü Kaydı Güncellendi!'), backgroundColor: Colors.green, duration: Duration(seconds: 1))
        );
      }
    }
  }

  // --- KİLO GÜNCELLEME FONKSİYONU ---
  void _kiloGuncelleDialog() {
    TextEditingController kiloCtrl = TextEditingController(text: SystemMemory.kilo.toString());
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E17), 
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(15)),
          title: Text('KİLO GÜNCELLEMESİ', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text("Güncel kilonuzu girin. Sistem kalori hedefinizi otomatik olarak yeniden hesaplayacaktır.", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: kiloCtrl, keyboardType: TextInputType.number, 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, 
                decoration: InputDecoration(
                  suffixText: 'kg', suffixStyle: const TextStyle(color: Colors.cyanAccent), 
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5))), 
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent))
                )
              ),
            ]
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İPTAL', style: TextStyle(color: Colors.redAccent))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withOpacity(0.2), side: const BorderSide(color: Colors.cyanAccent)), 
              onPressed: () {
                if(kiloCtrl.text.isNotEmpty) {
                  double yeniKilo = double.parse(kiloCtrl.text);
                  setState(() { 
                    SystemMemory.oyuncuyuAnalizEt(SystemMemory.cinsiyet, SystemMemory.dogumTarihi ?? DateTime(2000), SystemMemory.boy, yeniKilo, SystemMemory.aktifHedef, SystemMemory.aktifZorluk, SystemMemory.profilFotoByte); 
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİSTEM: Fiziksel Veriler Güncellendi!'), backgroundColor: Colors.green));
                }
              }, 
              child: const Text('GÜNCELLE', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  String _unvanBelirle(int level) {
    if (level < 5) return "Çaylak Avcı (E-Rank)"; 
    if (level < 10) return "Deneyimli Avcı (C-Rank)";
    if (level < 20) return "Elit Avcı (B-Rank)"; 
    if (level < 50) return "Ulusal Seviye Avcı (A-Rank)";
    return "Gölgelerin Efendisi (S-Rank)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text('OYUNCU KİMLİĞİ', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)), backgroundColor: const Color(0xFF0A0E17), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- AVATAR KISMI ---
            GestureDetector(
              onTap: _fotoGuncelle, // TIKLAYINCA FOTOĞRAF DEĞİŞİR!
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.cyanAccent, width: 2), 
                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20)], 
                  // Hafızadaki baytları okur:
                  image: SystemMemory.profilFotoByte != null ? DecorationImage(image: MemoryImage(SystemMemory.profilFotoByte!), fit: BoxFit.cover) : null, 
                  color: const Color(0xFF111827)
                ),
                child: SystemMemory.profilFotoByte == null ? const Icon(Icons.person, size: 60, color: Colors.cyanAccent) : null,
              ),
            ),
            const SizedBox(height: 15),
            Text('OYUNCU', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3)),
            Text(_unvanBelirle(SystemMemory.level.value), style: const TextStyle(color: Colors.amberAccent, fontSize: 16, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // HologramCard ile saniyeler içinde oluşturulan Fiziksel Kart
            HologramCard(
              neonRenk: Colors.cyanAccent,
              child: Column(
                children: [
                  Row(children: [const Icon(Icons.accessibility_new, color: Colors.cyanAccent), const SizedBox(width: 10), Text("FİZİKSEL DURUM", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold))]), 
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_bilgiSutunu("BOY", "${SystemMemory.boy.toInt()} cm"), _bilgiSutunu("KİLO", "${SystemMemory.kilo} kg"), _bilgiSutunu("YAŞ", "${SystemMemory.yas}")]),
                  const SizedBox(height: 15), const Divider(color: Colors.white12), const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Vücut Sınıfı:", style: TextStyle(color: Colors.white70, fontSize: 16)), Text(SystemMemory.vucutSinifi, style: TextStyle(color: SystemMemory.vucutSinifi.contains("Normal") ? Colors.greenAccent : Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold))])
                ]
              )
            ),
            const SizedBox(height: 20),

            // HologramCard ile saniyeler içinde oluşturulan Protokol Kartı
            HologramCard(
              neonRenk: Colors.purpleAccent,
              child: Column(
                children: [
                  Row(children: [const Icon(Icons.memory, color: Colors.purpleAccent), const SizedBox(width: 10), Text("SİSTEM PROTOKOLÜ", style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold))]), 
                  const SizedBox(height: 20),
                  _protokolSatiri("Görev Amacı", SystemMemory.aktifHedef), const SizedBox(height: 10),
                  _protokolSatiri("Zindan Zorluğu", SystemMemory.aktifZorluk, isDanger: SystemMemory.aktifZorluk == "Cehennem"), const SizedBox(height: 10), const Divider(color: Colors.white12), const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Günlük Kalori Limiti:", style: TextStyle(color: Colors.white70, fontSize: 16)), Row(children: [const Icon(Icons.local_fire_department, color: Colors.amberAccent, size: 20), const SizedBox(width: 5), Text("${SystemMemory.gunlukHedefKalori} Kcal", style: GoogleFonts.orbitron(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold))])])
                ]
              )
            ),
            const SizedBox(height: 30),

            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _kiloGuncelleDialog, icon: const Icon(Icons.monitor_weight_outlined, color: Colors.cyanAccent), label: const Text('FİZİKSEL VERİYİ GÜNCELLE (KİLO)', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111827), padding: const EdgeInsets.symmetric(vertical: 18), side: const BorderSide(color: Colors.cyanAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))))
          ],
        ),
      ),
    );
  }

  Widget _bilgiSutunu(String baslik, String deger) { return Column(children: [Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)), const SizedBox(height: 5), Text(deger, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]); }
  Widget _protokolSatiri(String baslik, String deger, {bool isDanger = false}) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 15)), Text(deger, style: TextStyle(color: isDanger ? Colors.redAccent : Colors.white, fontSize: 15, fontWeight: FontWeight.bold))]); }
}