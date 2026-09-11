// lib/screens/instruction_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_system.dart'; 
import 'ana_ekran.dart'; 
import '../core/translation_manager.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {

  @override
  void initState() {
    super.initState();
    AudioSystem.playStartup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAŞLIK ---
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amberAccent, size: 50),
                    const SizedBox(height: 15),
                    Text(TranslationManager.get('instruction_title'), style: GoogleFonts.orbitron(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text(TranslationManager.get('instruction_subtitle'), style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- KURALLAR LİSTESİ ---
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _kuralKarti(
                      ikon: Icons.gavel, renk: Colors.redAccent, baslik: TranslationManager.get('instruction_r1_title'),
                      metin: TranslationManager.get('instruction_r1_desc')
                    ),
                    _kuralKarti(
                      ikon: Icons.trending_up, renk: Colors.amberAccent, baslik: TranslationManager.get('instruction_r2_title'),
                      metin: TranslationManager.get('instruction_r2_desc')
                    ),
                    _kuralKarti(
                      ikon: Icons.local_fire_department, renk: Colors.cyanAccent, baslik: TranslationManager.get('instruction_r3_title'),
                      metin: TranslationManager.get('instruction_r3_desc')
                    ),
                    _kuralKarti(
                      ikon: Icons.calendar_month, renk: Colors.purpleAccent, baslik: TranslationManager.get('instruction_r4_title'),
                      metin: TranslationManager.get('instruction_r4_desc')
                    ),
                    _kuralKarti(
                      ikon: Icons.warning_amber_rounded, renk: Colors.orangeAccent, baslik: TranslationManager.get('instruction_r5_title'),
                      metin: TranslationManager.get('instruction_r5_desc')
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- ONAY VE BAŞLAMA BUTONU ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AudioSystem.playTransition(); 
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnaEkran()));
                  },
                  icon: const Icon(Icons.login, color: Colors.cyanAccent),
                  label: Text(TranslationManager.get('instruction_confirm'), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1), padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Colors.cyanAccent, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _kuralKarti({required IconData ikon, required Color renk, required String baslik, required String metin}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(10), border: Border.all(color: renk.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(ikon, color: renk, size: 24), const SizedBox(width: 10), Text(baslik, style: GoogleFonts.orbitron(color: renk, fontSize: 16, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}