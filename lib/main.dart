// Dosya: lib/main.dart

import 'package:flutter/material.dart';
import 'core/diyet_motoru.dart';

void main() {
  // SİSTEM TESTİ: Diyet motorumuzu çalıştırıp konsola yazdırıyoruz
  print("TEST SONUCU: ${DiyetMotoru.makroHesapla(80.0, "yag_yakma")}");
  
  runApp(const SoloApp());
}

class SoloApp extends StatelessWidget {
  const SoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kişisel Takip',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: Text('Sistem Test Ediliyor... Lütfen Konsola Bakınız.'),
        ),
      ),
    );
  }
}