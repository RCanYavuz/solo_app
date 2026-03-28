import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/system_memory.dart'; // Beyin
import 'screens/setup_screen.dart'; // Tarama Ekranı
import 'screens/ana_ekran.dart'; // Ana Ekran (Eğer kayıtlıysa direkt buraya)

// YENİ: main fonksiyonunu "async" yaptık ki hafızanın okunmasını beklesin
void main() async {
  // Flutter motorunun tam yüklendiğinden emin ol
  WidgetsFlutterBinding.ensureInitialized();
  
  // SİSTEM HAFIZASINI OKU VE YÜKLE
  await SystemMemory.baslat();

  runApp(const PlayerSystem());
}

class PlayerSystem extends StatelessWidget {
  const PlayerSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        textTheme: GoogleFonts.rajdhaniTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white, displayColor: Colors.cyanAccent,
        ),
      ),
      // YENİ: Mantıksal Yönlendirme
      // Eğer hafızada kayıt bulunduysa "AnaEkran" açılır, yoksa "SetupScreen" açılır
      home: SystemMemory.kayitBulundu ? const AnaEkran() : const SetupScreen(), 
    );
  }
}