// lib/widgets/achievement_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_system.dart';
import '../controllers/system_memory.dart';

class AchievementDialog extends StatefulWidget {
  final String title;
  final String message;
  final int tier;
  final String? targetUnlocked;

  const AchievementDialog({
    super.key,
    required this.title,
    required this.message,
    this.tier = 1,
    this.targetUnlocked,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
  }) async {
    // Parse message if formatted as "[ACHIEVEMENT ASCENDED]\nTitle (Tier X)\nTarget Unlocked: ..."
    String title = "ACHIEVEMENT ASCENDED";
    int tier = 1;
    String target = "";

    final lines = message.split('\n');
    if (lines.isNotEmpty) {
      if (lines[0].contains('ACHIEVEMENT')) {
        if (lines.length > 1) {
          title = lines[1];
          // Try parse tier number
          final match = RegExp(r'Tier (\d+)').firstMatch(title);
          if (match != null) {
            tier = int.tryParse(match.group(1) ?? '1') ?? 1;
          }
        }
        if (lines.length > 2) {
          target = lines.sublist(2).join('\n');
        }
      } else {
        title = lines[0];
        if (lines.length > 1) target = lines.sublist(1).join('\n');
      }
    }

    AudioSystem.playLevelUp();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AchievementDialog',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return AchievementDialog(
          title: title,
          message: message,
          tier: tier,
          targetUnlocked: target.isNotEmpty ? target : null,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color gold = Color(0xFFEAB308);
  static const Color sysBlue = Color(0xFF38BDF8);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!SystemMemory.isTest) {
      _pulseController.repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _yildizlar(int tier) {
    int count = tier.clamp(1, 6);
    return '★' * count + '☆' * (6 - count);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF030712),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: sysBlue.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // System Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: gold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  "[ SYSTEM ANNOUNCEMENT ]",
                  style: GoogleFonts.orbitron(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Animated Glowing Badge
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gold.withValues(alpha: 0.15),
                    border: Border.all(color: gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: gold,
                    size: 46,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subheader
              Text(
                "ACHIEVEMENT ASCENDED",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),

              // Stars (Tier)
              Text(
                _yildizlar(widget.tier),
                style: const TextStyle(
                  color: gold,
                  fontSize: 18,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),

              // Achievement Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        color: sysBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (widget.targetUnlocked != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.targetUnlocked!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Claim Reward Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 6,
                    shadowColor: gold.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    AudioSystem.playSuccess();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "ACCEPT REWARD",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
