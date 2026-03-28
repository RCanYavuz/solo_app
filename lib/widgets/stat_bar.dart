import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int current;
  final int max;

  const StatBar({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    double ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0;
    
    return Row(
      children: [
        Column(
          children: [
            Icon(icon, color: color, size: 28), 
            Text(label, style: GoogleFonts.rajdhani(color: color, fontWeight: FontWeight.bold, fontSize: 16))
          ]
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: [
              Container(
                height: 12, width: double.infinity, 
                decoration: BoxDecoration(border: Border.all(color: color, width: 1), borderRadius: BorderRadius.circular(10)), 
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft, 
                  widthFactor: ratio, 
                  child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 10)]))
                )
              ),
              const SizedBox(height: 5), 
              Text('$current/$max', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]
          )
        ),
      ],
    );
  }
}