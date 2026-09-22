// lib/screens/instruction_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_system.dart';
import 'ana_ekran.dart';
import '../core/translation_manager.dart';
import '../widgets/hologram_card.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysDarkBg = Color(0xFF030712);
  static const Color sysGold = Color(0xFFB08D57);
  static const Color sysRed = Color(0xFFEF4444);
  static const Color sysPurple = Color(0xFFA855F7);
  static const Color sysOrange = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    AudioSystem.playStartup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sysDarkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAŞLIK ---
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.shield_outlined, color: sysBlue, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      TranslationManager.get('instruction_title'),
                      style: GoogleFonts.orbitron(
                        color: sysBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      TranslationManager.get('instruction_subtitle'),
                      style: GoogleFonts.rajdhani(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- KURALLAR LİSTESİ ---
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _kuralKarti(
                      ikon: Icons.gavel,
                      renk: sysRed,
                      baslik: TranslationManager.get('instruction_r1_title'),
                      metin: TranslationManager.get('instruction_r1_desc'),
                    ),
                    _kuralKarti(
                      ikon: Icons.trending_up,
                      renk: sysGold,
                      baslik: TranslationManager.get('instruction_r2_title'),
                      metin: TranslationManager.get('instruction_r2_desc'),
                    ),
                    _kuralKarti(
                      ikon: Icons.local_fire_department,
                      renk: sysBlue,
                      baslik: TranslationManager.get('instruction_r3_title'),
                      metin: TranslationManager.get('instruction_r3_desc'),
                    ),
                    _kuralKarti(
                      ikon: Icons.calendar_month,
                      renk: sysPurple,
                      baslik: TranslationManager.get('instruction_r4_title'),
                      metin: TranslationManager.get('instruction_r4_desc'),
                    ),
                    _kuralKarti(
                      ikon: Icons.warning_amber_rounded,
                      renk: sysOrange,
                      baslik: TranslationManager.get('instruction_r5_title'),
                      metin: TranslationManager.get('instruction_r5_desc'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- ONAY VE BAŞLAMA BUTONU ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AudioSystem.playTransition();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AnaEkran(playStartupSound: false)),
                    );
                  },
                  icon: const Icon(Icons.login, color: sysBlue),
                  label: Text(
                    TranslationManager.get('instruction_confirm'),
                    style: GoogleFonts.orbitron(
                      color: sysBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysBlue.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: sysBlue, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kuralKarti({
    required IconData ikon,
    required Color renk,
    required String baslik,
    required String metin,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HologramCard(
        neonRenk: renk,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ikon, color: renk, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    baslik,
                    style: GoogleFonts.orbitron(
                      color: renk,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metin,
              style: GoogleFonts.rajdhani(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}