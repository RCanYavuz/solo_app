// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart';
import '../core/translation_manager.dart';

import '../models/inventory_item_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysTextMuted = Color(0xFF94A3B8);

  IconData _esyaIkonu(String aksiyon) {
    switch (aksiyon) {
      case "hp_full": return Icons.favorite;
      case "stat_reset": return Icons.water_drop;
      case "minor_cheat": return Icons.icecream;
      case "cheat_meal": return Icons.fastfood;
      case "endless_feast": return Icons.restaurant;
      case "gaming_pass": return Icons.sports_esports;
      case "sloth_day": return Icons.weekend;
      case "new_gear": return Icons.shopping_cart;
      default: return Icons.inventory_2;
    }
  }

  List<Map<String, dynamic>> get marketEsyalari {
    final isTr = TranslationManager.isTurkish;
    return [
      // POTIONS
      {"id": "hp_pot", "ad": isTr ? "İyileşme İksiri" : "Healing Potion", "fiyat": 150, "aciklama": isTr ? "HP değerinizi anında maksimum seviyeye çıkarır." : "Restores your HP to maximum instantly.", "ikon": Icons.favorite, "renk": const Color(0xFFEF4444), "aksiyon": "hp_full"},
      {"id": "water_lethe", "ad": isTr ? "Lethe Suyu" : "Water of Lethe", "fiyat": 1000, "aciklama": isTr ? "Tüm dağıtılan statü puanlarını sıfırlar ve AP puanlarını iade eder." : "Resets all allocated Stat Points and refunds AP.", "ikon": Icons.water_drop, "renk": const Color(0xFFA060E0), "aksiyon": "stat_reset"},
      
      // CHEATS / SNACKS
      {"id": "minor_cheat", "ad": isTr ? "Küçük Kaçamak" : "Minor Cheat", "fiyat": 200, "aciklama": isTr ? "Ceza almadan küçük bir atıştırmalık tüketin." : "Eat one small snack (e.g., chocolate) without penalty.", "ikon": Icons.icecream, "renk": physicalGold, "aksiyon": "minor_cheat"},
      {"id": "cheat_meal", "ad": isTr ? "Kaçamak Öğün" : "Cheat Meal", "fiyat": 500, "aciklama": isTr ? "Ceza almadan serbest bir kaçamak öğün tüketin." : "One free cheat meal (e.g., Burger Menu).", "ikon": Icons.fastfood, "renk": physicalGold, "aksiyon": "cheat_meal"},
      {"id": "endless_feast", "ad": isTr ? "Sonsuz Ziyafet" : "Endless Feast", "fiyat": 2000, "aciklama": isTr ? "1 tam gün sınırsız beslenme günü." : "1 Full Cheat Day. Eat limitlessly.", "ikon": Icons.restaurant, "renk": physicalGold, "aksiyon": "endless_feast"},

      // ENTERTAINMENT
      {"id": "gaming_pass", "ad": isTr ? "Oyun Bileti (2 Saat)" : "Gaming Pass (2 Hrs)", "fiyat": 300, "aciklama": isTr ? "Vicdan azabı çekmeden oyun oynayın veya dizi izleyin." : "Play games or watch series guilt-free.", "ikon": Icons.sports_esports, "renk": sysBlue, "aksiyon": "gaming_pass"},
      {"id": "sloth_day", "ad": isTr ? "Tembellik Günü" : "Sloth Day", "fiyat": 1500, "aciklama": isTr ? "Sistem cezası almadan bugünün tüm görevlerini atlayın." : "Skip all quests today without System penalty.", "ikon": Icons.weekend, "renk": sysBlue, "aksiyon": "sloth_day"},

      // REWARDS
      {"id": "new_gear", "ad": isTr ? "Materyal: Yeni Teçhizat" : "Material: New Gear", "fiyat": 5000, "aciklama": isTr ? "Kendinize gerçek hayatta bir ödül satın alın." : "Buy yourself a real-life reward (clothes, games).", "ikon": Icons.shopping_cart, "renk": Colors.greenAccent, "aksiyon": "new_gear"},
    ];
  }

  void _satinAl(Map<String, dynamic> esya) {
    int fiyat = esya["fiyat"];
    if (SystemMemory.altin.value >= fiyat) {
      setState(() { SystemMemory.altin.value -= fiyat; });
      
      final Color itemColor = esya["renk"] as Color;
      final IconData itemIcon = esya["ikon"] as IconData;

      SystemMemory.esyaEkle(InventoryItem(
        id: esya["id"] ?? esya["aksiyon"],
        ad: esya["ad"],
        aciklama: esya["aciklama"],
        aksiyon: esya["aksiyon"],
        ikonKodu: itemIcon.codePoint,
        renkDegeri: itemColor.toARGB32(),
      ));

      AudioSystem.playSuccess();
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('[SYSTEM] "${esya["ad"]}" ${TranslationManager.get('shop_stored_in_bag')}'),
        backgroundColor: Colors.green, duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: TranslationManager.get('shop_open_bag'),
          textColor: Colors.white,
          onPressed: _cantayiGoster,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(TranslationManager.get('shop_insufficient_gold')),
        backgroundColor: const Color(0xFFEF4444), duration: const Duration(seconds: 2)
      ));
    }
  }

  void _cantayiGoster() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF070B14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: physicalGold.withValues(alpha: 0.5), width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.backpack, color: physicalGold, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            TranslationManager.get('shop_bag_title'),
                            style: GoogleFonts.orbitron(
                              color: physicalGold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${SystemMemory.canta.length} ${TranslationManager.get('shop_items_count')}',
                        style: const TextStyle(color: sysTextMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 10),

                  if (SystemMemory.canta.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          TranslationManager.get('shop_empty_bag'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: sysTextMuted, fontSize: 13, height: 1.5),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: SystemMemory.canta.length,
                        itemBuilder: (context, index) {
                          final item = SystemMemory.canta[index];
                          final itemColor = Color(item.renkDegeri);
                          final itemIcon = _esyaIkonu(item.aksiyon);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF030712),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: itemColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: itemColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: itemColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Icon(itemIcon, color: itemColor, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.ad,
                                            style: TextStyle(color: itemColor, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              'x${item.adet}',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.aciklama,
                                        style: const TextStyle(color: sysTextMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: itemColor.withValues(alpha: 0.15),
                                    side: BorderSide(color: itemColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  onPressed: () {
                                    final rapor = SystemMemory.esyaKullan(item.aksiyon);
                                    setSheetState(() {});
                                    setState(() {});
                                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                                      SnackBar(content: Text(rapor), backgroundColor: Colors.green),
                                    );
                                  },
                                  child: Text(TranslationManager.get('shop_use_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: sysDarkBg,
          appBar: AppBar(
            title: Text(
              TranslationManager.get('shop_title'),
              style: GoogleFonts.rajdhani(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: physicalGold),
            actions: [
              IconButton(
                icon: const Icon(Icons.backpack, color: physicalGold, size: 24),
                tooltip: TranslationManager.get('shop_bag_title'),
                onPressed: _cantayiGoster,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF070B14), border: Border(bottom: BorderSide(color: physicalGold.withValues(alpha: 0.5), width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on, color: physicalGold, size: 40),
                    const SizedBox(width: 15),
                    ValueListenableBuilder(
                      valueListenable: SystemMemory.altin,
                      builder: (context, altinDegeri, child) {
                        return Text('$altinDegeri', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold));
                      }
                    )
                  ],
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: marketEsyalari.length,
                  itemBuilder: (context, index) {
                    var esya = marketEsyalari[index];
                    return HologramCard(
                      neonRenk: esya["renk"], padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: esya["renk"].withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: esya["renk"].withOpacity(0.5))), child: Icon(esya["ikon"], color: esya["renk"], size: 30)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(esya["ad"], style: TextStyle(color: esya["renk"], fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(esya["aciklama"], style: const TextStyle(color: sysTextMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _satinAl(esya),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: physicalGold.withValues(alpha: 0.15), side: const BorderSide(color: physicalGold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                            ),
                            child: Text('${esya["fiyat"]} G', style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 14)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}