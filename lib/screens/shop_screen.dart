// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color cardBg = Color(0xFF0F172A); 
  static const Color sysTextMuted = Color(0xFF94A3B8);

  final List<Map<String, dynamic>> marketEsyalari = [
    // POTIONS
    {"ad": "Healing Potion", "fiyat": 150, "aciklama": "Restores your HP to maximum instantly.", "ikon": Icons.favorite, "renk": const Color(0xFFEF4444), "aksiyon": "hp_full"},
    {"ad": "Water of Lethe", "fiyat": 1000, "aciklama": "Resets all allocated Stat Points and refunds AP.", "ikon": Icons.water_drop, "renk": const Color(0xFFA060E0), "aksiyon": "stat_reset"},
    
    // CHEATS / SNACKS
    {"ad": "Minor Cheat", "fiyat": 200, "aciklama": "Eat one small snack (e.g., chocolate) without penalty.", "ikon": Icons.icecream, "renk": physicalGold, "aksiyon": "gercek_hayat"},
    {"ad": "Cheat Meal", "fiyat": 500, "aciklama": "One free cheat meal (e.g., Burger Menu).", "ikon": Icons.fastfood, "renk": physicalGold, "aksiyon": "gercek_hayat"},
    {"ad": "Endless Feast", "fiyat": 2000, "aciklama": "1 Full Cheat Day. Eat limitlessly.", "ikon": Icons.restaurant, "renk": physicalGold, "aksiyon": "gercek_hayat"},

    // ENTERTAINMENT
    {"ad": "Gaming Pass (2 Hrs)", "fiyat": 300, "aciklama": "Play games or watch series guilt-free.", "ikon": Icons.sports_esports, "renk": sysBlue, "aksiyon": "gercek_hayat"},
    {"ad": "Sloth Day", "fiyat": 1500, "aciklama": "Skip all quests today without System penalty.", "ikon": Icons.weekend, "renk": sysBlue, "aksiyon": "gercek_hayat"},

    // REWARDS
    {"ad": "Material: New Gear", "fiyat": 5000, "aciklama": "Buy yourself a real-life reward (clothes, games).", "ikon": Icons.shopping_cart, "renk": Colors.greenAccent, "aksiyon": "gercek_hayat"},
  ];

  void _satinAl(Map<String, dynamic> esya) {
    int fiyat = esya["fiyat"];
    if (SystemMemory.altin.value >= fiyat) {
      setState(() { SystemMemory.altin.value -= fiyat; });
      AudioSystem.playSuccess();
      
      if (esya["aksiyon"] == "hp_full") SystemMemory.acilSifa();
      if (esya["aksiyon"] == "stat_reset") SystemMemory.statuleriSifirla();

      SystemMemory.kaydet();
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('SYSTEM: "${esya["ad"]}" acquired! ${esya["aksiyon"] == "gercek_hayat" ? "Use this reward in the real world." : "Effect applied."}'),
        backgroundColor: Colors.green, duration: const Duration(seconds: 3)
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SYSTEM WARNING: Insufficient Gold.'),
        backgroundColor: Color(0xFFEF4444), duration: Duration(seconds: 2)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg,
      appBar: AppBar(title: Text('S Y S T E M   S H O P', style: GoogleFonts.rajdhani(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: physicalGold)),
      body: Column(
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF070B14), border: Border(bottom: BorderSide(color: physicalGold.withOpacity(0.5), width: 1))),
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
                          backgroundColor: physicalGold.withOpacity(0.15), side: const BorderSide(color: physicalGold),
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
  }
}