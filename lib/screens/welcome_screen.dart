// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'instruction_screen.dart'; // YENİ: Kurallar ekranı yolu

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Simsiyah fonda açılır, karmaşayı çözer.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D), 
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyanAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.15), 
                  blurRadius: 20, 
                  spreadRadius: 2
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "[ SİSTEM HOŞ GELDİNİZ ]",
                  style: GoogleFonts.orbitron(
                    color: Colors.cyanAccent, 
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(color: Colors.cyanAccent, thickness: 1),
                const SizedBox(height: 20),
                Text(
                  "Tebrikler, Avcı.\nTaramayı tamamladınız.\nŞimdi Sisteme tam erişim sağladınız.\n[UYANMAK İÇİN ONAYLA]",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white, 
                    fontSize: 18, 
                    height: 1.5, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // YENİ: Sisteme ilk girişte doğrudan Kılavuz'a yönlendirilir
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InstructionScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                    ),
                    child: const Text(
                      'SİSTEMİ BAŞLAT',
                      style: TextStyle(
                        color: Colors.cyanAccent, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 2
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