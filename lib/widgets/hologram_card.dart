// lib/widgets/hologram_card.dart
import 'package:flutter/material.dart';

class HologramCard extends StatelessWidget {
  final Widget child; 
  final Color neonRenk; 
  final EdgeInsetsGeometry? padding;

  const HologramCard({
    super.key, 
    required this.child, 
    // YENİ: Varsayılan renk artık orijinal sistemin Buz Mavisi (Icy Blue)
    this.neonRenk = const Color(0xFF38BDF8),
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // YENİ: Animedeki gibi koyu lacivert/siyah şeffaf cam arka plan
        color: const Color(0xFF070B14).withOpacity(0.85), 
        // YENİ: Animedeki paneller gibi daha keskin (az yuvarlatılmış) köşeler
        borderRadius: BorderRadius.circular(4), 
        // YENİ: İncecik ve zarif bir çerçeve çizgisi
        border: Border.all(color: neonRenk.withOpacity(0.4), width: 1.0), 
        boxShadow: [
          // YENİ: Parlama çok daha hafif ve dipten geliyor, göz yormuyor
          BoxShadow(
            color: neonRenk.withOpacity(0.08), 
            blurRadius: 10,
            spreadRadius: 1
          ) 
        ]
      ),
      child: child,
    );
  }
}