// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 

import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 
  static const Color mentalPurple = Color(0xFFA060E0); 
  static const Color bloodRed = Color(0xFFDC2626); 
  static const Color physicalGold = Color(0xFFB08D57);

  String _hedefIngilizce(String tr) {
    if (tr == 'Kilo Ver (Yağ Yak)') return 'Lose Weight';
    if (tr == 'Kilo Al (Kas İnşa Et)') return 'Build Muscle';
    return tr;
  }

  String _zorlukIngilizce(String tr) {
    if (tr == 'Normal') return 'Normal';
    if (tr == 'Yüksek') return 'Hard';
    if (tr == 'Cehennem') return 'Hell';
    if (tr == 'Canavar') return 'Monster';
    return tr;
  }

  Future<void> _fotoGuncelle() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500, 
      maxHeight: 500, 
      imageQuality: 80,
    );
    
    if (image != null) {
      final Uint8List fotoBytes = await image.readAsBytes();
      setState(() { 
        SystemMemory.profilFotoByte = fotoBytes; 
      });
      SystemMemory.kaydet(); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SYSTEM: Avatar Updated Successfully!'), 
            backgroundColor: Colors.green
          )
        );
      }
    }
  }

  void _isimGuncelleDialog() {
    TextEditingController isimCtrl = TextEditingController(text: SystemMemory.oyuncuIsmi);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withOpacity(0.95),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: sysBlue, width: 1), 
            borderRadius: BorderRadius.circular(4)
          ),
          title: Text(
            'RENAME HUNTER', 
            style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16)
          ),
          content: TextField(
            controller: isimCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: sysBlue.withOpacity(0.5))
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: sysBlue)
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('CANCEL', style: TextStyle(color: sysTextMuted))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sysBlue.withOpacity(0.1), 
                side: const BorderSide(color: sysBlue)
              ),
              onPressed: () {
                setState(() {
                  SystemMemory.oyuncuIsmi = isimCtrl.text.isNotEmpty 
                      ? isimCtrl.text.trim().toUpperCase() 
                      : "PLAYER";
                });
                SystemMemory.kaydet();
                Navigator.pop(context);
              },
              child: const Text('CONFIRM', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  void _protokolGuncelleDialog() {
    String geciciHedef = SystemMemory.aktifHedef;
    String geciciZorluk = SystemMemory.aktifZorluk;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withOpacity(0.95), 
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: sysBlue, width: 1), 
                borderRadius: BorderRadius.circular(4)
              ),
              title: Text(
                'OVERRIDE PROTOCOL', 
                style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Change your Main Objective:", 
                    style: TextStyle(color: sysTextMuted, fontSize: 12)
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: geciciHedef == "Bilinmiyor" ? null : geciciHedef,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: sysBlue.withOpacity(0.5))
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: sysBlue)
                      ),
                    ),
                    items: ['Kilo Ver (Yağ Yak)', 'Kilo Al (Kas İnşa Et)'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value, 
                        child: Text(_hedefIngilizce(value))
                      );
                    }).toList(),
                    onChanged: (yeniDeger) {
                      setDialogState(() {
                        geciciHedef = yeniDeger!;
                        geciciZorluk = "Normal"; 
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Change Dungeon Difficulty:", 
                    style: TextStyle(color: sysTextMuted, fontSize: 12)
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: geciciZorluk == "Bilinmiyor" ? null : geciciZorluk,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: sysBlue.withOpacity(0.5))
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: sysBlue)
                      ),
                    ),
                    items: (geciciHedef == 'Kilo Ver (Yağ Yak)' 
                            ? ['Normal', 'Yüksek', 'Cehennem'] 
                            : ['Normal', 'Yüksek', 'Canavar']).map((String value) {
                      return DropdownMenuItem<String>(
                        value: value, 
                        child: Text(
                          _zorlukIngilizce(value), 
                          style: TextStyle(
                            color: value == 'Cehennem' || value == 'Canavar' 
                                ? const Color(0xFFEF4444) 
                                : Colors.white
                          )
                        )
                      );
                    }).toList(),
                    onChanged: (yeniDeger) {
                      setDialogState(() { 
                        geciciZorluk = yeniDeger!; 
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('CANCEL', style: TextStyle(color: sysTextMuted))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysBlue.withOpacity(0.1), 
                    side: const BorderSide(color: sysBlue)
                  ), 
                  onPressed: () {
                    SystemMemory.protokolGuncelle(geciciHedef, geciciZorluk);
                    setState(() {}); 
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SYSTEM: Protocol Overridden! Calories Recalculated.'),
                        backgroundColor: sysBlue, 
                        duration: Duration(seconds: 2),
                      )
                    );
                  }, 
                  child: const Text('OVERRIDE', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold))
                )
              ],
            );
          }
        );
      }
    );
  }

  void _kiloGuncelleDialog() {
    TextEditingController kiloCtrl = TextEditingController(text: SystemMemory.kilo.toString());
    
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withOpacity(0.95), 
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: sysBlue, width: 1), 
            borderRadius: BorderRadius.circular(4)
          ),
          title: Text(
            'SYSTEM WEIGH-IN', 
            style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text(
                "The System will analyze your current mass and apply rewards or penalties. Do you confirm?", 
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: kiloCtrl, 
                keyboardType: TextInputType.number, 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), 
                textAlign: TextAlign.center, 
                decoration: InputDecoration(
                  suffixText: 'kg', 
                  suffixStyle: const TextStyle(color: sysBlue), 
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: sysBlue.withOpacity(0.5))
                  ), 
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: sysBlue)
                  )
                )
              ),
            ]
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8)))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sysBlue.withOpacity(0.1), 
                side: const BorderSide(color: sysBlue)
              ), 
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
          shape: RoundedRectangleBorder(
            side: BorderSide(color: dialogRenk, width: 1), 
            borderRadius: BorderRadius.circular(4)
          ),
          title: Text(
            cezaVarMi ? 'WARNING' : 'ACHIEVEMENT', 
            style: GoogleFonts.orbitron(color: dialogRenk, fontWeight: FontWeight.bold, fontSize: 16)
          ),
          content: Text(
            rapor, 
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogRenk.withOpacity(0.1), 
                side: BorderSide(color: dialogRenk)
              ), 
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15))
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: sysBlue.withOpacity(0.5), width: 2))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WEIGHT LOG', 
                style: GoogleFonts.orbitron(color: sysBlue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)
              ),
              const SizedBox(height: 15),
              SystemMemory.kiloGecmisi.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20), 
                  child: Text("No records found.", style: TextStyle(color: sysTextMuted))
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: SystemMemory.kiloGecmisi.length,
                    itemBuilder: (context, index) {
                      // Ters sıralama (en yeni en üstte)
                      int reversedIndex = SystemMemory.kiloGecmisi.length - 1 - index;
                      var kayit = SystemMemory.kiloGecmisi[reversedIndex];
                      
                      DateTime t = DateTime.parse(kayit['tarih']);
                      String tarihFormatli = "${t.day.toString().padLeft(2,'0')}.${t.month.toString().padLeft(2,'0')}.${t.year}";
                      int kalori = kayit['kalori'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF030712), 
                          border: Border.all(color: Colors.white12), 
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.monitor_weight, color: sysTextMuted),
                          title: Text(tarihFormatli, style: const TextStyle(color: sysTextMuted, fontSize: 12)),
                          subtitle: Text(
                            'Energy: $kalori Kcal', 
                            style: const TextStyle(color: sysBlue, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                          trailing: Text(
                            '${kayit['kilo']} kg', 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
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

  // ========================================================
  // ÖZELLEŞTİRİLEBİLİR VE OTOMATİK KIRMIZI GEÇİT KURULUMU
  // ========================================================
  void _kirmiziGecitKurulumDialog() {
    double secilenGun = 7;
    String secilenPlan = "Full Body + Cardio";
    TextEditingController kaloriCtrl = TextEditingController(text: SystemMemory.gunlukHedefKalori.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int kazanilacakAP = secilenGun.toInt() * 1;
            int kazanilacakAltin = secilenGun.toInt() * 1500;
            int kazanilacakExp = secilenGun.toInt() * 300;

            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withOpacity(0.95),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: bloodRed, width: 2), 
                borderRadius: BorderRadius.circular(4)
              ),
              title: Row(
                children: [
                  const Icon(Icons.whatshot, color: bloodRed, size: 28),
                  const SizedBox(width: 10),
                  Text('RED GATE SETUP', style: GoogleFonts.orbitron(color: bloodRed, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set your own limits and select a combat protocol.", 
                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      "Survival Duration: ${secilenGun.toInt()} Days", 
                      style: const TextStyle(color: bloodRed, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    Slider(
                      value: secilenGun, 
                      min: 1, 
                      max: 30, 
                      divisions: 29, 
                      activeColor: bloodRed, 
                      inactiveColor: bloodRed.withOpacity(0.2),
                      onChanged: (val) { 
                        setDialogState(() { secilenGun = val; }); 
                      },
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "Hell's Training Protocol:", 
                      style: TextStyle(color: bloodRed, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: secilenPlan,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: bloodRed.withOpacity(0.5))
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: bloodRed)
                        )
                      ),
                      items: ['Full Body + Cardio', 'Push / Pull / Legs', 'Saitama Hell'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (yeniDeger) { 
                        setDialogState(() { secilenPlan = yeniDeger!; }); 
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    const Text(
                      "Hell's Calorie Limit:", 
                      style: TextStyle(color: bloodRed, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: kaloriCtrl, 
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        suffixText: 'Kcal', 
                        suffixStyle: const TextStyle(color: bloodRed),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: bloodRed.withOpacity(0.5))
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: bloodRed)
                        )
                      )
                    ),
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(10), 
                      decoration: BoxDecoration(
                        color: bloodRed.withOpacity(0.1), 
                        border: Border.all(color: bloodRed.withOpacity(0.3)), 
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: const Text(
                        "INFO: Your normal plan is backed up. The System will forcefully assign you the chosen Training Protocol every single day of this hell.", 
                        style: TextStyle(color: sysTextMuted, fontSize: 11, fontStyle: FontStyle.italic)
                      ),
                    ),
                    const SizedBox(height: 15),

                    Text(
                      "EXPECTED CLEAR REWARD", 
                      style: GoogleFonts.orbitron(color: physicalGold, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "+ $kazanilacakAP AP\n+ $kazanilacakAltin Gold\n+ $kazanilacakExp EXP", 
                      style: GoogleFonts.rajdhani(color: physicalGold, fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('CANCEL', style: TextStyle(color: sysTextMuted))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bloodRed.withOpacity(0.2), 
                    side: const BorderSide(color: bloodRed)
                  ),
                  onPressed: () {
                    int finalKalori = int.tryParse(kaloriCtrl.text) ?? SystemMemory.gunlukHedefKalori;
                    SystemMemory.kirmiziGecideGir(secilenGun.toInt(), finalKalori, secilenPlan);
                    setState(() {});
                    Navigator.pop(context);
                    AudioSystem.playTransition();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SYSTEM: Welcome to Hell. Check your Daily Quests!'), 
                        backgroundColor: bloodRed, 
                        duration: Duration(seconds: 3)
                      )
                    );
                  },
                  child: const Text('OPEN GATE', style: TextStyle(color: bloodRed, fontWeight: FontWeight.bold)),
                )
              ],
            );
          }
        );
      }
    );
  }

  // ========================================================
  // YENİ: GEÇİTTEN KAÇIŞ DİYALOGU (ESCAPE CRYSTAL)
  // ========================================================
  void _kirmiziGecittenKacDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withOpacity(0.95),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: sysTextMuted, width: 2), 
            borderRadius: BorderRadius.circular(4)
          ),
          title: Row(
            children: [
              const Icon(Icons.directions_run, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                'USE ESCAPE CRYSTAL?', 
                style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to flee the Red Gate? You will return to the normal world, but you will forfeit all accumulated survival rewards. Cowards get nothing.", 
            style: TextStyle(color: sysTextMuted, fontSize: 14)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('STAY & FIGHT', style: TextStyle(color: bloodRed, fontWeight: FontWeight.bold))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10, 
                side: const BorderSide(color: Colors.white)
              ),
              onPressed: () {
                SystemMemory.kirmiziGecittenCik();
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SYSTEM: You fled the Red Gate. Normal protocol restored.'), 
                    backgroundColor: Colors.white, 
                    duration: Duration(seconds: 3)
                  )
                );
              },
              child: const Text('FLEE GATE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg,
      appBar: AppBar(
        title: Text(
          'P L A Y E R   I N F O', 
          style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)
        ), 
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
                      border: Border.all(color: SystemMemory.redGateAktif ? bloodRed : sysBlue, width: 1.5), 
                      boxShadow: [
                        BoxShadow(
                          color: (SystemMemory.redGateAktif ? bloodRed : sysBlue).withOpacity(0.1), 
                          blurRadius: 20
                        )
                      ], 
                      image: SystemMemory.profilFotoByte != null 
                          ? DecorationImage(image: MemoryImage(SystemMemory.profilFotoByte!), fit: BoxFit.cover) 
                          : null, 
                      color: const Color(0xFF0F172A)
                    ),
                    child: SystemMemory.profilFotoByte == null 
                        ? Icon(Icons.person, size: 50, color: SystemMemory.redGateAktif ? bloodRed : sysBlue) 
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4), 
                    decoration: BoxDecoration(
                      color: SystemMemory.redGateAktif ? bloodRed : sysBlue, 
                      shape: BoxShape.circle
                    ), 
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 14)
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  SystemMemory.oyuncuIsmi, 
                  style: GoogleFonts.orbitron(color: SystemMemory.redGateAktif ? bloodRed : Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)
                ), 
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: sysTextMuted, size: 16), 
                  tooltip: 'Rename Hunter', 
                  onPressed: _isimGuncelleDialog
                )
              ],
            ),
            
            Text(
              _unvanBelirle(SystemMemory.level.value), 
              style: const TextStyle(color: sysTextMuted, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 30),

            HologramCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.accessibility_new, color: sysBlue, size: 18), 
                          const SizedBox(width: 10), 
                          Text("PHYSICAL SPECS", style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2))
                        ]
                      ), 
                      IconButton(
                        icon: const Icon(Icons.history, color: sysBlue, size: 20), 
                        onPressed: _kiloGecmisiGoster, 
                        tooltip: 'Weight Log'
                      )
                    ]
                  ), 
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, 
                    children: [
                      _bilgiSutunu("HEIGHT", "${SystemMemory.boy.toInt()} cm", sysTextMuted), 
                      _bilgiSutunu("WEIGHT", "${SystemMemory.kilo} kg", sysTextMuted), 
                      _bilgiSutunu("AGE", "${SystemMemory.yas}", sysTextMuted)
                    ]
                  ),
                  const SizedBox(height: 15), 
                  const Divider(color: Colors.white12, thickness: 1), 
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      const Text("Body Class:", style: TextStyle(color: sysTextMuted, fontSize: 14)), 
                      Text(SystemMemory.vucutSinifi, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
                    ]
                  )
                ]
              )
            ),
            const SizedBox(height: 20),

            HologramCard(
              neonRenk: SystemMemory.redGateAktif ? bloodRed : (SystemMemory.golgeModuAktif ? mentalPurple : sysBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.memory, color: SystemMemory.redGateAktif ? bloodRed : (SystemMemory.golgeModuAktif ? mentalPurple : sysBlue), size: 18), 
                          const SizedBox(width: 10), 
                          Text(
                            "SYSTEM PROTOCOL", 
                            style: GoogleFonts.orbitron(
                              color: SystemMemory.redGateAktif ? bloodRed : (SystemMemory.golgeModuAktif ? mentalPurple : sysBlue), 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 2
                            )
                          )
                        ]
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_suggest, color: SystemMemory.redGateAktif ? bloodRed : (SystemMemory.golgeModuAktif ? mentalPurple : sysBlue), size: 20), 
                        onPressed: SystemMemory.redGateAktif ? null : _protokolGuncelleDialog, 
                        tooltip: 'Override Protocol'
                      )
                    ],
                  ), 
                  const SizedBox(height: 10),
                  _protokolSatiri("Main Objective", _hedefIngilizce(SystemMemory.aktifHedef), sysTextMuted),
                  const SizedBox(height: 10),
                  _protokolSatiri(
                    "Dungeon Difficulty", 
                    _zorlukIngilizce(SystemMemory.aktifZorluk), 
                    sysTextMuted, 
                    isDanger: SystemMemory.aktifZorluk == "Cehennem" || SystemMemory.aktifZorluk == "Canavar"
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      Text(
                        SystemMemory.redGateAktif ? "Red Gate Calorie Limit:" : "Daily Calorie Limit:", 
                        style: TextStyle(color: SystemMemory.redGateAktif ? bloodRed : sysTextMuted, fontSize: 14)
                      ), 
                      Text(
                        "${SystemMemory.gunlukHedefKalori} Kcal", 
                        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      )
                    ]
                  ),
                  
                  const SizedBox(height: 10), 
                  const Divider(color: Colors.white12, thickness: 1), 
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stealth Mode (Real World Focus)", 
                            style: GoogleFonts.orbitron(color: SystemMemory.redGateAktif ? sysTextMuted : mentalPurple, fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 2),
                          Text(
                            SystemMemory.redGateAktif ? "LOCKED. Cannot hide in Red Gate." : "System Dormant. Penalties suspended.", 
                            style: const TextStyle(color: sysTextMuted, fontSize: 10)
                          ),
                        ],
                      ),
                      Switch(
                        value: SystemMemory.golgeModuAktif,
                        activeColor: mentalPurple, 
                        inactiveThumbColor: sysTextMuted, 
                        inactiveTrackColor: sysDarkBg,
                        onChanged: SystemMemory.redGateAktif ? null : (val) { 
                          setState(() { SystemMemory.golgeModuAktif = val; }); 
                          SystemMemory.kaydet(); 
                          if (val) AudioSystem.playTransition(); 
                        },
                      ),
                    ],
                  )
                ]
              )
            ),
            const SizedBox(height: 30),

            // ==========================================
            // KIRMIZI GEÇİT KARTLARI VE KAÇIŞ BUTONU
            // ==========================================
            if (SystemMemory.redGateAktif)
              Column(
                children: [
                  HologramCard(
                    neonRenk: bloodRed,
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.warning, color: bloodRed, size: 40), 
                          const SizedBox(height: 10),
                          Text(
                            "RED GATE ACTIVE", 
                            style: GoogleFonts.orbitron(color: bloodRed, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)
                          ), 
                          const SizedBox(height: 5),
                          Text(
                            "${SystemMemory.redGateKalanGun} DAYS REMAINING", 
                            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                          ), 
                          const SizedBox(height: 5),
                          const Text(
                            "Survive this hell to claim the ultimate power.", 
                            style: TextStyle(color: sysTextMuted, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // YENİ: KAÇIŞ BUTONU (ESCAPE CRYSTAL)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _kirmiziGecittenKacDialog,
                      icon: const Icon(Icons.directions_run, color: Colors.white, size: 18),
                      label: const Text(
                        'FLEE GATE (GIVE UP)', 
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10, 
                        side: const BorderSide(color: Colors.white54, width: 1), 
                        padding: const EdgeInsets.symmetric(vertical: 15)
                      ),
                    ),
                  )
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _kirmiziGecitKurulumDialog,
                  icon: const Icon(Icons.whatshot, color: bloodRed, size: 20),
                  label: const Text(
                    'OPEN RED GATE (CUSTOM)', 
                    style: TextStyle(color: bloodRed, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bloodRed.withOpacity(0.1), 
                    padding: const EdgeInsets.symmetric(vertical: 20), 
                    side: const BorderSide(color: bloodRed, width: 2), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                  ),
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _kiloGuncelleDialog,
                icon: const Icon(Icons.monitor_weight, color: sysBlue, size: 16),
                label: const Text(
                  'SYSTEM WEIGH-IN', 
                  style: TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sysBlue.withOpacity(0.1), 
                  padding: const EdgeInsets.symmetric(vertical: 18), 
                  side: const BorderSide(color: sysBlue, width: 1), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                ),
              ),
            ),
            const SizedBox(height: 40),
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
        Text(deger, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
      ]
    ); 
  }
  
  Widget _protokolSatiri(String baslik, String deger, Color muted, {bool isDanger = false}) { 
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Text(baslik, style: TextStyle(color: muted, fontSize: 14)), 
        Text(deger, style: TextStyle(color: isDanger ? const Color(0xFFEF4444) : Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
      ]
    ); 
  }
}