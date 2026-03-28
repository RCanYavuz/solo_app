import 'package:flutter/material.dart';

// SİSTEME ÖZEL HOLOGRAM GEÇİŞ MOTORU
class SistemGecisi extends PageRouteBuilder {
  final Widget sayfa;
  
  SistemGecisi({required this.sayfa})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => sayfa,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            
            // 1. Ekran yavaşça aydınlanır (Fade)
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut)
            );

            // 2. Ekran geriden gelip öne doğru oturur (Scale)
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
        );
}