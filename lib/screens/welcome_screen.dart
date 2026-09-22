// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'instruction_screen.dart';
import '../core/translation_manager.dart';
import '../widgets/hologram_card.dart';
import '../core/audio_system.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysDarkBg = Color(0xFF030712);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: HologramCard(
            neonRenk: sysBlue,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on, color: sysBlue, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      TranslationManager.get('welcome_init'),
                      style: GoogleFonts.orbitron(
                        color: sysBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sysBlue.withValues(alpha: 0.1),
                        sysBlue,
                        sysBlue.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  TranslationManager.get('welcome_message'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AudioSystem.playTransition();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const InstructionScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sysBlue.withValues(alpha: 0.15),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: sysBlue, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(
                      TranslationManager.get('welcome_start'),
                      style: GoogleFonts.orbitron(
                        color: sysBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}