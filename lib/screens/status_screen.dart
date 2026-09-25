// lib/screens/status_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../core/sistem_gecisi.dart';

import 'workout_planner_screen.dart';
import 'boxing_timer_screen.dart';
import 'workout_library_screen.dart';
import '../core/translation_manager.dart';
import '../core/audio_system.dart';

class StatusWindow extends StatefulWidget {
  const StatusWindow({super.key});
  @override
  State<StatusWindow> createState() => _StatusWindowState();
}

class _StatusWindowState extends State<StatusWindow> {
  @override
  Widget build(BuildContext context) {
    const Color sysBlue = Color(0xFF38BDF8);
    const Color sysDarkBg = Color(0xFF030712);
    const Color sysRed = Color(0xFFEF4444);
    const Color sysTextMuted = Color(0xFF94A3B8);

    int bugunIndex = DateTime.now().weekday;
    List<Gorev> bugununProgrami = SystemMemory.haftalikPlan[bugunIndex]!;

    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: sysDarkBg,
          appBar: AppBar(
            title: Text(
              TranslationManager.get('dash_status'),
              style: GoogleFonts.rajdhani(
                color: sysBlue,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 4.0,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center, color: sysBlue, size: 26),
            tooltip: TranslationManager.get('status_workout_lib_tooltip'),
            onPressed: () => Navigator.push(
              context,
              SistemGecisi(sayfa: const WorkoutLibraryScreen()),
            ).then((_) => setState(() {})),
          ),
          IconButton(
            icon: const Icon(Icons.sports_mma, color: sysRed, size: 28),
            tooltip: TranslationManager.get('status_combat_sim_tooltip'),
            onPressed: () => Navigator.push(
              context,
              SistemGecisi(sayfa: const BoxingTimerScreen()),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            SystemMemory.hp,
            SystemMemory.mp,
            SystemMemory.fatigue,
            SystemMemory.level,
            SystemMemory.exp,
            SystemMemory.ap,
            SystemMemory.str,
            SystemMemory.agi,
            SystemMemory.vit,
            SystemMemory.intStat,
            SystemMemory.per,
          ]),
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${SystemMemory.level.value}',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        TranslationManager.get('dash_level'),
                        style: const TextStyle(
                          color: sysBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXP',
                            style: GoogleFonts.rajdhani(
                              color: sysTextMuted,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: sysBlue.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  (SystemMemory.exp.value /
                                          SystemMemory.maxExp.value)
                                      .clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: sysBlue,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: sysBlue.withValues(alpha: 0.5),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${SystemMemory.exp.value} / ${SystemMemory.maxExp.value}',
                              style: const TextStyle(
                                color: sysTextMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14).withValues(alpha: 0.85),
                    border: Border.all(
                      color: sysBlue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.add_box,
                                color: Colors.white,
                                size: 24,
                              ),
                              Text(
                                'HP',
                                style: GoogleFonts.rajdhani(
                                  color: sysTextMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: sysBlue.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor:
                                        (SystemMemory.hp.value / SystemMemory.maxHp)
                                            .clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: sysBlue,
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: sysBlue.withValues(alpha: 0.5),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${SystemMemory.hp.value}/${SystemMemory.maxHp}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              const Icon(
                                Icons.science,
                                color: Colors.white,
                                size: 24,
                              ),
                              Text(
                                'MP',
                                style: GoogleFonts.rajdhani(
                                  color: sysTextMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: sysBlue.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor:
                                        (SystemMemory.mp.value / SystemMemory.maxMp)
                                            .clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: sysBlue,
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: sysBlue.withValues(alpha: 0.5),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${SystemMemory.mp.value}/${SystemMemory.maxMp}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, thickness: 1, height: 1),
                      const SizedBox(height: 10),
                      // --- SOLO LEVELING FATIGUE (YORGUNLUK) BARI ---
                      Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: SystemMemory.fatigue.value >= 80 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FATIGUE',
                            style: GoogleFonts.rajdhani(
                              color: SystemMemory.fatigue.value >= 80 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: (SystemMemory.fatigue.value >= 80 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)).withValues(alpha: 0.4),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (SystemMemory.fatigue.value / 100.0).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: SystemMemory.fatigue.value >= 80 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (SystemMemory.fatigue.value >= 80 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)).withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${SystemMemory.fatigue.value} / 100',
                            style: TextStyle(
                              color: SystemMemory.fatigue.value >= 80 ? const Color(0xFFEF4444) : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14).withValues(alpha: 0.85),
                    border: Border.all(
                      color: sysBlue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statRow(
                              Icons.fitness_center,
                              'STR',
                              SystemMemory.str.value,
                              sysBlue,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _statRow(
                              Icons.favorite,
                              'VIT',
                              SystemMemory.vit.value,
                              sysBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _statRow(
                              Icons.directions_run,
                              'AGI',
                              SystemMemory.agi.value,
                              sysBlue,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _statRow(
                              Icons.psychology,
                              'INT',
                              SystemMemory.intStat.value,
                              sysBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _statRow(
                              Icons.visibility,
                              'PER',
                              SystemMemory.per.value,
                              sysBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                TranslationManager.get('status_available_pts'),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: sysTextMuted,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '${SystemMemory.ap.value}',
                                style: GoogleFonts.orbitron(
                                  color: SystemMemory.ap.value > 0
                                      ? sysBlue
                                      : sysTextMuted,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (SystemMemory.ap.value > 0) ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () {
                                    final dagitilan = SystemMemory.otomatikStatDagit();
                                    AudioSystem.playLevelUp();
                                    setState(() {});
                                    final isTr = TranslationManager.isTurkish;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF0F172A),
                                        duration: const Duration(seconds: 3),
                                        content: Text(
                                          isTr
                                              ? '⚡ AKILLI DAĞITILDI: +${dagitilan['STR']} STR, +${dagitilan['AGI']} AGI, +${dagitilan['VIT']} VIT, +${dagitilan['INT']} INT, +${dagitilan['PER']} PER'
                                              : '⚡ AUTO ALLOCATED: +${dagitilan['STR']} STR, +${dagitilan['AGI']} AGI, +${dagitilan['VIT']} VIT, +${dagitilan['INT']} INT, +${dagitilan['PER']} PER',
                                          style: const TextStyle(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: sysBlue.withValues(alpha: 0.18),
                                      border: Border.all(color: sysBlue.withValues(alpha: 0.8)),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: sysBlue.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.flash_on, color: sysBlue, size: 12),
                                        const SizedBox(width: 3),
                                        Text(
                                          TranslationManager.isTurkish ? 'AKILLI DAĞIT' : 'AUTO ALLOCATE',
                                          style: GoogleFonts.orbitron(
                                            color: sysBlue,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              ValueListenableBuilder<bool>(
                                valueListenable: SystemMemory.otomatikStatDagitimiAktif,
                                builder: (context, autoActive, _) {
                                  return InkWell(
                                    onTap: () {
                                      SystemMemory.otomatikStatDagitimiAktif.value = !autoActive;
                                      SystemMemory.kaydet();
                                      setState(() {});
                                      final isTr = TranslationManager.isTurkish;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(0xFF0F172A),
                                          duration: const Duration(seconds: 2),
                                          content: Text(
                                            SystemMemory.otomatikStatDagitimiAktif.value
                                                ? (isTr
                                                    ? '⚡ Otomatik Stat Dağıtımı AÇIK: Kazanılan AP anında statlara eklenecek.'
                                                    : '⚡ Auto-Allocate ON: Earned AP will be automatically allocated to stats.')
                                                : (isTr
                                                    ? '💎 Manuel Stat Dağıtımı: AP puanları biriktirilip elle dağıtılacak.'
                                                    : '💎 Manual Stat Allocation: AP will be held for manual distribution.'),
                                            style: TextStyle(
                                              color: SystemMemory.otomatikStatDagitimiAktif.value ? sysBlue : sysTextMuted,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: autoActive ? sysBlue.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                                        border: Border.all(
                                          color: autoActive ? sysBlue : Colors.white24,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            autoActive ? Icons.check_circle : Icons.radio_button_unchecked,
                                            color: autoActive ? sysBlue : sysTextMuted,
                                            size: 11,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              TranslationManager.get('status_auto_allocate_toggle'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: autoActive ? sysBlue : sysTextMuted,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationManager.get('status_quests'),
                      style: GoogleFonts.orbitron(
                        color: sysBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_square,
                        color: sysBlue,
                        size: 20,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        SistemGecisi(sayfa: const WorkoutPlannerScreen()),
                      ).then((value) => setState(() {})),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: sysBlue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFF070B14).withValues(alpha: 0.85),
                  ),
                  child: bugununProgrami.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              TranslationManager.get('status_no_quests'),
                              style: const TextStyle(color: sysTextMuted),
                            ),
                          ),
                        )
                      : Column(
                          children: bugununProgrami.map<Widget>((gorev) {
                            return Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white12,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: CheckboxListTile(
                                secondary: Icon(
                                  gorev.tip == "Fiziksel"
                                      ? Icons.fitness_center
                                      : Icons.psychology,
                                  color: sysTextMuted,
                                  size: 18,
                                ),
                                title: Text(
                                  gorev.ad,
                                  style: TextStyle(
                                    color: gorev.yapildiMi
                                        ? sysTextMuted
                                        : Colors.white,
                                    fontSize: 14,
                                    decoration: gorev.yapildiMi
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                value: gorev.yapildiMi,
                                activeColor: sysBlue,
                                checkColor: sysDarkBg,
                                onChanged: (val) {
                                  setState(() {
                                    gorev.yapildiMi = val!;
                                  });
                                  SystemMemory.kaydet();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),

                Text(
                  TranslationManager.get('status_requirements'),
                  style: GoogleFonts.orbitron(
                    color: sysBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: sysBlue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFF070B14).withValues(alpha: 0.85),
                  ),
                  child: ListTile(
                    title: Text(
                      TranslationManager.get('status_sleep_title'),
                      style: const TextStyle(color: sysTextMuted, fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: sysBlue),
                          onPressed: () {
                            if (SystemMemory.uyunanSaat > 0) {
                              setState(() => SystemMemory.uyunanSaat--);
                              SystemMemory.kaydet();
                            }
                          },
                        ),
                        Text(
                          '${SystemMemory.uyunanSaat}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: sysBlue),
                          onPressed: () {
                            setState(() => SystemMemory.uyunanSaat++);
                            SystemMemory.kaydet();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
      },
    );
  }

  Widget _statRow(IconData icon, String label, int value, Color sysBlue) {
    bool canUpgrade = SystemMemory.ap.value > 0;
    return Row(
      children: [
        Icon(icon, color: sysBlue, size: 16),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF94A3B8),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (canUpgrade) ...[
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              SystemMemory.statuYukselt(label);
              setState(() {});
            },
            onLongPress: () {
              for (int i = 0; i < 5 && SystemMemory.ap.value > 0; i++) {
                SystemMemory.statuYukselt(label);
              }
              AudioSystem.playSuccess();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: sysBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Icon(Icons.add, color: sysBlue, size: 14),
            ),
          ),
        ],
      ],
    );
  }
}
