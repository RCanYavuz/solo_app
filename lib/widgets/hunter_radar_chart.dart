// lib/widgets/hunter_radar_chart.dart
// ============================================================
// SOLO LEVELING AVCI BİYOMETRİK RADAR GRAFİĞİ (PENTAGON)
// 5 Temel Statı (STR, AGI, VIT, INT, PER) beşgen radar ızgarası
// üzerinde holografik Solo Leveling HUD tarzında çizer.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/translation_manager.dart';

class HunterRadarChart extends StatelessWidget {
  final int str;
  final int agi;
  final int vit;
  final int intStat;
  final int per;
  final double size;

  const HunterRadarChart({
    super.key,
    required this.str,
    required this.agi,
    required this.vit,
    required this.intStat,
    required this.per,
    this.size = 260,
  });

  String get sinifAdi {
    final stats = {'STR': str, 'AGI': agi, 'VIT': vit, 'INT': intStat, 'PER': per};
    final enYuksek = stats.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final enDusuk = stats.entries.reduce((a, b) => a.value <= b.value ? a : b);

    if (enYuksek.value - enDusuk.value <= 4) {
      return TranslationManager.isTurkish ? 'ALL-ROUNDER (DENGELİ AVCI)' : 'ALL-ROUNDER (BALANCED HUNTER)';
    }

    switch (enYuksek.key) {
      case 'STR':
        return TranslationManager.isTurkish ? 'BERSERKER / AĞIR VURUŞÇU' : 'BERSERKER / HEAVY HITTER';
      case 'AGI':
        return TranslationManager.isTurkish ? 'ASSASSIN / GÖLGE SUİKASTÇİSİ' : 'ASSASSIN / SHADOW ASSASSIN';
      case 'VIT':
        return TranslationManager.isTurkish ? 'TANKER / KAYA MUHAFIZ' : 'TANK / ROCK GUARDIAN';
      case 'INT':
        return TranslationManager.isTurkish ? 'STRATEGIST / BÜYÜCÜ LİDER' : 'STRATEGIST / MAGE LEADER';
      case 'PER':
        return TranslationManager.isTurkish ? 'SCOUT / KESKİN SEZGİ' : 'SCOUT / SHARP PERCEPTION';
      default:
        return TranslationManager.isTurkish ? 'SAVAŞÇI' : 'WARRIOR';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF030712).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Sınıf Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationManager.isTurkish ? '[ BİYOMETRİK STAT RADARI ]' : '[ BIOMETRIC STAT RADAR ]',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                ),
                child: Text(
                  sinifAdi,
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFFF59E0B),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Radar Çizimi
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RadarPainter(
                str: str,
                agi: agi,
                vit: vit,
                intStat: intStat,
                per: per,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final int str;
  final int agi;
  final int vit;
  final int intStat;
  final int per;

  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysCyan = Color(0xFF06B6D4);

  _RadarPainter({
    required this.str,
    required this.agi,
    required this.vit,
    required this.intStat,
    required this.per,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 32;

    final List<String> etiketler = ['STR', 'AGI', 'VIT', 'INT', 'PER'];
    final List<int> degerler = [str, agi, vit, intStat, per];
    final int maxVal = degerler.reduce(max).clamp(20, 200);

    // 1. Konsantrik Izgara Beşgenleri (Grid)
    final gridPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int seviye = 1; seviye <= 4; seviye++) {
      final r = radius * (seviye / 4);
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 2 * pi / 5) - (pi / 2);
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Eksen Çizgileri
    final axisPaint = Paint()
      ..color = sysBlue.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(endX, endY), axisPaint);
    }

    // 2. Oyuncu Stat Poligonu (Dolgu ve Parlama)
    final polyPath = Path();
    final List<Offset> noktalar = [];

    for (int i = 0; i < 5; i++) {
      final oran = (degerler[i] / maxVal).clamp(0.2, 1.0);
      final r = radius * oran;
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      final point = Offset(x, y);
      noktalar.add(point);

      if (i == 0) {
        polyPath.moveTo(x, y);
      } else {
        polyPath.lineTo(x, y);
      }
    }
    polyPath.close();

    // Dolgu
    final fillPaint = Paint()
      ..color = sysBlue.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(polyPath, fillPaint);

    // Dış Kenar Çizgisi
    final strokePaint = Paint()
      ..color = sysCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(polyPath, strokePaint);

    // Noktalar
    final dotPaint = Paint()..color = Colors.white;
    for (final p in noktalar) {
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(p, 5.0, Paint()..color = sysCyan.withValues(alpha: 0.5)..style = PaintingStyle.stroke);
    }

    // 3. Etiket ve Değerler
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final labelRadius = radius + 22;
      final lx = center.dx + labelRadius * cos(angle);
      final ly = center.dy + labelRadius * sin(angle);

      final span = TextSpan(
        text: '${etiketler[i]}\n${degerler[i]}',
        style: GoogleFonts.orbitron(
          color: sysBlue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      );

      textPainter.text = span;
      textPainter.textAlign = TextAlign.center;
      textPainter.layout();
      textPainter.paint(canvas, Offset(lx - textPainter.width / 2, ly - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.str != str ||
        oldDelegate.agi != agi ||
        oldDelegate.vit != vit ||
        oldDelegate.intStat != intStat ||
        oldDelegate.per != per;
  }
}
