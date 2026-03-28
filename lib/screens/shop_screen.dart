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
  static const Color systemBlue = Color(0xFF389EFF); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color deepBlack = Colors.black; 
  static const Color cardBg = Color(0xFF0D0D0D); 

  // Market Eşyaları (Fiyat, Ad, Açıklama, İkon, Kategori)
  final List<Map<String, dynamic>> marketEsyalari = [
    // SİSTEM İKSİRLERİ
    {"ad": "Şifa İksiri", "fiyat": 150, "aciklama": "HP (Can) değerini anında tamamen doldurur.", "ikon": Icons.favorite, "renk": Colors.redAccent, "aksiyon": "hp_full"},
    {"ad": "Unutuş Suyu", "fiyat": 1000, "aciklama": "Verilmiş tüm Statü puanlarını sıfırlar ve AP olarak iade eder.", "ikon": Icons.water_drop, "renk": Colors.purpleAccent, "aksiyon": "stat_reset"},
    
    // TÜKETİM / KAÇAMAKLAR
    {"ad": "Küçük Kaçamak", "fiyat": 200, "aciklama": "Bir adet çikolata/abur cubur yeme hakkı (Ceza yazılmaz).", "ikon": Icons.icecream, "renk": physicalGold, "aksiyon": "gercek_hayat"},
    {"ad": "Cheat Meal", "fiyat": 500, "aciklama": "Tek bir serbest öğün hakkı (Örn: Hamburger menü).", "ikon": Icons.fastfood, "renk": physicalGold, "aksiyon": "gercek_hayat"},
    {"ad": "Sonsuz Ziyafet", "fiyat": 2000, "aciklama": "1 Tam Günlük (Cheat Day) limitsiz yeme içme hakkı.", "ikon": Icons.restaurant, "renk": physicalGold, "aksiyon": "gercek_hayat"},

    // EĞLENCE / ZAMAN
    {"ad": "Oyun İzni (2 Saat)", "fiyat": 300, "aciklama": "Suçluluk duymadan oyun oynama / dizi izleme hakkı.", "ikon": Icons.sports_esports, "renk": systemBlue, "aksiyon": "gercek_hayat"},
    {"ad": "Tembellik Günü", "fiyat": 1500, "aciklama": "O gün hiçbir görev yapmasan bile Sistem sana ceza vermez.", "ikon": Icons.weekend, "renk": systemBlue, "aksiyon": "gercek_hayat"},

    // BÜYÜK ÖDÜLLER
    {"ad": "Materyal: Yeni Ekipman", "fiyat": 5000, "aciklama": "Gerçek hayatta kendine yeni bir ayakkabı/kıyafet/oyun al.", "ikon": Icons.shopping_cart, "renk": Colors.greenAccent, "aksiyon": "gercek_hayat"},
  ];

  void _satinAl(Map<String, dynamic> esya) {
    int fiyat = esya["fiyat"];
    if (SystemMemory.altin.value >= fiyat) {
      // Satın Alma Başarılı
      setState(() {
        SystemMemory.altin.value -= fiyat;
      });
      AudioSystem.playSuccess();
      
      // Özel Aksiyonlar
      if (esya["aksiyon"] == "hp_full") SystemMemory.acilSifa();
      if (esya["aksiyon"] == "stat_reset") SystemMemory.statuleriSifirla();

      SystemMemory.kaydet();
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('SİSTEM: "${esya["ad"]}" başarıyla alındı! ${esya["aksiyon"] == "gercek_hayat" ? "Ödülünü gerçek dünyada kullanabilirsin." : "Uygulandı."}'),
        backgroundColor: Colors.green, duration: const Duration(seconds: 3)
      ));
    } else {
      // Yetersiz Bakiye
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SİSTEM UYARISI: Yetersiz Altın.'),
        backgroundColor: Colors.redAccent, duration: Duration(seconds: 2)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepBlack,
      appBar: AppBar(title: Text('SİSTEM MARKETİ', style: GoogleFonts.orbitron(color: physicalGold, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF050A10), elevation: 0),
      body: Column(
        children: [
          // Bakiye Göstergesi
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardBg, border: Border(bottom: BorderSide(color: physicalGold.withOpacity(0.5), width: 2))),
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
          
          // Market Listesi
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
                            Text(esya["ad"], style: TextStyle(color: esya["renk"], fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(esya["aciklama"], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _satinAl(esya),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: physicalGold.withOpacity(0.15), side: const BorderSide(color: physicalGold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                        ),
                        child: Text('${esya["fiyat"]} G', style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 16)),
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