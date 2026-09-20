// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; 

import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart'; 
import '../core/services/gemini_service.dart'; 
import 'setup_screen.dart';
import '../core/translation_manager.dart';

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
    return TranslationManager.objectiveTitle(tr);
  }

  String _zorlukIngilizce(String tr) {
    return TranslationManager.difficultyTitle(tr);
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
            content: Text('SYSTEM: Photo Updated Successfully!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)), 
            backgroundColor: Colors.green
          )
        );
      }
    }
  }

  Future<void> _avatarUretimSureci() async {
    if (SystemMemory.profilFotoByte == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SYSTEM: Upload a photo first to Awaken!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), 
          backgroundColor: bloodRed
        )
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: sysBlue, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text('VISUAL AWAKENING', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: sysBlue),
              const SizedBox(height: 20),
              const Text('Analyzing facial features...', style: TextStyle(color: sysTextMuted, fontSize: 12)),
              const SizedBox(height: 5),
              const Text('Generating hyper-realistic prompt...', style: TextStyle(color: sysTextMuted, fontSize: 12)),
            ],
          ),
        );
      }
    );

    String? prompt = await GeminiService.avatarIcinPromptUret(SystemMemory.profilFotoByte!);
    
    if (prompt != null) {
      if (mounted) {
        Navigator.pop(context); // close first dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: mentalPurple, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              title: Text('FORGING AVATAR', style: GoogleFonts.orbitron(color: mentalPurple, fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: mentalPurple),
                  const SizedBox(height: 20),
                  const Text('Connecting to Pollinations AI...', style: TextStyle(color: sysTextMuted, fontSize: 12)),
                  const SizedBox(height: 5),
                  const Text('Forging new identity...', style: TextStyle(color: sysTextMuted, fontSize: 12)),
                ],
              ),
            );
          }
        );
      }
      
      dynamic avatarResult = await GeminiService.avatarUret(prompt);
      
      if (mounted) {
        Navigator.pop(context); // close second dialog
      }

      if (avatarResult is Uint8List) {
        setState(() {
          SystemMemory.avatarFotoByte = avatarResult;
        });
        SystemMemory.kaydet();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('SYSTEM: Avatar Awakened!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), 
              backgroundColor: mentalPurple
            )
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SYSTEM: API Error: $avatarResult', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), 
              backgroundColor: bloodRed
            )
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SYSTEM: Failed to analyze face with Gemini.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), 
            backgroundColor: bloodRed
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
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
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
                borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5))
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
                backgroundColor: sysBlue.withValues(alpha: 0.1), 
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
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95), 
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
                    initialValue: geciciHedef == "Bilinmiyor" ? null : geciciHedef,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5))
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
                    initialValue: geciciZorluk == "Bilinmiyor" ? null : geciciZorluk,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5))
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
                    backgroundColor: sysBlue.withValues(alpha: 0.1), 
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
    TextEditingController boyCtrl = TextEditingController(text: SystemMemory.boy.toInt().toString());
    TextEditingController kiloCtrl = TextEditingController(text: SystemMemory.kilo.toString());
    TextEditingController yasCtrl = TextEditingController(text: SystemMemory.yas.toString());
    
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95), 
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: sysBlue, width: 1), 
            borderRadius: BorderRadius.circular(4)
          ),
          title: Text(
            'SYSTEM UPDATE', 
            style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "The System will analyze your current physical specs and apply rewards or penalties.", 
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)
                ),
                const SizedBox(height: 20),
                _profilGirdiAlani("HEIGHT (cm)", boyCtrl),
                const SizedBox(height: 10),
                _profilGirdiAlani("WEIGHT (kg)", kiloCtrl),
                const SizedBox(height: 10),
                _profilGirdiAlani("AGE", yasCtrl),
              ]
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8)))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sysBlue.withValues(alpha: 0.1), 
                side: const BorderSide(color: sysBlue)
              ), 
              onPressed: () {
                if(kiloCtrl.text.isNotEmpty) {
                  setState(() {
                    if (boyCtrl.text.isNotEmpty) SystemMemory.boy = double.tryParse(boyCtrl.text) ?? SystemMemory.boy;
                    if (yasCtrl.text.isNotEmpty) {
                      int yeniYas = int.tryParse(yasCtrl.text) ?? SystemMemory.yas;
                      SystemMemory.dogumTarihi = DateTime(DateTime.now().year - yeniYas, 1, 1);
                    }
                  });
                  double yeniKilo = double.parse(kiloCtrl.text);
                  String rapor = SystemMemory.tartiGuncelle(yeniKilo);
                  setState(() {});
                  Navigator.pop(context);
                  _tartiRaporuGoster(rapor);
                }
              }, 
              child: const Text('CONFIRM', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold))
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
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95), 
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
                backgroundColor: dialogRenk.withValues(alpha: 0.1), 
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

  Widget _profilGirdiAlani(String etiket, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: etiket,
        labelStyle: const TextStyle(color: sysTextMuted, fontSize: 12),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
      ),
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
            border: Border(top: BorderSide(color: sysBlue.withValues(alpha: 0.5), width: 2))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TranslationManager.get('profile_weight_history_title'), 
                style: GoogleFonts.orbitron(color: sysBlue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)
              ),
              const SizedBox(height: 15),
              SystemMemory.kiloGecmisi.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20), 
                  child: Text(TranslationManager.get('profile_weight_records_empty'), style: const TextStyle(color: sysTextMuted))
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
                            '${TranslationManager.get('diet_energy_kcal')}: $kalori Kcal', 
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
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
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
                      inactiveColor: bloodRed.withValues(alpha: 0.2),
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
                      initialValue: secilenPlan,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: bloodRed.withValues(alpha: 0.5))
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
                          borderSide: BorderSide(color: bloodRed.withValues(alpha: 0.5))
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
                        color: bloodRed.withValues(alpha: 0.1), 
                        border: Border.all(color: bloodRed.withValues(alpha: 0.3)), 
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
                    backgroundColor: bloodRed.withValues(alpha: 0.2), 
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
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
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

  bool _geminiTestEdiliyor = false;

  void _geminiAyarDialog() {
    TextEditingController apiKeyCtrl = TextEditingController(text: SystemMemory.geminiApiKey);
    bool sifreli = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: sysBlue, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              title: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: sysBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'GEMINI CORE PROTOCOL',
                    style: GoogleFonts.orbitron(
                      color: sysBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your Google Gemini API Key to enable AI Meal Decoding and System Voice synthesis.',
                      style: TextStyle(color: sysTextMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: apiKeyCtrl,
                      obscureText: sifreli,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        labelText: 'API KEY (AIza...)',
                        labelStyle: const TextStyle(color: sysTextMuted, fontSize: 12),
                        suffixIcon: IconButton(
                          icon: Icon(sifreli ? Icons.visibility : Icons.visibility_off, color: sysTextMuted, size: 18),
                          onPressed: () => setDialogState(() => sifreli = !sifreli),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: sysBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Active Model: ', style: TextStyle(color: sysTextMuted, fontSize: 12)),
                        Text(
                          SystemMemory.geminiActiveModel,
                          style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sysBlue.withValues(alpha: 0.1),
                          side: const BorderSide(color: sysBlue),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        onPressed: () {
                          SystemMemory.geminiApiKey = apiKeyCtrl.text.trim();
                          SystemMemory.kaydet();
                          Navigator.pop(context);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('SYSTEM: Gemini Key Updated.'), backgroundColor: Colors.green)
                          );
                        },
                        child: const Text('SAVE KEY', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.withValues(alpha: 0.1),
                    side: const BorderSide(color: Colors.amber),
                  ),
                  icon: _geminiTestEdiliyor
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                      : const Icon(Icons.troubleshoot, size: 16, color: Colors.amber),
                  label: const Text('DIAGNOSTIC', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  onPressed: _geminiTestEdiliyor ? null : () async {
                    setDialogState(() => _geminiTestEdiliyor = true);
                    final key = apiKeyCtrl.text.trim();
                    await GeminiService.testBaglantisi(hunterName: SystemMemory.oyuncuIsmi, apiKeyOverride: key);
                    setDialogState(() => _geminiTestEdiliyor = false);

                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _sistemiSifirlaDialog() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95), 
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: bloodRed, width: 2), 
            borderRadius: BorderRadius.circular(4)
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber, color: bloodRed),
              const SizedBox(width: 10),
              Text(
                'SYSTEM PURGE', 
                style: GoogleFonts.orbitron(color: bloodRed, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ],
          ),
          content: const Text(
            "All data (level, gold, history, API key) will be permanently deleted. Are you sure?", 
            style: TextStyle(color: Colors.white, fontSize: 14)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('CANCEL', style: TextStyle(color: sysTextMuted))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bloodRed.withValues(alpha: 0.2), 
                side: const BorderSide(color: bloodRed)
              ), 
              onPressed: () async {
                Navigator.pop(context);
                await SystemMemory.sistemiSifirla();
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SetupScreen()),
                  (route) => false
                );
              }, 
              child: const Text('WIPE DATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  Future<void> _geminiBaglantiTestEt() async {
    if (SystemMemory.geminiApiKey.isEmpty) {
      _geminiAyarDialog();
      return;
    }

    setState(() => _geminiTestEdiliyor = true);

    final sonuc = await GeminiService.testBaglantisi();
    if (!mounted) return;

    setState(() => _geminiTestEdiliyor = false);

    bool basarili = sonuc['basarili'] == true;
    String mesaj = sonuc['mesaj'] ?? '';
    String? model = sonuc['model'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: basarili ? sysBlue : bloodRed, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Row(
            children: [
              Icon(basarili ? Icons.check_circle : Icons.error, color: basarili ? sysBlue : bloodRed, size: 20),
              const SizedBox(width: 8),
              Text(
                basarili ? 'CORE ONLINE' : 'CORE DIAGNOSTIC FAILED',
                style: GoogleFonts.orbitron(
                  color: basarili ? sysBlue : bloodRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (model != null) ...[
                Text('VERIFIED MODEL: $model', style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
              ],
              Text(
                mesaj,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (basarili ? sysBlue : bloodRed).withValues(alpha: 0.15),
                side: BorderSide(color: basarili ? sysBlue : bloodRed),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('ACKNOWLEDGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _yedekExportDialog() {
    final String backupData = SystemMemory.exportBackupJson();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: sysBlue, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Row(
            children: [
              const Icon(Icons.file_download, color: sysBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'SYSTEM ARCHIVE EXPORT',
                style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy your complete Hunter encrypted archive to clipboard. You can restore your stats, level, inventory, and history on any device.',
                style: TextStyle(color: sysTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  border: Border.all(color: sysBlue.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    backupData,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE', style: TextStyle(color: sysTextMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: backupData));
                AudioSystem.playSuccess();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('[SYSTEM] Hunter archive copied to clipboard!'),
                    backgroundColor: sysBlue,
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16, color: Colors.black),
              label: const Text('COPY TO CLIPBOARD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: sysBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _yedekImportDialog() {
    final TextEditingController jsonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: physicalGold, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Row(
            children: [
              const Icon(Icons.file_upload, color: physicalGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'RESTORE ARCHIVE',
                style: GoogleFonts.orbitron(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your raw backup JSON archive below to overwrite and restore all Hunter data.',
                style: TextStyle(color: sysTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jsonCtrl,
                maxLines: 6,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: '{"oyuncuIsmi": "PLAYER", ...}',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: physicalGold.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: physicalGold),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = jsonCtrl.text.trim();
                if (text.isEmpty) return;

                final success = SystemMemory.importBackupJson(text);
                Navigator.pop(ctx);

                if (success) {
                  setState(() {});
                  AudioSystem.playLevelUp();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('[SYSTEM] Hunter archive successfully restored!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('[SYSTEM ERROR] Invalid or corrupt archive JSON!'),
                      backgroundColor: bloodRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: physicalGold.withValues(alpha: 0.2),
                side: const BorderSide(color: physicalGold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('RESTORE DATA', style: TextStyle(color: physicalGold, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _awakeningTestDialog() {
    final benchCtrl = TextEditingController(
      text: SystemMemory.maxBench > 0 ? SystemMemory.maxBench.toStringAsFixed(1).replaceAll('.0', '') : '',
    );
    final squatCtrl = TextEditingController(
      text: SystemMemory.maxSquat > 0 ? SystemMemory.maxSquat.toStringAsFixed(1).replaceAll('.0', '') : '',
    );
    final deadliftCtrl = TextEditingController(
      text: SystemMemory.maxDeadlift > 0 ? SystemMemory.maxDeadlift.toStringAsFixed(1).replaceAll('.0', '') : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            double bench = double.tryParse(benchCtrl.text.trim()) ?? 0;
            double squat = double.tryParse(squatCtrl.text.trim()) ?? 0;
            double deadlift = double.tryParse(deadliftCtrl.text.trim()) ?? 0;
            double total = bench + squat + deadlift;
            double bw = SystemMemory.kilo > 0 ? SystemMemory.kilo : 70.0;
            double ratio = total / bw;

            String previewRank;
            if (total == 0) {
              previewRank = SystemMemory.hunterRank;
            } else if (ratio >= 4.5) {
              previewRank = "S-Rank (Monarch)";
            } else if (ratio >= 3.75) {
              previewRank = "A-Rank (National)";
            } else if (ratio >= 3.0) {
              previewRank = "B-Rank (Elite)";
            } else if (ratio >= 2.25) {
              previewRank = "C-Rank (Knight)";
            } else if (ratio >= 1.5) {
              previewRank = "D-Rank (Hunter)";
            } else {
              previewRank = "E-Rank (Rookie)";
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF030712).withValues(alpha: 0.96),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: physicalGold, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              title: Row(
                children: [
                  const Icon(Icons.flash_on, color: physicalGold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AWAKENING TEST (1RM TRIAL)',
                      style: GoogleFonts.orbitron(
                        color: physicalGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The System measures your physical output against your body weight (${SystemMemory.kilo.toStringAsFixed(1)} kg) to assign your official Hunter Rank.',
                      style: const TextStyle(color: sysTextMuted, fontSize: 11, height: 1.4),
                    ),
                    const SizedBox(height: 14),

                    // Inputs for Big 3
                    _awakeningInputField(
                      controller: benchCtrl,
                      label: 'Bench Press 1RM (kg)',
                      icon: Icons.fitness_center,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _awakeningInputField(
                      controller: squatCtrl,
                      label: 'Squat 1RM (kg)',
                      icon: Icons.airline_seat_legroom_extra,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _awakeningInputField(
                      controller: deadliftCtrl,
                      label: 'Deadlift 1RM (kg)',
                      icon: Icons.arrow_upward,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Live Metrics Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: physicalGold.withValues(alpha: 0.08),
                        border: Border.all(color: physicalGold.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Lifted:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text('${total.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Strength Ratio:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text('${ratio.toStringAsFixed(2)}x BW', style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Divider(color: Colors.white12, thickness: 0.5),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Projected Rank:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text(
                                previewRank,
                                style: GoogleFonts.orbitron(
                                  color: physicalGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: physicalGold.withValues(alpha: 0.2),
                    side: const BorderSide(color: physicalGold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    final bVal = double.tryParse(benchCtrl.text.trim()) ?? 0;
                    final sVal = double.tryParse(squatCtrl.text.trim()) ?? 0;
                    final dVal = double.tryParse(deadliftCtrl.text.trim()) ?? 0;
                    final tot = bVal + sVal + dVal;

                    if (tot <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Please enter valid lifting numbers!'),
                          backgroundColor: bloodRed,
                        ),
                      );
                      return;
                    }

                    final bool isFirstAwakening = SystemMemory.hunterRank == "Unranked";

                    setState(() {
                      SystemMemory.maxBench = bVal;
                      SystemMemory.maxSquat = sVal;
                      SystemMemory.maxDeadlift = dVal;
                      SystemMemory.hunterRank = previewRank;

                      if (isFirstAwakening) {
                        SystemMemory.exp.value += 100;
                        SystemMemory.ap.value += 3;
                      }
                    });

                    SystemMemory.kaydet();
                    Navigator.pop(ctx);

                    if (isFirstAwakening) {
                      AudioSystem.playLevelUp();
                    } else {
                      AudioSystem.playSuccess();
                    }

                    showDialog(
                      context: context,
                      builder: (awardCtx) => AlertDialog(
                        backgroundColor: const Color(0xFF030712).withValues(alpha: 0.96),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: physicalGold, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        title: Center(
                          child: Text(
                            '[ AWAKENING REGISTERED ]',
                            style: GoogleFonts.orbitron(
                              color: physicalGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.military_tech, color: physicalGold, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              previewRank,
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: ${tot.toStringAsFixed(1)} kg | Ratio: ${ratio.toStringAsFixed(2)}x BW',
                              style: const TextStyle(color: sysTextMuted, fontSize: 12),
                            ),
                            if (isFirstAwakening) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.greenAccent),
                                ),
                                child: const Text(
                                  'FIRST AWAKENING BONUS: +100 EXP | +3 AP',
                                  style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: physicalGold,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(awardCtx),
                              child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('SAVE & AWAKEN', style: TextStyle(color: physicalGold, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _awakeningInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
        prefixIcon: Icon(icon, color: physicalGold, size: 16),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: physicalGold.withValues(alpha: 0.4)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: physicalGold),
        ),
      ),
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
            title: Text(
              TranslationManager.get('profile_title'), 
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                              color: (SystemMemory.redGateAktif ? bloodRed : sysBlue).withValues(alpha: 0.1), 
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
                if (SystemMemory.avatarFotoByte != null) ...[
                  const SizedBox(width: 20),
                  const Icon(Icons.arrow_forward_ios, color: sysBlue, size: 20),
                  const SizedBox(width: 20),
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4), 
                      border: Border.all(color: mentalPurple, width: 2), 
                      boxShadow: [
                        BoxShadow(
                          color: mentalPurple.withValues(alpha: 0.3), 
                          blurRadius: 25,
                          spreadRadius: 2
                        )
                      ], 
                      image: DecorationImage(image: MemoryImage(SystemMemory.avatarFotoByte!), fit: BoxFit.cover), 
                      color: const Color(0xFF0F172A)
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: _avatarUretimSureci, 
              icon: const Icon(Icons.auto_awesome, color: mentalPurple, size: 16), 
              label: Text(SystemMemory.avatarFotoByte == null ? TranslationManager.get('profile_awaken_avatar') : TranslationManager.get('profile_reawaken_avatar'), style: const TextStyle(color: mentalPurple, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: mentalPurple, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                backgroundColor: mentalPurple.withValues(alpha: 0.1)
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
                  tooltip: TranslationManager.get('profile_rename_tooltip'), 
                  onPressed: _isimGuncelleDialog
                )
              ],
            ),
            
            Text(
              TranslationManager.rankTitle(SystemMemory.level.value), 
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
                          Text(TranslationManager.get('profile_physical_specs'), style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2))
                        ]
                      ), 
                      IconButton(
                        icon: const Icon(Icons.history, color: sysBlue, size: 20), 
                        onPressed: _kiloGecmisiGoster, 
                        tooltip: TranslationManager.get('profile_weight_log_tooltip')
                      )
                    ]
                  ), 
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, 
                    children: [
                      _bilgiSutunu(TranslationManager.get('profile_height'), "${SystemMemory.boy.toInt()} cm", sysTextMuted), 
                      _bilgiSutunu(TranslationManager.get('profile_weight'), "${SystemMemory.kilo} kg", sysTextMuted), 
                      _bilgiSutunu(TranslationManager.get('profile_age'), "${SystemMemory.yas}", sysTextMuted)
                    ]
                  ),
                  const SizedBox(height: 15), 
                  const Divider(color: Colors.white12, thickness: 1), 
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(TranslationManager.get('profile_body_class'), style: const TextStyle(color: sysTextMuted, fontSize: 14)),
                          Text(SystemMemory.vucutSinifi, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(TranslationManager.get('profile_rank'), style: const TextStyle(color: sysTextMuted, fontSize: 14)),
                          Text(
                            SystemMemory.hunterRank, 
                            style: GoogleFonts.orbitron(
                              color: SystemMemory.hunterRank != 'Unranked' ? physicalGold : sysTextMuted, 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ]
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _awakeningTestDialog,
                      icon: const Icon(Icons.fitness_center, color: physicalGold, size: 14),
                      label: Text(TranslationManager.get('profile_take_test'), style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: physicalGold.withValues(alpha: 0.1),
                        side: const BorderSide(color: physicalGold, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 10)
                      ),
                    ),
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
                            TranslationManager.get('profile_protocol'), 
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
                        tooltip: TranslationManager.get('profile_override_tooltip')
                      )
                    ],
                  ), 
                  const SizedBox(height: 10),
                  _protokolSatiri(TranslationManager.get('profile_main_objective'), _hedefIngilizce(SystemMemory.aktifHedef), sysTextMuted),
                  const SizedBox(height: 10),
                  _protokolSatiri(
                    TranslationManager.get('profile_difficulty'), 
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
                        SystemMemory.redGateAktif ? TranslationManager.get('profile_red_gate_cal_limit') : TranslationManager.get('profile_daily_cal_limit'), 
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
                            TranslationManager.get('profile_stealth_mode'), 
                            style: GoogleFonts.orbitron(color: SystemMemory.redGateAktif ? sysTextMuted : mentalPurple, fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 2),
                          Text(
                            SystemMemory.redGateAktif ? TranslationManager.get('profile_stealth_desc_red') : TranslationManager.get('profile_stealth_desc_active'), 
                            style: const TextStyle(color: sysTextMuted, fontSize: 10)
                          ),
                        ],
                      ),
                      Switch(
                        value: SystemMemory.golgeModuAktif,
                        activeThumbColor: mentalPurple, 
                        inactiveThumbColor: sysTextMuted, 
                        inactiveTrackColor: sysDarkBg,
                        onChanged: SystemMemory.redGateAktif ? null : (val) { 
                          setState(() { SystemMemory.golgeModuAktif = val; }); 
                          SystemMemory.kaydet(); 
                          if (val) AudioSystem.playTransition(); 
                        },
                      ),
                    ],
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
                            TranslationManager.get('profile_lang_title'), 
                            style: GoogleFonts.orbitron(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentLang == 'en' ? "🇬🇧 English Active" : "🇹🇷 Türkçe Aktif", 
                            style: const TextStyle(color: sysTextMuted, fontSize: 10)
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildLanguageButton("en", "🇬🇧", "EN", currentLang == 'en'),
                          const SizedBox(width: 8),
                          _buildLanguageButton("tr", "🇹🇷", "TR", currentLang == 'tr'),
                        ],
                      ),
                    ],
                  )
                ]
              )
            ),
            const SizedBox(height: 20),

            HologramCard(
              neonRenk: SystemMemory.geminiApiKey.isNotEmpty ? sysBlue : Colors.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: SystemMemory.geminiApiKey.isNotEmpty ? sysBlue : Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "AI CORE / GEMINI",
                            style: GoogleFonts.orbitron(
                              color: SystemMemory.geminiApiKey.isNotEmpty ? sysBlue : Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (SystemMemory.geminiApiKey.isNotEmpty ? Colors.green : Colors.amber).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (SystemMemory.geminiApiKey.isNotEmpty ? Colors.green : Colors.amber).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          SystemMemory.geminiApiKey.isNotEmpty ? "CONFIGURED" : "NO KEY",
                          style: TextStyle(
                            color: SystemMemory.geminiApiKey.isNotEmpty ? Colors.greenAccent : Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _protokolSatiri("Active Engine", SystemMemory.geminiActiveModel, sysTextMuted),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _geminiAyarDialog,
                          icon: const Icon(Icons.key, size: 14, color: sysBlue),
                          label: const Text('SET KEY', style: TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: sysBlue.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _geminiTestEdiliyor ? null : _geminiBaglantiTestEt,
                          icon: _geminiTestEdiliyor
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.wifi, size: 14, color: Colors.white),
                          label: const Text('DIAGNOSTIC', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sysBlue.withValues(alpha: 0.2),
                            side: const BorderSide(color: sysBlue),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                            TranslationManager.get('profile_red_gate_active'), 
                            style: GoogleFonts.orbitron(color: bloodRed, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)
                          ), 
                          const SizedBox(height: 5),
                          Text(
                            "${SystemMemory.redGateKalanGun} ${TranslationManager.get('profile_days_remaining')}", 
                            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                          ), 
                          const SizedBox(height: 5),
                          Text(
                            TranslationManager.get('profile_red_gate_desc'), 
                            style: const TextStyle(color: sysTextMuted, fontSize: 12)
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
                      label: Text(
                        TranslationManager.get('profile_flee_gate'), 
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
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
                  label: Text(
                    TranslationManager.get('profile_open_red_gate'), 
                    style: const TextStyle(color: bloodRed, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bloodRed.withValues(alpha: 0.1), 
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
                label: Text(
                  TranslationManager.get('profile_system_update'), 
                  style: const TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sysBlue.withValues(alpha: 0.1), 
                  padding: const EdgeInsets.symmetric(vertical: 18), 
                  side: const BorderSide(color: sysBlue, width: 1), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sistemiSifirlaDialog,
                icon: const Icon(Icons.delete_forever, color: Colors.white, size: 16),
                label: Text(
                  TranslationManager.get('profile_system_reset'), 
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bloodRed.withValues(alpha: 0.2), 
                  padding: const EdgeInsets.symmetric(vertical: 18), 
                  side: const BorderSide(color: bloodRed, width: 2), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // VERİ YEDEKLEME VE GERİ YÜKLEME (DATA VAULT)
            // ==========================================
            HologramCard(
              neonRenk: physicalGold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storage, color: physicalGold, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            TranslationManager.get('profile_data_vault'),
                            style: GoogleFonts.orbitron(
                              color: physicalGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: physicalGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: physicalGold.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          "CLOUD / JSON",
                          style: TextStyle(color: physicalGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Export your full Hunter profile or restore from a previously saved JSON archive.",
                    style: TextStyle(color: sysTextMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _yedekExportDialog,
                          icon: const Icon(Icons.file_download, size: 14, color: sysBlue),
                          label: Text(TranslationManager.get('profile_backup_export'), style: const TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: sysBlue.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _yedekImportDialog,
                          icon: const Icon(Icons.file_upload, size: 14, color: physicalGold),
                          label: Text(TranslationManager.get('profile_backup_import'), style: const TextStyle(color: physicalGold, fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: physicalGold.withValues(alpha: 0.15),
                            side: const BorderSide(color: physicalGold),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  },
);
}

  Widget _buildLanguageButton(String langCode, String flag, String label, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          SystemMemory.appLanguage.value = langCode;
        });
        SystemMemory.kaydet();
        AudioSystem.playSuccess();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? sysBlue.withValues(alpha: 0.2) : const Color(0xFF070B14),
          border: Border.all(
            color: active ? sysBlue : Colors.white24,
            width: active ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: active
              ? [BoxShadow(color: sysBlue.withValues(alpha: 0.3), blurRadius: 6)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : sysTextMuted,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
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