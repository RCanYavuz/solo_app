// lib/widgets/sleep_tracker_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/system_memory.dart';
import 'hologram_card.dart';

class SleepTrackerCard extends StatefulWidget {
  final VoidCallback? onSleepChanged;

  const SleepTrackerCard({super.key, this.onSleepChanged});

  @override
  State<SleepTrackerCard> createState() => _SleepTrackerCardState();
}

class _SleepTrackerCardState extends State<SleepTrackerCard> {
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color alertRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningGold = Color(0xFFF59E0B);
  static const Color mutedText = Color(0xFF94A3B8);

  void _uykuGuncelle(int yeniSaat) {
    if (yeniSaat < 0) yeniSaat = 0;
    if (yeniSaat > 16) yeniSaat = 16;
    setState(() {
      SystemMemory.uyunanSaat = yeniSaat;
    });
    SystemMemory.kaydet();
    if (widget.onSleepChanged != null) {
      widget.onSleepChanged!();
    }
  }

  String _durumMetni(int saat) {
    if (saat == 0) return "Henüz uyku verisi girilmedi.";
    if (saat < 6) return "⚠️ YETERSİZ: Yorgunluk artışı & MP kaybı!";
    if (saat < 7) return "⚖️ MİNİMAL: Bazal toparlanma sağlandı.";
    if (saat <= 9) return "✨ OPTİMAL: +2 MP & Tam Yorgunluk Arınması.";
    return "🛡️ DERİN HİBERNASYON: Maksimum hücre onarımı.";
  }

  Color _durumRengi(int saat) {
    if (saat == 0) return mutedText;
    if (saat < 6) return alertRed;
    if (saat < 7) return warningGold;
    if (saat <= 9) return successGreen;
    return sysBlue;
  }

  @override
  Widget build(BuildContext context) {
    final int saat = SystemMemory.uyunanSaat;
    final Color durumColor = _durumRengi(saat);

    return HologramCard(
      neonRenk: neonPurple,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: neonPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: neonPurple.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.nightlight_round, color: neonPurple, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "RECOVERY CHAMBER",
                    style: GoogleFonts.orbitron(
                      color: neonPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: durumColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: durumColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  saat >= 7 ? "STABLE" : (saat == 0 ? "IDLE" : "VULNERABLE"),
                  style: TextStyle(
                    color: durumColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Counter & Quick Controls
          Row(
            children: [
              // Main Sleep Hour Display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$saat',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HRS SLEPT',
                          style: GoogleFonts.rajdhani(
                            color: neonPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _durumMetni(saat),
                      style: TextStyle(
                        color: durumColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Plus & Minus Buttons
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
                      tooltip: 'Azalt',
                      onPressed: saat > 0 ? () => _uykuGuncelle(saat - 1) : null,
                    ),
                    Container(width: 1, height: 20, color: Colors.white12),
                    IconButton(
                      icon: const Icon(Icons.add, color: neonPurple, size: 18),
                      tooltip: 'Artır',
                      onPressed: saat < 16 ? () => _uykuGuncelle(saat + 1) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),

          // Quick Preset Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hızlı Seçim:",
                style: TextStyle(color: mutedText, fontSize: 11),
              ),
              Row(
                children: [6, 7, 8, 9].map((val) {
                  final bool active = saat == val;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => _uykuGuncelle(val),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? neonPurple.withValues(alpha: 0.25) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: active ? neonPurple : Colors.white12,
                            width: active ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          '${val}h',
                          style: TextStyle(
                            color: active ? Colors.white : mutedText,
                            fontSize: 11,
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
