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

  final TextEditingController _yemekAdiCtrl = TextEditingController();
  final TextEditingController _kaloriCtrl = TextEditingController();

  void _yemekEkleDialog() {
    final TextEditingController aiTarifCtrl = TextEditingController();
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
                    'ADD INVENTORY ITEM',
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
                                "AI DECODER (GEMINI)",
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
                              hintText: 'e.g. 2 eggs, 1 slice bread, 50g cheese (optional if photo is given)',
                              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.3))),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Fotoğraf Yükleme Butonu
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: aiYukleniyor ? null : () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
                                    if (image != null) {
                                      final bytes = await image.readAsBytes();
                                      setDialogState(() {
                                        secilenFoto = bytes;
                                        aiHata = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_a_photo, color: sysBlue, size: 14),
                                  label: Text(
                                    secilenFoto != null ? 'PHOTO ATTACHED' : 'ATTACH PHOTO',
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
                                const SizedBox(width: 8),
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

                                        _yemekAdiCtrl.text = ad;
                                        _kaloriCtrl.text = cal;

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
                                aiYukleniyor ? 'DECODING...' : 'DECODE WITH AI',
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
                        labelText: 'Item Name (Food)',
                        labelStyle: const TextStyle(color: sysTextMuted),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: sysBlue.withValues(alpha: 0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kaloriCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Energy (Kcal)',
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
                  child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysBlue.withValues(alpha: 0.1),
                    side: const BorderSide(color: sysBlue),
                  ),
                  onPressed: () {
                    final ad = _yemekAdiCtrl.text.trim();
                    final kalori = int.tryParse(_kaloriCtrl.text.trim());
                    if (ad.isNotEmpty && kalori != null && kalori > 0) {
                      setState(() {
                        SystemMemory.bugununYemekleri.add(TuketilenYemek(ad, kalori));
                        SystemMemory.bugunAlinanKalori += kalori;
                      });
                      SystemMemory.kaydet();
                      _yemekAdiCtrl.clear();
                      _kaloriCtrl.clear();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SYSTEM WARNING: Enter valid item name and calorie amount!'),
                          backgroundColor: sysRed,
                        ),
                      );
                    }
                  },
                  child: const Text('ADD ITEM', style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold)),
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
                  Text('DIET ARCHIVE', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  SystemMemory.yemekGecmisi.isEmpty
                  ? const Expanded(child: Center(child: Text("No records found in the vault.", style: TextStyle(color: sysTextMuted))))
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
                              subtitle: Text('Total Energy: $topKalori Kcal', style: const TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                              children: yemeklerListesi.isEmpty 
                                ? [const Padding(padding: EdgeInsets.all(10), child: Text("No specific items recorded.", style: TextStyle(color: sysTextMuted, fontSize: 12)))]
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

    return Scaffold(
      backgroundColor: sysDarkBg,
      appBar: AppBar(
        title: Text('I N V E N T O R Y', style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: sysBlue, size: 26),
            tooltip: 'Macro Lab',
            onPressed: () => Navigator.push(
              context,
              SistemGecisi(sayfa: const MacroDashboardScreen()),
            ).then((_) => setState(() {})),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: sysBlue, size: 26),
            tooltip: 'Diet Archive',
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
                      Text('ENERGY GAUGE', style: GoogleFonts.orbitron(color: barRengi, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
                      const Text("Daily Limit:", style: TextStyle(color: sysTextMuted, fontSize: 14)),
                      Text("${SystemMemory.gunlukHedefKalori} Kcal", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  SistemGecisi(sayfa: const MacroDashboardScreen()),
                ).then((_) => setState(() {})),
                icon: const Icon(Icons.science_outlined, color: sysBlue, size: 18),
                label: const Text(
                  'ACCESS NUTRITION & MACRO LAB',
                  style: TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: sysBlue.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TODAY\'S INVENTORY', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ElevatedButton.icon(
                  onPressed: _yemekEkleDialog,
                  icon: const Icon(Icons.add, color: sysDarkBg, size: 16),
                  label: const Text('ADD ITEM', style: TextStyle(color: sysDarkBg, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: sysBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            Container(
              decoration: BoxDecoration(border: Border.all(color: sysBlue.withValues(alpha: 0.4), width: 1), borderRadius: BorderRadius.circular(4), color: const Color(0xFF070B14).withValues(alpha: 0.85)),
              child: SystemMemory.bugununYemekleri.isEmpty
                ? const Padding(padding: EdgeInsets.all(30), child: Center(child: Text("Inventory is empty. Fuel up, Hunter.", style: TextStyle(color: sysTextMuted))))
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
                          subtitle: Text('${y.kalori} Kcal', style: const TextStyle(color: sysBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: sysRed, size: 20), onPressed: () => _yemekSil(index)),
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}