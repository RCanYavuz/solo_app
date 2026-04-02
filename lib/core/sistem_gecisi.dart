// lib/core/sistem_gecisi.dart
import 'package:flutter/material.dart';
import 'audio_system.dart'; // YENİ: Ses sistemini içe aktardık

// SİSTEME ÖZEL HOLOGRAM GEÇİŞ MOTORU
class SistemGecisi extends PageRouteBuilder {
  final Widget sayfa;
  
  SistemGecisi({required this.sayfa})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => sayfa,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut)
            );

            var scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack)
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        ) {
          // YENİ: Bu geçiş motoru her çağırıldığında (yeni sayfa açıldığında) sesi otomatik çalar!
          AudioSystem.playTransition();
        }
}