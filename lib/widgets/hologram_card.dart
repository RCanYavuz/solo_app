// lib/widgets/hologram_card.dart
import 'package:flutter/material.dart';

class HologramCard extends StatelessWidget {
  final Widget child; 
  final Color neonRenk; 
  final EdgeInsetsGeometry? padding;

  const HologramCard({
    super.key, 
    required this.child, 
    this.neonRenk = Colors.cyanAccent,
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // YENİ: "Karanlık Ton" (Derin Koyu Gri). Neonları parlatır.
        color: const Color(0xFF0D0D0D), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neonRenk.withOpacity(0.25)), // Sınır çizgisi biraz daha belirgin
        boxShadow: [
          // YENİ: Parlama efektini biraz daha kısık yapıyoruz ki derinlik hissi artsın.
          BoxShadow(
            color: neonRenk.withOpacity(0.04), 
            blurRadius: 15
          ) 
        ]
      ),
      child: child,
    );
  }
}