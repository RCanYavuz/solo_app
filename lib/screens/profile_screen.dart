// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 

import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 

  Future<void> _fotoGuncelle() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500, maxHeight: 500, imageQuality: 80,
    );
    
    if (image != null) {
      final Uint8List fotoBytes = await image.readAsBytes();
      setState(() { 
        SystemMemory.profilFotoByte = fotoBytes; 
      });
      SystemMemory.kaydet(); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('SYSTEM: Avatar Updated Successfully!'), 
          backgroundColor: Colors.green
        ));
      }
    }
  }

  void _kiloGuncelleDialog() {
    TextEditingController kiloCtrl = TextEditingController(text: SystemMemory.kilo.toString());
    
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withOpacity(0.95), 
          shape: RoundedRectangleBorder(side: const BorderSide(color: sysBlue, width: 1), borderRadius: BorderRadius.circular(4)),
          title: Text('SYSTEM WEIGH-IN', style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text("The System will analyze your current mass and apply rewards or penalties. Do you confirm?", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: kiloCtrl, keyboardType: TextInputType.number, 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, 
                decoration: InputDecoration(
                  suffixText: 'kg', suffixStyle: const TextStyle(color: sysBlue), 
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withOpacity(0.5))), 
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue))
                )
              ),
            ]
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sysBlue.withOpacity(0.1), side: const BorderSide(color: sysBlue)), 
              onPressed: () {
                if(kiloCtrl.text.isNotEmpty) {
                  double yeniKilo = double.parse(kiloCtrl.text);
                  String rapor = SystemMemory.tartiGuncelle(yeniKilo);
                  setState(() {});
                  Navigator.pop(context);
                  _tartiRaporuGoster(rapor);
                }
              }, 
              child: const Text('WEIGH-IN', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _tartiRaporuGoster(String rapor) {
    showDialog(
      context: context, 
      builder: (context) {
        bool cezaVarMi = rapor.contains("PENALTY");
        Color dialogRenk = cezaVarMi ? const Color(0xFFEF4444) : sysBlue;

        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withOpacity(0.95), 
          shape: RoundedRectangleBorder(side: BorderSide(color: dialogRenk, width: 1), borderRadius: BorderRadius.circular(4)),
          title: Text(cezaVarMi ? 'WARNING' : 'ACHIEVEMENT', style: GoogleFonts.orbitron(color: dialogRenk, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text(rapor, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: dialogRenk.withOpacity(0.1), side: BorderSide(color: dialogRenk)), 
              onPressed: () => Navigator.pop(context), 
              child: Text('OK', style: TextStyle(color: dialogRenk, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _kiloGecmisiGoster() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF070B14),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: sysBlue.withOpacity(0.5), width: 2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('WEIGHT LOG', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 15),
              SystemMemory.kiloGecmisi.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text("No records found.", style: TextStyle(color: sysTextMuted)))
              : Expanded(
                  child: ListView.builder(
                    itemCount: SystemMemory.kiloGecmisi.length,
                    itemBuilder: (context, index) {
                      int reversedIndex = SystemMemory.kiloGecmisi.length - 1 - index;
                      var kayit = SystemMemory.kiloGecmisi[reversedIndex];
                      
                      DateTime t = DateTime.parse(kayit['tarih']);
                      String tarihFormatli = "${t.day.toString().padLeft(2,'0')}.${t.month.toString().padLeft(2,'0')}.${t.year}";
                      
                      // YENİ: Geçmişte kalori verisi yoksa hata vermemesi için "?? 0" ile korunuyor.
                      int kalori = kayit['kalori'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: const Color(0xFF030712), border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(4)),
                        child: ListTile(
                          leading: const Icon(Icons.monitor_weight, color: sysTextMuted),
                          title: Text(tarihFormatli, style: const TextStyle(color: sysTextMuted, fontSize: 12)),
                          subtitle: Text('Energy: $kalori Kcal', style: const TextStyle(color: sysBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                          trailing: Text('${kayit['kilo']} kg', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  String _unvanBelirle(int level) {
    if (level < 5) return "Rookie Hunter (E-Rank)"; 
    if (level < 10) return "Experienced Hunter (C-Rank)";
    if (level < 20) return "Elite Hunter (B-Rank)"; 
    if (level < 50) return "National Level Hunter (A-Rank)";
    return "Shadow Monarch (S-Rank)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg,
      appBar: AppBar(
        title: Text('P L A Y E R   I N F O', style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _fotoGuncelle, 
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4), 
                      border: Border.all(color: sysBlue, width: 1.5),
                      boxShadow: [BoxShadow(color: sysBlue.withOpacity(0.1), blurRadius: 20)],
                      image: SystemMemory.profilFotoByte != null ? DecorationImage(image: MemoryImage(SystemMemory.profilFotoByte!), fit: BoxFit.cover) : null,
                      color: const Color(0xFF0F172A)
                    ),
                    child: SystemMemory.profilFotoByte == null ? const Icon(Icons.person, size: 50, color: sysBlue) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4), 
                    decoration: const BoxDecoration(color: sysBlue, shape: BoxShape.circle), 
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 14)
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text('PLAYER', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
            Text(_unvanBelirle(SystemMemory.level.value), style: const TextStyle(color: sysTextMuted, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            HologramCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.accessibility_new, color: sysBlue, size: 18), const SizedBox(width: 10), Text("PHYSICAL SPECS", style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2))]),
                      IconButton(icon: const Icon(Icons.history, color: sysBlue, size: 20), onPressed: _kiloGecmisiGoster, tooltip: 'Weight Log')
                    ],
                  ), 
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bilgiSutunu("HEIGHT", "${SystemMemory.boy.toInt()} cm", sysTextMuted),
                      _bilgiSutunu("WEIGHT", "${SystemMemory.kilo} kg", sysTextMuted),
                      _bilgiSutunu("AGE", "${SystemMemory.yas}", sysTextMuted),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Body Class:", style: TextStyle(color: sysTextMuted, fontSize: 14)),
                      Text(SystemMemory.vucutSinifi, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
                    ],
                  )
                ]
              )
            ),
            const SizedBox(height: 20),

            HologramCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.memory, color: sysBlue, size: 18),
                      const SizedBox(width: 10),
                      Text("SYSTEM PROTOCOL", style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ), 
                  const SizedBox(height: 20),
                  _protokolSatiri("Main Objective", SystemMemory.aktifHedef, sysTextMuted),
                  const SizedBox(height: 10),
                  _protokolSatiri("Dungeon Difficulty", SystemMemory.aktifZorluk, sysTextMuted, isDanger: SystemMemory.aktifZorluk == "Cehennem"),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Calorie Limit:", style: TextStyle(color: sysTextMuted, fontSize: 14)),
                      Text("${SystemMemory.gunlukHedefKalori} Kcal", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                    ],
                  )
                ]
              )
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _kiloGuncelleDialog,
                icon: const Icon(Icons.monitor_weight, color: sysBlue, size: 16),
                label: const Text('SYSTEM WEIGH-IN', style: TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sysBlue.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: sysBlue, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _bilgiSutunu(String baslik, String deger, Color muted) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(deger, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _protokolSatiri(String baslik, String deger, Color muted, {bool isDanger = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: TextStyle(color: muted, fontSize: 14)),
        Text(deger, style: TextStyle(color: isDanger ? const Color(0xFFEF4444) : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}