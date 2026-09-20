// lib/widgets/awakening_test_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../core/audio_system.dart';

void showAwakeningTestDialog(BuildContext context, {VoidCallback? onCompleted}) {
  final TextEditingController benchCtrl = TextEditingController(
    text: SystemMemory.maxBench > 0 ? SystemMemory.maxBench.toStringAsFixed(0) : '',
  );
  final TextEditingController squatCtrl = TextEditingController(
    text: SystemMemory.maxSquat > 0 ? SystemMemory.maxSquat.toStringAsFixed(0) : '',
  );
  final TextEditingController deadliftCtrl = TextEditingController(
    text: SystemMemory.maxDeadlift > 0 ? SystemMemory.maxDeadlift.toStringAsFixed(0) : '',
  );

  // Calisthenics / Reps controllers
  final TextEditingController pushupCtrl = TextEditingController();
  final TextEditingController bwSquatCtrl = TextEditingController();
  final TextEditingController pullupCtrl = TextEditingController();

  // Combat Stamina controllers
  final TextEditingController patlayiciSinavCtrl = TextEditingController(
    text: SystemMemory.maxPatlayiciSinav > 0 ? SystemMemory.maxPatlayiciSinav.toString() : '',
  );
  final TextEditingController burpeeCtrl = TextEditingController(
    text: SystemMemory.maxBurpeeKondisyon > 0 ? SystemMemory.maxBurpeeKondisyon.toString() : '',
  );
  final TextEditingController plankCtrl = TextEditingController(
    text: SystemMemory.maxPlankSaniye > 0 ? SystemMemory.maxPlankSaniye.toString() : '',
  );
  final TextEditingController combatBarfiksCtrl = TextEditingController(
    text: SystemMemory.maxBarfiks > 0 ? SystemMemory.maxBarfiks.toString() : '',
  );

  // 0: Barbell 1RM, 1: Calisthenics Reps, 2: Combat Stamina
  int testMode = SystemMemory.dovusSporuYapiyorMu
      ? 2
      : (SystemMemory.ekipmanTuru == 'Vucut-Agirligi' ? 1 : 0);

  const Color physicalGold = Color(0xFFEAB308);
  const Color bloodRed = Color(0xFFEF4444);
  const Color sysTextMuted = Color(0xFF94A3B8);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          double bench = 0;
          double squat = 0;
          double deadlift = 0;
          double bw = SystemMemory.kilo > 0 ? SystemMemory.kilo : 70.0;

          int pSinav = 0;
          int pBurpee = 0;
          int pPlank = 0;
          int pBarfiks = 0;
          double combatScore = 0;

          String previewRank;

          if (testMode == 2) {
            // Combat Stamina
            pSinav = int.tryParse(patlayiciSinavCtrl.text.trim()) ?? 0;
            pBurpee = int.tryParse(burpeeCtrl.text.trim()) ?? 0;
            pPlank = int.tryParse(plankCtrl.text.trim()) ?? 0;
            pBarfiks = int.tryParse(combatBarfiksCtrl.text.trim()) ?? 0;
            bench = double.tryParse(benchCtrl.text.trim()) ?? 0;
            squat = double.tryParse(squatCtrl.text.trim()) ?? 0;
            deadlift = double.tryParse(deadliftCtrl.text.trim()) ?? 0;

            combatScore = (pSinav * 2.0) +
                (pBurpee * 3.0) +
                ((pPlank / 10).clamp(0, 18) * 2.0) +
                (pBarfiks * 4.0);

            if (pSinav == 0 && pBurpee == 0 && pPlank == 0 && pBarfiks == 0 && bench == 0 && squat == 0 && deadlift == 0) {
              previewRank = SystemMemory.hunterRank;
            } else {
              previewRank = SystemMemory.hesaplaDovusRank(
                patlayiciSinav: pSinav,
                burpeeKondisyon: pBurpee,
                plankSaniye: pPlank,
                barfiks: pBarfiks,
                bench: bench > 0 ? bench : null,
                squat: squat > 0 ? squat : null,
                deadlift: deadlift > 0 ? deadlift : null,
                kilo: bw,
              );
            }
          } else if (testMode == 1) {
            // Calisthenics Reps
            double pReps = double.tryParse(pushupCtrl.text.trim()) ?? 0;
            double sReps = double.tryParse(bwSquatCtrl.text.trim()) ?? 0;
            double puReps = double.tryParse(pullupCtrl.text.trim()) ?? 0;

            if (pReps > 0) bench = bw * (0.60 + (pReps * 0.015));
            if (sReps > 0) squat = bw * (0.75 + (sReps * 0.02));
            if (puReps > 0) deadlift = bw * (0.80 + (puReps * 0.035));

            double total = bench + squat + deadlift;
            double ratio = total / bw;

            if (total == 0) {
              previewRank = SystemMemory.hunterRank;
            } else if (ratio >= 4.5) {
              previewRank = "S-Rank (Monarch)";
            } else if (ratio >= 3.75) {
              previewRank = "A-Rank (National)";
            } else if (ratio >= 3.0) {
              previewRank = "B-Rank (Elite)";
            } else if (ratio >= 2.25) {
              previewRank = "C-Rank (Knight)";
            } else if (ratio >= 1.5) {
              previewRank = "D-Rank (Hunter)";
            } else {
              previewRank = "E-Rank (Rookie)";
            }
          } else {
            // Barbell / DB 1RM
            bench = double.tryParse(benchCtrl.text.trim()) ?? 0;
            squat = double.tryParse(squatCtrl.text.trim()) ?? 0;
            deadlift = double.tryParse(deadliftCtrl.text.trim()) ?? 0;

            double total = bench + squat + deadlift;
            double ratio = total / bw;

            if (total == 0) {
              previewRank = SystemMemory.hunterRank;
            } else if (ratio >= 4.5) {
              previewRank = "S-Rank (Monarch)";
            } else if (ratio >= 3.75) {
              previewRank = "A-Rank (National)";
            } else if (ratio >= 3.0) {
              previewRank = "B-Rank (Elite)";
            } else if (ratio >= 2.25) {
              previewRank = "C-Rank (Knight)";
            } else if (ratio >= 1.5) {
              previewRank = "D-Rank (Hunter)";
            } else {
              previewRank = "E-Rank (Rookie)";
            }
          }

          double total = bench + squat + deadlift;
          double ratio = total / bw;

          return AlertDialog(
            backgroundColor: const Color(0xFF030712).withValues(alpha: 0.97),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: physicalGold, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            title: Row(
              children: [
                const Icon(Icons.flash_on, color: physicalGold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AWAKENING & RANK TEST',
                    style: GoogleFonts.orbitron(
                      color: physicalGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testMode == 2
                        ? 'Dövüş sporcusu rütbenizi belirlemek için patlayıcı şınav, burpee raund kondisyonu, plank ve barfiks gücünüzü test edin.'
                        : 'The System benchmarks your power against your body mass (${SystemMemory.kilo.toStringAsFixed(1)} kg) to evaluate your official Hunter Rank and adapt your quest regimen.',
                    style: const TextStyle(color: sysTextMuted, fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Mode Switcher (1RM Weight vs Calisthenics Reps vs Combat Stamina)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setDialogState(() => testMode = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: testMode == 0 ? physicalGold.withValues(alpha: 0.2) : Colors.transparent,
                              border: Border.all(color: testMode == 0 ? physicalGold : Colors.white24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                'BARBELL / DB 1RM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: testMode == 0 ? physicalGold : sysTextMuted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: InkWell(
                          onTap: () => setDialogState(() => testMode = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: testMode == 1 ? physicalGold.withValues(alpha: 0.2) : Colors.transparent,
                              border: Border.all(color: testMode == 1 ? physicalGold : Colors.white24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                'CALISTHENICS REPS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: testMode == 1 ? physicalGold : sysTextMuted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: InkWell(
                          onTap: () => setDialogState(() => testMode = 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: testMode == 2 ? physicalGold.withValues(alpha: 0.2) : Colors.transparent,
                              border: Border.all(color: testMode == 2 ? physicalGold : Colors.white24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                'COMBAT STAMINA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: testMode == 2 ? physicalGold : sysTextMuted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (testMode == 0) ...[
                    _inputField(
                      controller: benchCtrl,
                      label: 'Bench Press 1RM (kg)',
                      icon: Icons.fitness_center,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: squatCtrl,
                      label: 'Squat 1RM (kg)',
                      icon: Icons.airline_seat_legroom_extra,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: deadliftCtrl,
                      label: 'Deadlift 1RM (kg)',
                      icon: Icons.arrow_upward,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ] else if (testMode == 1) ...[
                    _inputField(
                      controller: pushupCtrl,
                      label: 'Max Push-ups (Reps to failure)',
                      icon: Icons.fitness_center,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: bwSquatCtrl,
                      label: 'Max Air Squats (Reps to failure)',
                      icon: Icons.airline_seat_legroom_extra,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: pullupCtrl,
                      label: 'Max Pull-ups (Reps to failure)',
                      icon: Icons.arrow_upward,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ] else ...[
                    _inputField(
                      controller: patlayiciSinavCtrl,
                      label: 'Patlayıcı Şınav (Plyo Push-ups - Reps)',
                      icon: Icons.bolt,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: burpeeCtrl,
                      label: '3 Dk Burpee (Raund Kondisyonu)',
                      icon: Icons.timer,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: plankCtrl,
                      label: 'Max Plank (Saniye)',
                      icon: Icons.shield,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: combatBarfiksCtrl,
                      label: 'Max Barfiks (Pull-up Reps)',
                      icon: Icons.arrow_upward,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: physicalGold, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'KUVVET & AĞIRLIK TESTİ (1RM - OPSİYONEL)',
                            style: const TextStyle(
                              color: physicalGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: benchCtrl,
                      label: 'Bench Press 1RM (kg - Opsiyonel)',
                      icon: Icons.fitness_center,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: squatCtrl,
                      label: 'Squat 1RM (kg - Opsiyonel)',
                      icon: Icons.airline_seat_legroom_extra,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: deadliftCtrl,
                      label: 'Deadlift 1RM (kg - Opsiyonel)',
                      icon: Icons.arrow_upward,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Live Metrics Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: physicalGold.withValues(alpha: 0.08),
                      border: Border.all(color: physicalGold.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (testMode == 2) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Combat Power Index:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text('${combatScore.toStringAsFixed(1)} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Striker Discipline:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text(SystemMemory.dovusBransi, style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          if (total > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Bonus 1RM Strength:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                                Text('${total.toStringAsFixed(0)} kg (${ratio.toStringAsFixed(2)}x BW)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ],
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(testMode == 1 ? 'Est. Total Strength:' : 'Total Lifted:', style: const TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text('${total.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Strength Ratio:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                              Text('${ratio.toStringAsFixed(2)}x BW', style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        const Divider(color: Colors.white12, thickness: 0.5),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Calculated Rank:', style: TextStyle(color: sysTextMuted, fontSize: 11)),
                            Text(
                              previewRank,
                              style: GoogleFonts.orbitron(
                                color: physicalGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL', style: TextStyle(color: sysTextMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: physicalGold.withValues(alpha: 0.2),
                  side: const BorderSide(color: physicalGold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () {
                  if (testMode == 2) {
                    final int sumCombat = pSinav + pBurpee + pPlank + pBarfiks;
                    final double sumWeights = bench + squat + deadlift;
                    if (sumCombat <= 0 && sumWeights <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Please enter valid performance numbers!'),
                          backgroundColor: bloodRed,
                        ),
                      );
                      return;
                    }

                    final bool isFirstAwakening = SystemMemory.hunterRank == "Unranked";
                    SystemMemory.dovusTestiKaydet(
                      patlayiciSinav: pSinav,
                      burpeeKondisyon: pBurpee,
                      plankSaniye: pPlank,
                      barfiks: pBarfiks,
                      bench: bench > 0 ? bench : null,
                      squat: squat > 0 ? squat : null,
                      deadlift: deadlift > 0 ? deadlift : null,
                      rank: previewRank,
                    );

                    Navigator.pop(ctx);
                    if (isFirstAwakening) {
                      AudioSystem.playLevelUp();
                    } else {
                      AudioSystem.playSuccess();
                    }

                    if (onCompleted != null) onCompleted();

                    final String weightSummary = sumWeights > 0 ? ' + ${sumWeights.toStringAsFixed(0)}kg Big3' : '';
                    _showRewardModal(context, previewRank, isFirstAwakening, 'Combat Stamina Score: ${combatScore.toStringAsFixed(1)} pts$weightSummary');
                  } else {
                    final tot = bench + squat + deadlift;
                    if (tot <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Please enter valid performance numbers!'),
                          backgroundColor: bloodRed,
                        ),
                      );
                      return;
                    }

                    final bool isFirstAwakening = SystemMemory.hunterRank == "Unranked";

                    SystemMemory.awakeningTestKaydet(
                      bench: bench,
                      squat: squat,
                      deadlift: deadlift,
                      rank: previewRank,
                    );

                    Navigator.pop(ctx);

                    if (isFirstAwakening) {
                      AudioSystem.playLevelUp();
                    } else {
                      AudioSystem.playSuccess();
                    }

                    if (onCompleted != null) {
                      onCompleted();
                    }

                    _showRewardModal(context, previewRank, isFirstAwakening, 'Total Power: ${total.toStringAsFixed(1)} kg (${ratio.toStringAsFixed(2)}x BW)');
                  }
                },
                child: const Text(
                  'SUBMIT DATA',
                  style: TextStyle(
                    color: physicalGold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showRewardModal(BuildContext context, String previewRank, bool isFirstAwakening, String subText) {
  const Color physicalGold = Color(0xFFEAB308);
  const Color sysTextMuted = Color(0xFF94A3B8);

  showDialog(
    context: context,
    builder: (awardCtx) => AlertDialog(
      backgroundColor: const Color(0xFF030712).withValues(alpha: 0.96),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: physicalGold, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      title: Center(
        child: Text(
          '[ AWAKENING REGISTERED ]',
          style: GoogleFonts.orbitron(
            color: physicalGold,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.military_tech, color: physicalGold, size: 48),
          const SizedBox(height: 12),
          Text(
            previewRank,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subText,
            style: const TextStyle(color: sysTextMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  'Quest Regimen recalibrated for Rank $previewRank!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (isFirstAwakening) ...[
                  const SizedBox(height: 6),
                  const Text(
                    '+100 EXP  |  +3 AP (Awakening Reward)',
                    style: TextStyle(color: physicalGold, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: physicalGold.withValues(alpha: 0.2),
              side: const BorderSide(color: physicalGold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () => Navigator.pop(awardCtx),
            child: const Text('SYSTEM ACKNOWLEDGE', style: TextStyle(color: physicalGold, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

Widget _inputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required ValueChanged<String> onChanged,
}) {
  const Color physicalGold = Color(0xFFEAB308);
  const Color sysTextMuted = Color(0xFF94A3B8);

  return TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: physicalGold, size: 18),
      labelText: label,
      labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: physicalGold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: physicalGold),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}
