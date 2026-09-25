// lib/widgets/global_timer_hud.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/system_session_manager.dart';
import '../core/sistem_gecisi.dart';
import '../core/translation_manager.dart';
import '../screens/deep_work_timer_screen.dart';

/// Tüm uygulama boyunca arka planda veya diğer sekmelerde gezinirken
/// aktif olan Deep Work veya Dinlenme Sayacını gösteren, tıklanabilir
/// ve kontrol edilebilir yüzen Cyberpunk Hologram HUD çubuğu.
class GlobalTimerHUD extends StatelessWidget {
  const GlobalTimerHUD({super.key});

  String _formatTime(int totalSec) {
    final minutes = (totalSec ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSec % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SystemSessionManager.instance,
      builder: (context, _) {
        final manager = SystemSessionManager.instance;
        final deepWork = manager.deepWork;
        final restTimer = manager.restTimer;

        // 1. Önce Rest Timer (Dinlenme) aktifse onu göster
        if (restTimer.isRunning && restTimer.isMinimized) {
          return _buildRestTimerHUD(context, manager, restTimer);
        }

        // 2. Deep Work aktifse ve çalışıyorsa göster
        if (deepWork.isRunning) {
          return _buildDeepWorkHUD(context, manager, deepWork);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDeepWorkHUD(
    BuildContext context,
    SystemSessionManager manager,
    DeepWorkSessionState deepWork,
  ) {
    final isFocus = deepWork.phase == DeepWorkPhase.focus;
    final themeColor = isFocus ? const Color(0xFF38BDF8) : Colors.purpleAccent;
    final isTr = TranslationManager.isTurkish;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeColor.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              SistemGecisi(
                sayfa: DeepWorkTimerScreen(
                  initialTopic: deepWork.topic,
                  initialMinutes: deepWork.focusMinutes,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // İlerleme Dairesi / İkon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        value: deepWork.progress,
                        strokeWidth: 3.5,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    ),
                    Icon(
                      isFocus ? Icons.psychology : Icons.self_improvement,
                      color: themeColor,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Başlık ve Konu Bilgisi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            isFocus
                                ? (isTr ? 'BİLİŞSEL ZİNDAN' : 'DEEP WORK')
                                : (isTr ? 'DİNLENME MODU' : 'RECOVERY'),
                            style: GoogleFonts.orbitron(
                              color: themeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              _formatTime(deepWork.remainingSeconds),
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deepWork.topic.isNotEmpty
                            ? deepWork.topic
                            : (isTr ? 'Odaklanma Seansı' : 'Focus Session'),
                        style: GoogleFonts.rajdhani(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Kontrol Butonları
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        deepWork.isPaused ? Icons.play_arrow : Icons.pause,
                        color: themeColor,
                        size: 22,
                      ),
                      tooltip: deepWork.isPaused ? 'Devam Et' : 'Duraklat',
                      onPressed: () {
                        if (deepWork.isPaused) {
                          manager.resumeDeepWork();
                        } else {
                          manager.pauseDeepWork();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 22),
                      tooltip: isTr ? 'Büyüt' : 'Expand',
                      onPressed: () {
                        Navigator.push(
                          context,
                          SistemGecisi(
                            sayfa: DeepWorkTimerScreen(
                              initialTopic: deepWork.topic,
                              initialMinutes: deepWork.focusMinutes,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestTimerHUD(
    BuildContext context,
    SystemSessionManager manager,
    RestTimerSessionState restTimer,
  ) {
    const gold = Color(0xFFEAB308);
    final isTr = TranslationManager.isTurkish;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gold.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, color: gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        isTr ? 'DİNLENME' : 'REST TIMER',
                        style: GoogleFonts.orbitron(
                          color: gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${restTimer.remainingSeconds}s',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (restTimer.exerciseName != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      restTimer.exerciseName!,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: gold.withValues(alpha: 0.2),
              ),
              onPressed: () => manager.addRestSeconds(30),
              child: Text(
                '+30s',
                style: GoogleFonts.orbitron(color: gold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60, size: 18),
              onPressed: () => manager.stopRestTimer(),
            ),
          ],
        ),
      ),
    );
  }
}
