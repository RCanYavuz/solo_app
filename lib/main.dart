// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/system_memory.dart'; 
import 'screens/setup_screen.dart'; 
import 'screens/ana_ekran.dart'; 
import 'core/audio_system.dart'; 
import 'core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  // Flutter motorunun tam yüklendiğinden emin ol
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await initializeService();
  }
  
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
      // Kayıt varsa doğrudan Ana Ekran, ilk kez açılıyorsa SetupScreen açılır
      home: SystemMemory.kayitBulundu ? const AnaEkran() : const SetupScreen(), 
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}
