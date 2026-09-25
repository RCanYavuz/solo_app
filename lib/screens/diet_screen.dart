import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:typed_data';
import '../controllers/system_memory.dart';
import '../models/food_model.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/hologram_card.dart';
import '../core/sistem_gecisi.dart';
import '../core/services/gemini_service.dart';
import 'macro_dashboard_screen.dart';
import '../core/translation_manager.dart';
import '../widgets/dietitian_scanner_modal.dart';

class YemekEkrani extends StatefulWidget {
  const YemekEkrani({super.key});

  @override
  State<YemekEkrani> createState() => _YemekEkraniState();
}

class _YemekEkraniState extends State<YemekEkrani> {
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysRed = Color(0xFFEF4444); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 
  static const Color sysGold = Color(0xFFB08D57); 
  static const Color sysGreen = Color(0xFF22C55E); 

  final TextEditingController _yemekAdiCtrl = TextEditingController();
  final TextEditingController _kaloriCtrl = TextEditingController();

  void _yemekEkleDialog() {
    final TextEditingController aiTarifCtrl = TextEditingController();
    final TextEditingController proteinCtrl = TextEditingController();
    final TextEditingController karbCtrl = TextEditingController();
    final TextEditingController yagCtrl = TextEditingController();
    bool aiYukleniyor = false;
    String? aiHata;
    Map<String, dynamic>? aiMakrolar;
    Uint8List? secilenFoto;

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
                  const Icon(Icons.restaurant_menu, color: sysBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    TranslationManager.get('diet_dialog_title'),
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
                    // ==========================================
                    // GEMINI AI ÇÖZÜMLEME BÖLÜMÜ
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: sysBlue.withValues(alpha: 0.06),
                        border: Border.all(color: sysBlue.withValues(alpha: 0.25)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: sysBlue, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                TranslationManager.get('diet_ai_decoder'),
                                style: GoogleFonts.orbitron(
                                  color: sysBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: aiTarifCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: TranslationManager.get('diet_ai_hint'),
                              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3))),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Fotoğraf Yükleme ve Canlı Kamera Butonları
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: aiYukleniyor ? null : () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024);
                                    if (image != null) {
                                      final bytes = await image.readAsBytes();
                                      setDialogState(() {
                                        secilenFoto = bytes;
                                        aiHata = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt, color: Colors.greenAccent, size: 14),
                                  label: const Text(
                                    'KAMERA',
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                                    side: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: aiYukleniyor ? null : () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
                                    if (image != null) {
                                      final bytes = await image.readAsBytes();
                                      setDialogState(() {
                                        secilenFoto = bytes;
                                        aiHata = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.photo_library, color: sysBlue, size: 14),
                                  label: Text(
                                    secilenFoto != null ? 'FOTO YÜKLENDİ' : 'GALERİ',
                                    style: const TextStyle(color: sysBlue, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: sysBlue.withValues(alpha: 0.1),
                                    side: BorderSide(color: secilenFoto != null ? Colors.greenAccent : sysBlue.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              if (secilenFoto != null) ...[
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.close, color: sysRed, size: 16),
                                  onPressed: () {
                                    setDialogState(() {
                                      secilenFoto = null;
                                    });
                                  },
                                )
                              ]
                            ],
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: aiYukleniyor
                                  ? null
                                  : () async {
                                      final tarif = aiTarifCtrl.text.trim();
                                      if (tarif.isEmpty && secilenFoto == null) {
                                        setDialogState(() {
                                          aiHata = 'Enter meal description or attach a photo.';
                                        });
                                        return;
                                      }
                                      if (SystemMemory.geminiApiKey.isEmpty) {
                                        setDialogState(() {
                                          aiHata = 'API Key missing. Configure in Profile.';
                                        });
                                        return;
                                      }

                                      setDialogState(() {
                                        aiYukleniyor = true;
                                        aiHata = null;
                                        aiMakrolar = null;
                                      });

                                      try {
                                        final raw = await GeminiService.yemekAnalizEt(tarif, imageBytes: secilenFoto);
                                        if (raw == null) {
                                          setDialogState(() {
                                            aiYukleniyor = false;
                                            aiHata = 'AI analysis could not connect.';
                                          });
                                          return;
                                        }

                                        final cleaned = raw.replaceAll(RegExp(r'```json\s*|```'), '').trim();
                                        final data = jsonDecode(cleaned);
                                        
                                        if (data.containsKey('hata')) {
                                          setDialogState(() {
                                            aiYukleniyor = false;
                                            aiHata = data['hata'].toString();
                                          });
                                          return;
                                        }

                                        final ad = data['yemekAdi']?.toString() ?? (tarif.isNotEmpty ? tarif : 'Photo AI Meal');
                                        final cal = (data['kalori'] ?? 0).toString();
                                        final p = (data['protein'] ?? 0).toString();
                                        final c = (data['karbonhidrat'] ?? 0).toString();
                                        final f = (data['yag'] ?? 0).toString();

                                        _yemekAdiCtrl.text = ad;
                                        _kaloriCtrl.text = cal;
                                        proteinCtrl.text = p;
                                        karbCtrl.text = c;
                                        yagCtrl.text = f;

                                        setDialogState(() {
                                          aiYukleniyor = false;
                                          aiMakrolar = data is Map<String, dynamic> ? data : null;
                                        });
                                      } catch (e) {
                                        setDialogState(() {
                                          aiYukleniyor = false;
                                          aiHata = 'Parse failed: $e';
                                        });
                                      }
                                    },
                              icon: aiYukleniyor
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: sysBlue),
                                    )
                                  : const Icon(Icons.flash_on, color: sysBlue, size: 14),
                              label: Text(
                                aiYukleniyor
                                    ? TranslationManager.get('diet_decoding')
                                    : TranslationManager.get('diet_decode_ai'),
                                style: const TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sysBlue.withValues(alpha: 0.12),
                                side: const BorderSide(color: sysBlue),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          if (aiHata != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              aiHata!,
                              style: const TextStyle(color: sysRed, fontSize: 11),
                            ),
                          ],
                          if (aiMakrolar != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'P: ${aiMakrolar!['protein'] ?? 0}g | C: ${aiMakrolar!['karbonhidrat'] ?? 0}g | F: ${aiMakrolar!['yag'] ?? 0}g',
                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  if (aiMakrolar!['sistemMesaji'] != null)
                                    Text(
                                      '${aiMakrolar!['sistemMesaji']}',
                                      style: const TextStyle(color: sysTextMuted, fontSize: 10, fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // MANUEL ONAY / DÜZENLEME ALANLARI
                    // ==========================================
                    TextField(
                      controller: _yemekAdiCtrl,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: TranslationManager.get('diet_item_name'),
                        labelStyle: const TextStyle(color: sysTextMuted),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Makro Giriş Alanları (P / C / F)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: proteinCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: '${TranslationManager.get('diet_protein')} (g)',
                              labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.4))),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: karbCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: '${TranslationManager.get('diet_carb')} (g)',
                              labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.4))),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: yagCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: '${TranslationManager.get('diet_fat')} (g)',
                              labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4))),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _kaloriCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: TranslationManager.get('diet_energy_kcal'),
                        labelStyle: const TextStyle(color: sysTextMuted),
                        suffixText: 'Kcal',
                        suffixStyle: const TextStyle(color: sysBlue),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(TranslationManager.get('cancel'), style: const TextStyle(color: sysTextMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysBlue.withValues(alpha: 0.1),
                    side: const BorderSide(color: sysBlue),
                  ),
                  onPressed: () {
                    final ad = _yemekAdiCtrl.text.trim();
                    final kalori = int.tryParse(_kaloriCtrl.text.trim());
                    final pVal = int.tryParse(proteinCtrl.text.trim()) ?? 0;
                    final cVal = int.tryParse(karbCtrl.text.trim()) ?? 0;
                    final fVal = int.tryParse(yagCtrl.text.trim()) ?? 0;

                    if (ad.isNotEmpty && kalori != null && kalori > 0) {
                      setState(() {
                        SystemMemory.bugununYemekleri.add(TuketilenYemek(
                          ad,
                          kalori,
                          protein: pVal,
                          karbonhidrat: cVal,
                          yag: fVal,
                        ));
                        SystemMemory.bugunAlinanKalori += kalori;
                      });
                      SystemMemory.kaydet();
                      _yemekAdiCtrl.clear();
                      _kaloriCtrl.clear();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(TranslationManager.get('diet_warning_valid_item')),
                          backgroundColor: sysRed,
                        ),
                      );
                    }
                  },
                  child: Text(TranslationManager.get('diet_add_item_btn'), style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _yemekSil(int index) {
    setState(() {
      SystemMemory.bugunAlinanKalori -= SystemMemory.bugununYemekleri[index].kalori;
      SystemMemory.bugununYemekleri.removeAt(index);
    });
    SystemMemory.kaydet();
  }

  void _diyetisyenModaliAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const DietitianScannerModal(),
    ).then((_) => setState(() {}));
  }

  String _formatTarihKisa(DateTime? dt) {
    if (dt == null) return "";
    const aylarTr = ["", "Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"];
    const aylarEn = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final aylar = TranslationManager.isTurkish ? aylarTr : aylarEn;
    return "${dt.day} ${aylar[dt.month]}";
  }

  void _tumDiyetisyenGunleriniGoster() {
    final tr = TranslationManager.isTurkish;
    final planlar = SystemMemory.diyetisyenGunlukPlanlar;
    final sortedKeys = planlar.keys.toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF070B14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: sysGold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tr ? "TÜM DİYETİSYEN GÜNLERİ" : "ALL DIETITIAN DAYS",
                            style: GoogleFonts.orbitron(color: sysGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: sysTextMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr
                        ? "Diyetisyen belgenizden takvime işlenen günlük beslenme programı:"
                        : "Multi-day diet protocol decoded from your dietitian document:",
                    style: const TextStyle(color: sysTextMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: sortedKeys.isEmpty
                        ? Center(
                            child: Text(
                              tr ? "Henüz çoklu gün planı bulunmuyor." : "No multi-day plan found.",
                              style: const TextStyle(color: sysTextMuted),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            itemCount: sortedKeys.length,
                            itemBuilder: (context, idx) {
                              final key = sortedKeys[idx];
                              final p = Map<String, dynamic>.from(planlar[key] as Map);
                              final dt = DateTime.tryParse(key);
                              final baslik = p['baslik']?.toString() ?? '${idx + 1}. Gün';
                              final cal = p['kalori'] ?? SystemMemory.diyetisyenBazKalori;
                              final pro = p['protein'] ?? SystemMemory.diyetisyenBazProtein;
                              final carb = p['karb'] ?? SystemMemory.diyetisyenBazKarb;
                              final fat = p['yag'] ?? SystemMemory.diyetisyenBazYag;
                              final ogunler = (p['ogunler'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

                              final now = DateTime.now();
                              final isToday = dt != null && dt.year == now.year && dt.month == now.month && dt.day == now.day;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isToday ? sysGold.withValues(alpha: 0.12) : const Color(0xFF0F172A),
                                  border: Border.all(
                                    color: isToday ? sysGold : Colors.white12,
                                    width: isToday ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              baslik,
                                              style: GoogleFonts.orbitron(
                                                color: isToday ? sysGold : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (dt != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                "(${_formatTarihKisa(dt)})",
                                                style: TextStyle(color: isToday ? sysGold : sysBlue, fontSize: 11),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (isToday)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: sysGold, borderRadius: BorderRadius.circular(3)),
                                            child: Text(
                                              tr ? "BUGÜN" : "TODAY",
                                              style: const TextStyle(color: sysDarkBg, fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "$cal kcal | P: ${pro}g | C: ${carb}g | F: ${fat}g",
                                      style: TextStyle(color: sysGold.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...ogunler.map((og) {
                                      final bool done = og['tamamlandi'] == true;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              done ? Icons.check_circle : Icons.circle_outlined,
                                              size: 14,
                                              color: done ? sysGreen : sysTextMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                "${og['ad'] ?? og['baslik']}: ${og['detay'] ?? og['besinler'] ?? ''}",
                                                style: TextStyle(
                                                  color: done ? Colors.white54 : Colors.white,
                                                  fontSize: 11,
                                                  decoration: done ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                            ),
                                            if (og['kalori'] != null)
                                              Text(
                                                "${og['kalori']} kcal",
                                                style: const TextStyle(color: sysTextMuted, fontSize: 10),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiyetisyenGununMenusuCard() {
    final tr = TranslationManager.isTurkish;
    final now = DateTime.now();
    final bugunStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final baslangicStr = SystemMemory.diyetisyenBaslangicTarihi;
    final baslangicDt = baslangicStr.isNotEmpty ? DateTime.tryParse(baslangicStr) : null;
    final bool yarinBasliyor = baslangicDt != null && DateTime(now.year, now.month, now.day).isBefore(DateTime(baslangicDt.year, baslangicDt.month, baslangicDt.day));

    if (yarinBasliyor) {
      return HologramCard(
        neonRenk: sysGold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: sysGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr ? "⏳ DİYETİSYEN MENÜSÜ: 1. GÜN YARIN BAŞLIYOR" : "⏳ DIETITIAN MENU: DAY 1 STARTS TOMORROW",
                    style: GoogleFonts.orbitron(color: sysGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr
                  ? "Diyetisyen belgenizdeki '1. Gün' menüsü ${_formatTarihKisa(baslangicDt)} tarihinden itibaren devreye girecektir. Bugün mevcut beslenmenize devam edebilirsiniz."
                  : "Day 1 from your dietitian document will activate on ${_formatTarihKisa(baslangicDt)}. You may proceed with today's regular plan.",
              style: const TextStyle(color: sysTextMuted, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _tumDiyetisyenGunleriniGoster,
                    icon: const Icon(Icons.visibility, size: 14, color: sysGold),
                    label: Text(
                      tr ? "YARININ MENÜSÜNÜ ÖNİZLE" : "PREVIEW TOMORROW'S MENU",
                      style: const TextStyle(color: sysGold, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: sysGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Map<String, dynamic>? gunPlani;
    if (SystemMemory.diyetisyenGunlukPlanlar.containsKey(bugunStr)) {
      gunPlani = Map<String, dynamic>.from(SystemMemory.diyetisyenGunlukPlanlar[bugunStr] as Map);
    }
    final planBaslik = gunPlani?['baslik']?.toString() ?? (tr ? 'Günün Menüsü' : "Today's Menu");
    final ogunler = (gunPlani?['ogunler'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? SystemMemory.diyetisyenOgunleri;

    return HologramCard(
      neonRenk: sysGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant_menu, color: sysGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "📋 $planBaslik",
                    style: GoogleFonts.orbitron(color: sysGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              if (SystemMemory.diyetisyenGunlukPlanlar.isNotEmpty)
                InkWell(
                  onTap: _tumDiyetisyenGunleriniGoster,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sysGold.withValues(alpha: 0.15),
                      border: Border.all(color: sysGold.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr ? "TÜM GÜNLER" : "ALL DAYS",
                          style: const TextStyle(color: sysGold, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, color: sysGold, size: 10),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${SystemMemory.diyetisyenBazKalori} kcal | P: ${SystemMemory.diyetisyenBazProtein}g | C: ${SystemMemory.diyetisyenBazKarb}g | F: ${SystemMemory.diyetisyenBazYag}g",
            style: TextStyle(color: sysGold.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (ogunler.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                tr ? "Bugün için kayıtlı öğün bulunmuyor." : "No meals logged for today.",
                style: const TextStyle(color: sysTextMuted, fontSize: 11),
              ),
            )
          else
            ...ogunler.map((og) {
              final String id = og['id']?.toString() ?? og['ad']?.toString() ?? '';
              final String ad = og['ad']?.toString() ?? og['baslik']?.toString() ?? (tr ? 'Öğün' : 'Meal');
              final String detay = og['detay']?.toString() ?? og['besinler']?.toString() ?? '';
              final int cal = (og['kalori'] as num?)?.toInt() ?? 0;
              final int pro = (og['protein'] as num?)?.toInt() ?? 0;
              final int carb = (og['karb'] as num?)?.toInt() ?? 0;
              final int fat = (og['yag'] as num?)?.toInt() ?? 0;
              final bool done = og['tamamlandi'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: done ? sysGreen.withValues(alpha: 0.08) : const Color(0xFF0F172A),
                  border: Border.all(color: done ? sysGreen.withValues(alpha: 0.4) : Colors.white12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ad,
                                style: TextStyle(
                                  color: done ? sysGreen : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  decoration: done ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$cal kcal",
                                style: const TextStyle(color: sysGold, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (detay.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              detay,
                              style: TextStyle(
                                color: done ? Colors.white38 : sysTextMuted,
                                fontSize: 11,
                                height: 1.3,
                                decoration: done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                          if (pro > 0 || carb > 0 || fat > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              "P: ${pro}g • C: ${carb}g • F: ${fat}g",
                              style: const TextStyle(color: sysBlue, fontSize: 9),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        SystemMemory.diyetisyenOgunDurumuGuncelle(id, !done);
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: done ? sysGreen : sysBlue.withValues(alpha: 0.15),
                          border: Border.all(color: done ? sysGreen : sysBlue.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              done ? Icons.check : Icons.add_circle_outline,
                              color: done ? sysDarkBg : sysBlue,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              done ? (tr ? "TÜKETİLDİ" : "EATEN") : (tr ? "TÜKET" : "EAT"),
                              style: TextStyle(
                                color: done ? sysDarkBg : sysBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _telafiBadge(String metin, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.15),
        border: Border.all(color: renk.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        metin,
        style: GoogleFonts.orbitron(color: renk, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==========================================================
  // GEÇMİŞ GÜNLERİN YEMEKLERİNİ GÖSTEREN ARŞİV MOTORU
  // ==========================================================
  void _gecmisiGoster() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF070B14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: sysBlue.withValues(alpha: 0.5), width: 2))),
              child: Column(
                children: [
                  Text(TranslationManager.get('diet_archive_title'), style: GoogleFonts.orbitron(color: sysBlue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  SystemMemory.yemekGecmisi.isEmpty
                  ? Expanded(child: Center(child: Text(TranslationManager.get('diet_archive_empty'), style: const TextStyle(color: sysTextMuted))))
                  : Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: SystemMemory.yemekGecmisi.length,
                        itemBuilder: (context, index) {
                          // En yeni olan en üstte görünsün diye ters indexleme
                          int revIndex = SystemMemory.yemekGecmisi.length - 1 - index;
                          var kayit = SystemMemory.yemekGecmisi[revIndex];
                          
                          List<dynamic> yemeklerListesi = kayit['yemekler'] ?? [];
                          int topKalori = kayit['toplamKalori'] ?? 0;
                          String tarih = kayit['tarih'] ?? "Unknown Date";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(color: const Color(0xFF030712), border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(4)),
                            child: ExpansionTile(
                              collapsedIconColor: sysBlue,
                              iconColor: sysBlue,
                              leading: const Icon(Icons.inventory_2, color: sysTextMuted),
                              title: Text(tarih, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              subtitle: Text('${TranslationManager.get('diet_total_energy')}: $topKalori Kcal', style: const TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                              children: yemeklerListesi.isEmpty 
                                ? [Padding(padding: const EdgeInsets.all(10), child: Text(TranslationManager.get('diet_no_specific_items'), style: const TextStyle(color: sysTextMuted, fontSize: 12)))]
                                : yemeklerListesi.map((y) {
                                  return Container(
                                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12, width: 0.5))),
                                    child: ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.restaurant_menu, color: sysTextMuted, size: 16),
                                      title: Text(y['ad'], style: const TextStyle(color: sysTextMuted, fontSize: 14)),
                                      trailing: Text('${y['kalori']} Kcal', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                              }).toList(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    double kaloriYuzdesi = 0;
    if (SystemMemory.gunlukHedefKalori > 0) {
      kaloriYuzdesi = SystemMemory.bugunAlinanKalori / SystemMemory.gunlukHedefKalori;
      if (kaloriYuzdesi > 1.0) kaloriYuzdesi = 1.0; 
    }
    bool kaloriAsildi = SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori;
    Color barRengi = kaloriAsildi ? sysRed : sysBlue;

    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: sysDarkBg,
          appBar: AppBar(
            title: Text(TranslationManager.get('diet_title'), style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
            backgroundColor: Colors.transparent, 
            elevation: 0,
            centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.assignment_outlined,
              color: SystemMemory.diyetisyenListesiAktif ? sysGold : sysBlue,
              size: 26,
            ),
            tooltip: TranslationManager.get('diet_dietitian_tooltip'),
            onPressed: _diyetisyenModaliAc,
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: sysBlue, size: 26),
            tooltip: TranslationManager.get('diet_macro_lab_tooltip'),
            onPressed: () => Navigator.push(
              context,
              SistemGecisi(sayfa: const MacroDashboardScreen()),
            ).then((_) => setState(() {})),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: sysBlue, size: 26),
            tooltip: TranslationManager.get('diet_archive_tooltip'),
            onPressed: _gecmisiGoster,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HologramCard(
              neonRenk: barRengi,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(TranslationManager.get('diet_energy_gauge'), style: GoogleFonts.orbitron(color: barRengi, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Icon(kaloriAsildi ? Icons.warning_amber_rounded : Icons.bolt, color: barRengi, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150, height: 150,
                        child: CircularProgressIndicator(
                          value: kaloriYuzdesi, strokeWidth: 8,
                          backgroundColor: const Color(0xFF0F172A),
                          valueColor: AlwaysStoppedAnimation<Color>(barRengi),
                        ),
                      ),
                      Column(
                        children: [
                          Text('${SystemMemory.bugunAlinanKalori}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, shadows: [Shadow(color: barRengi.withValues(alpha: 0.5), blurRadius: 10)])),
                          const Text('Kcal', style: TextStyle(color: sysTextMuted, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        SystemMemory.diyetisyenListesiAktif
                            ? (TranslationManager.isTurkish ? 'Diyetisyen Taban Limiti' : 'Dietitian Base Limit')
                            : TranslationManager.get('diet_daily_limit'),
                        style: const TextStyle(color: sysTextMuted, fontSize: 14),
                      ),
                      Text("${SystemMemory.gunlukHedefKalori} Kcal", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                    ],
                  )
                ],
              ),
            ),

            // HEDEF KİLO & STRATEJİ BANNERI
            if (SystemMemory.hedefKilo > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  border: Border.all(color: sysBlue.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.track_changes, color: sysBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${TranslationManager.isTurkish ? '🎯 HEDEF KİLO' : '🎯 TARGET WEIGHT'}: ${SystemMemory.hedefKilo.toStringAsFixed(1)} KG',
                                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(SystemMemory.hedefKilo - SystemMemory.kilo) >= 0 ? "+" : ""}${(SystemMemory.hedefKilo - SystemMemory.kilo).toStringAsFixed(1)} KG',
                                style: GoogleFonts.rajdhani(
                                  color: (SystemMemory.hedefKilo - SystemMemory.kilo).abs() <= 0.5 ? sysGreen : sysBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (SystemMemory.avciDiyetNotu.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              '${TranslationManager.isTurkish ? 'Vizyon' : 'Vision'}: "${SystemMemory.avciDiyetNotu}"',
                              style: const TextStyle(color: sysTextMuted, fontSize: 10, fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // SİSTEM YIPRANMA VE KATABOLİZMA DENGELEYİCİSİ HUD
            if (SystemMemory.bugunYakilanIdmanKalorisi > 0 || SystemMemory.bugunTelafiProteini > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: sysRed.withValues(alpha: 0.8), width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: sysRed.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: sysRed, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          TranslationManager.isTurkish ? '⚖️ SİSTEM İDMAN VE KAS KORUMA' : '⚖️ WORKOUT & MUSCLE DEFENSE',
                          style: GoogleFonts.orbitron(
                            color: sysRed,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sysRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${TranslationManager.isTurkish ? 'KATABOLİZMA' : 'CATABOLISM'}: ${SystemMemory.sonIdmanYipranmaRaporu?['katabolizmaRiski'] ?? (TranslationManager.isTurkish ? 'YÜKSEK' : 'HIGH')}',
                            style: const TextStyle(color: sysRed, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TranslationManager.isTurkish
                          ? 'Bugünkü ağır idman harcamanız: ~${SystemMemory.bugunYakilanIdmanKalorisi} kcal.\nKas yıkımını önlemek ve glikojeni yenilemek için sisteme eklenen dinamik takviye:'
                          : 'Today\'s workout expenditure: ~${SystemMemory.bugunYakilanIdmanKalorisi} kcal.\nDynamic supplements added to protect muscle and restore glycogen:',
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _telafiBadge('+${SystemMemory.bugunTelafiProteini}g Protein', sysBlue),
                        const SizedBox(width: 8),
                        _telafiBadge('+${SystemMemory.bugunTelafiKarbonhidrati}g ${TranslationManager.isTurkish ? 'Karbonhidrat' : 'Carbs'}', Colors.orangeAccent),
                      ],
                    ),
                    if (SystemMemory.diyetisyenListesiAktif) ...[
                      const SizedBox(height: 6),
                      Text(
                        TranslationManager.isTurkish
                            ? '📋 Diyetisyen taban reçetesi korunmaktadır; idman eforu dinamik olarak telafi edilmiştir.'
                            : '📋 Dietitian base protocol preserved; workout expenditure compensated dynamically.',
                        style: const TextStyle(color: sysGold, fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      SistemGecisi(sayfa: const MacroDashboardScreen()),
                    ).then((_) => setState(() {})),
                    icon: const Icon(Icons.science_outlined, color: sysBlue, size: 16),
                    label: Text(
                      TranslationManager.get('diet_access_macro_lab'),
                      style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: sysBlue.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _diyetisyenModaliAc,
                    icon: Icon(
                      Icons.assignment_turned_in,
                      color: SystemMemory.diyetisyenListesiAktif ? sysGold : sysBlue,
                      size: 16,
                    ),
                    label: Text(
                      SystemMemory.diyetisyenListesiAktif
                          ? (TranslationManager.isTurkish ? 'DİYETİSYEN [AÇIK]' : 'DIETITIAN [ON]')
                          : (TranslationManager.isTurkish ? 'DİYETİSYEN' : 'DIETITIAN'),
                      style: TextStyle(
                        color: SystemMemory.diyetisyenListesiAktif ? sysGold : sysBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: (SystemMemory.diyetisyenListesiAktif ? sysGold : sysBlue).withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            if (SystemMemory.diyetisyenListesiAktif) ...[
              _buildDiyetisyenGununMenusuCard(),
              const SizedBox(height: 25),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslationManager.get('diet_todays_inventory'), style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ElevatedButton.icon(
                  onPressed: _yemekEkleDialog,
                  icon: const Icon(Icons.add, color: sysDarkBg, size: 16),
                  label: Text(TranslationManager.get('diet_add_item_btn'), style: const TextStyle(color: sysDarkBg, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: sysBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            Container(
              decoration: BoxDecoration(border: Border.all(color: sysBlue.withValues(alpha: 0.4), width: 1), borderRadius: BorderRadius.circular(4), color: const Color(0xFF070B14).withValues(alpha: 0.85)),
              child: SystemMemory.bugununYemekleri.isEmpty
                ? Padding(padding: const EdgeInsets.all(30), child: Center(child: Text(TranslationManager.get('diet_inventory_empty'), style: const TextStyle(color: sysTextMuted))))
                : ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: SystemMemory.bugununYemekleri.length,
                    itemBuilder: (context, index) {
                      var y = SystemMemory.bugununYemekleri[index];
                      return Container(
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5))),
                        child: ListTile(
                          leading: const Icon(Icons.restaurant_menu, color: sysTextMuted, size: 20),
                          title: Text(y.ad, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: Text(
                            (y.protein > 0 || y.karbonhidrat > 0 || y.yag > 0)
                              ? '${y.kalori} Kcal | P: ${y.protein}g C: ${y.karbonhidrat}g F: ${y.yag}g'
                              : '${y.kalori} Kcal',
                            style: const TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: sysRed, size: 20), onPressed: () => _yemekSil(index)),
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 25),

            // ==========================================
            // SU TAKİBİ PANELİ (HYDRATION CORE)
            // ==========================================
            ValueListenableBuilder<int>(
              valueListenable: SystemMemory.bugunIcilenSuMl,
              builder: (context, icilenSu, _) {
                final hedef = SystemMemory.suHedefiMl;
                final double suOrani = hedef > 0 ? (icilenSu / hedef).clamp(0.0, 1.0) : 0.0;
                final bool hedefUlasildi = icilenSu >= hedef && hedef > 0;
                const Color waterColor = Color(0xFF00E5FF);

                return HologramCard(
                  neonRenk: hedefUlasildi ? Colors.greenAccent : waterColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.water_drop, color: waterColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    TranslationManager.get('diet_hydration_title'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.orbitron(
                                      color: hedefUlasildi ? Colors.greenAccent : waterColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$icilenSu / $hedef ml',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: suOrani,
                          minHeight: 10,
                          backgroundColor: const Color(0xFF0F172A),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hedefUlasildi ? Colors.greenAccent : waterColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  SystemMemory.suEkle(250);
                                });
                              },
                              icon: const Icon(Icons.local_drink, size: 14, color: waterColor),
                              label: const Text('+250 ml', style: TextStyle(color: waterColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: waterColor.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  SystemMemory.suEkle(500);
                                });
                              },
                              icon: const Icon(Icons.local_cafe, size: 14, color: waterColor),
                              label: const Text('+500 ml', style: TextStyle(color: waterColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: waterColor.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: sysTextMuted, size: 18),
                            tooltip: TranslationManager.get('diet_water_reset'),
                            onPressed: () {
                              setState(() {
                                SystemMemory.suSifirla();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
      },
    );
  }

  @override
  void dispose() {
    _yemekAdiCtrl.dispose();
    _kaloriCtrl.dispose();
    super.dispose();
  }
}