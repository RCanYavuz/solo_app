// Dosya: lib/main.dart

import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const SoloApp());
}

class SoloApp extends StatelessWidget {
  const SoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.systemBlue,
          secondary: AppColors.questGold,
          error: AppColors.errorRed,
          surface: AppColors.background,
        ),
      ),
      home: const SetupScreen(),
    );
  }
}
