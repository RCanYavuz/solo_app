// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/system_memory.dart'; 
import 'screens/setup_screen.dart'; 
import 'screens/instruction_screen.dart'; 
import 'core/audio_system.dart'; 
import 'core/theme/app_colors.dart';

void main() async {
  // Flutter motorunun tam yüklendiğinden emin ol
  WidgetsFlutterBinding.ensureInitialized();
  
  // SİSTEM HAFIZASINI OKU VE YÜKLE
  await SystemMemory.baslat();

  // SES SİSTEMİNİ BAŞLAT
  await AudioSystem.init();

  runApp(const SoloApp());
}

class SoloApp extends StatelessWidget {
  const SoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.systemBlue,
          secondary: AppColors.questGold,
          error: AppColors.errorRed,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white, 
          displayColor: AppColors.systemBlue,
        ),
      ),
      // Başlangıç ekranı olarak doğrudan Avcı Kayıt Ekranı (SetupScreen) açılır
      home: const SetupScreen(), 
    );
  }
}
