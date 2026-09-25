// lib/screens/analytics_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../core/translation_manager.dart';
import '../widgets/hologram_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color sysCyan = Color(0xFF38BDF8);
  static const Color sysGold = Color(0xFFF59E0B);
  static const Color sysGreen = Color(0xFF10B981);
  static const Color sysRed = Color(0xFFEF4444);
  static const Color sysPurple = Color(0xFFA855F7);
  static const Color sysTextMuted = Color(0xFF94A3B8);
  static const Color sysDarkBg = Color(0xFF030712);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: sysDarkBg,
          appBar: AppBar(
            backgroundColor: const Color(0xFF070B14),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: sysCyan, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              TranslationManager.get('analytics_title'),
              style: GoogleFonts.orbitron(
                color: sysCyan,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: sysCyan,
              indicatorWeight: 3,
              labelColor: sysCyan,
              unselectedLabelColor: sysTextMuted,
              labelStyle: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 10),
              tabs: [
                Tab(
                  icon: const Icon(Icons.show_chart, size: 18),
                  text: TranslationManager.get('analytics_tab_weight'),
                ),
                Tab(
                  icon: const Icon(Icons.fitness_center, size: 18),
                  text: TranslationManager.get('analytics_tab_workout'),
                ),
                Tab(
                  icon: const Icon(Icons.restaurant, size: 18),
                  text: TranslationManager.get('analytics_tab_diet'),
                ),
                Tab(
                  icon: const Icon(Icons.military_tech, size: 18),
                  text: TranslationManager.get('analytics_tab_strength'),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildWeightTab(),
              _buildWorkoutTab(),
              _buildDietTab(),
              _buildStrengthTab(),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. KİLO TRENDİ TABI
  // ==========================================
  Widget _buildWeightTab() {
    final history = SystemMemory.kiloGecmisi;
    final currentWeight = SystemMemory.kilo;
    final targetWeight = SystemMemory.hedefKilo;

    double firstWeight = currentWeight;
    double minWeight = currentWeight;
    double maxWeight = currentWeight;
    double totalWeight = 0;

    List<double> weightPoints = [];
    List<String> dateLabels = [];

    if (history.isNotEmpty) {
      try {
        firstWeight = (history.first['kilo'] as num).toDouble();
      } catch (_) {}

      for (var entry in history) {
        try {
          final w = (entry['kilo'] as num).toDouble();
          weightPoints.add(w);
          final tStr = entry['tarih']?.toString() ?? '';
          if (tStr.length >= 10) {
            dateLabels.add('${tStr.substring(8, 10)}/${tStr.substring(5, 7)}');
          } else {
            dateLabels.add('');
          }
          if (w < minWeight) minWeight = w;
          if (w > maxWeight) maxWeight = w;
          totalWeight += w;
        } catch (_) {}
      }
    }

    if (weightPoints.isEmpty) {
      weightPoints.add(currentWeight);
      dateLabels.add(TranslationManager.isTurkish ? 'Bugün' : 'Today');
    }

    final avgWeight = totalWeight > 0 ? (totalWeight / history.length) : currentWeight;
    final delta = currentWeight - firstWeight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrik Özet Kartları
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_current_weight'),
                  value: '${currentWeight.toStringAsFixed(1)} kg',
                  accentColor: sysCyan,
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_target_weight'),
                  value: '${targetWeight.toStringAsFixed(1)} kg',
                  accentColor: sysGold,
                  icon: Icons.flag_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_weight_delta'),
                  value: '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                  accentColor: delta <= 0 ? sysGreen : sysRed,
                  icon: delta <= 0 ? Icons.trending_down : Icons.trending_up,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  title: TranslationManager.isTurkish ? 'MİN / MAKS' : 'MIN / MAX',
                  value: '${minWeight.toStringAsFixed(1)} / ${maxWeight.toStringAsFixed(1)}',
                  accentColor: sysPurple,
                  icon: Icons.swap_vert,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Çizgi Grafik Kartı
          HologramCard(
            neonRenk: sysCyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationManager.isTurkish ? 'KİLO GELİŞİM EĞRİSİ' : 'WEIGHT TRAJECTORY',
                      style: GoogleFonts.orbitron(color: sysCyan, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      '${TranslationManager.isTurkish ? 'Ort.' : 'Avg:'} ${avgWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: sysTextMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _WeightLineChartPainter(
                      points: weightPoints,
                      dateLabels: dateLabels,
                      targetWeight: targetWeight,
                      lineColor: sysCyan,
                      targetColor: sysGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 3, color: sysCyan),
                    const SizedBox(width: 6),
                    Text(TranslationManager.isTurkish ? 'Kilo Kayıtları' : 'Weight Log', style: const TextStyle(color: sysTextMuted, fontSize: 11)),
                    const SizedBox(width: 18),
                    Container(width: 12, height: 2, color: sysGold),
                    const SizedBox(width: 6),
                    Text(TranslationManager.isTurkish ? 'Hedef Çizgisi' : 'Target Baseline', style: const TextStyle(color: sysTextMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (history.isEmpty)
            _emptyNotice(TranslationManager.get('analytics_no_weight_data')),
        ],
      ),
    );
  }

  // ==========================================
  // 2. İDMAN HACMİ & YAKIM TABI
  // ==========================================
  Widget _buildWorkoutTab() {
    final raids = SystemMemory.idmanGecmisi;
    final totalWorkoutMins = SystemMemory.toplamIdmanDakikasi;

    int totalRaids = raids.length;
    int totalBurnedCalories = 0;

    List<double> recentMinutes = [];
    List<String> raidLabels = [];

    // Son 10 idman
    final recent = raids.length > 10 ? raids.sublist(raids.length - 10) : raids;
    for (var r in recent) {
      try {
        final d = (r['dakika'] as num?)?.toDouble() ?? 0.0;
        final c = (r['yakilanKalori'] as num?)?.toInt() ?? (d * 7).toInt();
        recentMinutes.add(d);
        totalBurnedCalories += c;
        final tStr = r['tarih']?.toString() ?? '';
        if (tStr.length >= 10) {
          raidLabels.add('${tStr.substring(8, 10)}/${tStr.substring(5, 7)}');
        } else {
          raidLabels.add('Raid');
        }
      } catch (_) {}
    }

    if (recentMinutes.isEmpty) {
      recentMinutes = [0];
      raidLabels = [TranslationManager.isTurkish ? 'Yok' : 'None'];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_total_workout_time'),
                  value: '$totalWorkoutMins ${TranslationManager.get('cal_min')}',
                  accentColor: sysGold,
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_cleared_raids'),
                  value: '$totalRaids',
                  accentColor: sysCyan,
                  icon: Icons.shield_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricCard(
            title: TranslationManager.get('analytics_total_burned'),
            value: '~$totalBurnedCalories KCAL',
            accentColor: sysRed,
            icon: Icons.local_fire_department,
          ),
          const SizedBox(height: 16),

          HologramCard(
            neonRenk: sysGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationManager.isTurkish ? 'ZİNDAN HACMİ & SÜRE DAĞILIMI' : 'DUNGEON VOLUME & DURATION',
                      style: GoogleFonts.orbitron(color: sysGold, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      '${recent.length} ${TranslationManager.isTurkish ? 'Seans' : 'Sessions'}',
                      style: const TextStyle(color: sysTextMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _WorkoutBarChartPainter(
                      values: recentMinutes,
                      labels: raidLabels,
                      barColor: sysGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    TranslationManager.isTurkish
                        ? 'Her sütun tamamlanan bir zindan akınını (dakika cinsinden) temsil eder.'
                        : 'Each bar represents a cleared dungeon raid (in minutes).',
                    style: const TextStyle(color: sysTextMuted, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (raids.isEmpty)
            _emptyNotice(TranslationManager.get('analytics_no_workout_data')),
        ],
      ),
    );
  }

  // ==========================================
  // 3. BESLENME & DİYET TRENDİ TABI
  // ==========================================
  Widget _buildDietTab() {
    final meals = SystemMemory.yemekGecmisi;
    final targetCal = SystemMemory.gunlukHedefKalori;

    double totalCaloriesSum = 0;
    int daysLogged = meals.length;
    List<double> caloriesList = [];
    List<String> mealDates = [];

    // Son 7 gün
    final recentMeals = meals.length > 7 ? meals.sublist(meals.length - 7) : meals;
    for (var m in recentMeals) {
      try {
        final cal = (m['toplamKalori'] as num?)?.toDouble() ?? 0.0;
        caloriesList.add(cal);
        totalCaloriesSum += cal;
        final t = m['tarih']?.toString() ?? '';
        if (t.length >= 10) {
          mealDates.add('${t.substring(8, 10)}/${t.substring(5, 7)}');
        } else {
          mealDates.add('Gün');
        }
      } catch (_) {}
    }

    if (caloriesList.isEmpty) {
      caloriesList = [0];
      mealDates = [TranslationManager.isTurkish ? 'Bugün' : 'Today'];
    }

    final avgCal = daysLogged > 0 ? (totalCaloriesSum / recentMeals.length).round() : targetCal;
    final adherenceRate = targetCal > 0 ? ((1.0 - ((avgCal - targetCal).abs() / targetCal)) * 100).clamp(0, 100).round() : 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_avg_calories'),
                  value: '$avgCal kcal',
                  accentColor: sysGreen,
                  icon: Icons.restaurant_menu,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_target_adherence'),
                  value: '%$adherenceRate',
                  accentColor: adherenceRate >= 80 ? sysGreen : sysRed,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricCard(
            title: TranslationManager.isTurkish ? 'HEDEF GÜNLÜK KALORİ' : 'TARGET DAILY CALORIES',
            value: '$targetCal kcal',
            accentColor: sysCyan,
            icon: Icons.track_changes,
          ),
          const SizedBox(height: 16),

          HologramCard(
            neonRenk: sysGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationManager.isTurkish ? 'KALORİ ALIMI & HEDEF ÇİZGİSİ' : 'CALORIC INTAKE & TARGET LINE',
                      style: GoogleFonts.orbitron(color: sysGreen, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'Hedef: $targetCal kcal',
                      style: const TextStyle(color: sysTextMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _CalorieBarChartPainter(
                      values: caloriesList,
                      labels: mealDates,
                      target: targetCal.toDouble(),
                      barColor: sysGreen,
                      targetColor: sysCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    TranslationManager.isTurkish
                        ? 'Yeşil barlar tüketilen kaloriyi, mavi çizgi günlük hedefi temsil eder.'
                        : 'Green bars represent consumed calories, cyan line is your target.',
                    style: const TextStyle(color: sysTextMuted, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (meals.isEmpty)
            _emptyNotice(TranslationManager.get('analytics_no_diet_data')),
        ],
      ),
    );
  }

  // ==========================================
  // 4. 1RM KUVVET & GÜÇ SKORU TABI
  // ==========================================
  Widget _buildStrengthTab() {
    final bench = SystemMemory.maxBench;
    final squat = SystemMemory.maxSquat;
    final deadlift = SystemMemory.maxDeadlift;
    final totalLift = bench + squat + deadlift;
    final weight = SystemMemory.kilo > 0 ? SystemMemory.kilo : 75.0;
    final ratio = totalLift > 0 ? (totalLift / weight) : 0.0;

    String tier = 'D-Rank';
    Color tierColor = sysCyan;
    if (ratio >= 4.5) {
      tier = 'S-Rank Apex Hunter';
      tierColor = sysGold;
    } else if (ratio >= 3.5) {
      tier = 'A-Rank Elite Hunter';
      tierColor = sysPurple;
    } else if (ratio >= 2.5) {
      tier = 'B-Rank Veteran';
      tierColor = sysGreen;
    } else if (ratio >= 1.5) {
      tier = 'C-Rank Striker';
      tierColor = sysCyan;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_total_strength'),
                  value: '${totalLift.toStringAsFixed(1)} kg',
                  accentColor: sysGold,
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  title: TranslationManager.get('analytics_bodyweight_ratio'),
                  value: '${ratio.toStringAsFixed(2)}x BW',
                  accentColor: tierColor,
                  icon: Icons.bolt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Güç Kademesi Kartı
          HologramCard(
            neonRenk: tierColor,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tierColor),
                  ),
                  child: Icon(Icons.shield, color: tierColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationManager.get('analytics_power_tier'),
                        style: const TextStyle(color: sysTextMuted, fontSize: 10, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier,
                        style: GoogleFonts.orbitron(
                          color: tierColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3 Büyük Kaldırış Detay Barı
          HologramCard(
            neonRenk: sysCyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationManager.isTurkish ? 'BÜYÜK ÜÇLÜ 1RM KALDIRIŞLARI' : 'THE BIG THREE 1RM LIFTS',
                  style: GoogleFonts.orbitron(color: sysCyan, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 16),
                _liftProgressBar(name: 'BENCH PRESS', weight: bench, maxScale: 200, color: sysCyan),
                const SizedBox(height: 14),
                _liftProgressBar(name: 'SQUAT', weight: squat, maxScale: 250, color: sysGold),
                const SizedBox(height: 14),
                _liftProgressBar(name: 'DEADLIFT', weight: deadlift, maxScale: 300, color: sysRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liftProgressBar({
    required String name,
    required double weight,
    required double maxScale,
    required Color color,
  }) {
    final progress = (weight / maxScale).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            Text('${weight.toStringAsFixed(1)} kg', style: GoogleFonts.orbitron(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress > 0 ? progress : 0.02,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.5), color]),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // ORTAK WIDGET'LAR
  // ==========================================
  Widget _metricCard({
    required String title,
    required String value,
    required Color accentColor,
    required IconData icon,
  }) {
    return HologramCard(
      neonRenk: accentColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyNotice(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: sysCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: sysTextMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🎨 CUSTOM PAINTER: KİLO ÇİZGİ GRAFİĞİ
// ==========================================
class _WeightLineChartPainter extends CustomPainter {
  final List<double> points;
  final List<String> dateLabels;
  final double targetWeight;
  final Color lineColor;
  final Color targetColor;

  _WeightLineChartPainter({
    required this.points,
    required this.dateLabels,
    required this.targetWeight,
    required this.lineColor,
    required this.targetColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double bottomPadding = 24.0;
    final double topPadding = 16.0;
    final double chartHeight = size.height - bottomPadding - topPadding;

    double minVal = points.reduce(math.min);
    double maxVal = points.reduce(math.max);
    if (targetWeight > 0) {
      minVal = math.min(minVal, targetWeight);
      maxVal = math.max(maxVal, targetWeight);
    }
    // Eksen payı
    minVal = (minVal - 2).floorToDouble();
    maxVal = (maxVal + 2).ceilToDouble();
    final double range = (maxVal - minVal) > 0 ? (maxVal - minVal) : 1.0;

    // Kılavuz çizgileri
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Hedef Kilo Çizgisi
    if (targetWeight > 0) {
      final targetY = topPadding + chartHeight * (1.0 - ((targetWeight - minVal) / range));
      final targetPaint = Paint()
        ..color = targetColor.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Kesikli çizgi
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, targetY), Offset(startX + 6, targetY), targetPaint);
        startX += 10;
      }
    }

    // Noktaları hesapla
    final List<Offset> offsets = [];
    final double stepX = points.length > 1 ? size.width / (points.length - 1) : size.width / 2;

    for (int i = 0; i < points.length; i++) {
      final x = points.length > 1 ? i * stepX : size.width / 2;
      final y = topPadding + chartHeight * (1.0 - ((points[i] - minVal) / range));
      offsets.add(Offset(x, y));
    }

    // Gradient Dolgu Alanı
    if (offsets.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(offsets.first.dx, size.height - bottomPadding);
      for (var pt in offsets) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(offsets.last.dx, size.height - bottomPadding);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.35),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Çizgi
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Noktalar ve etiketler
    final dotPaint = Paint()..color = lineColor;
    final dotInnerPaint = Paint()..color = Colors.white;

    for (int i = 0; i < offsets.length; i++) {
      canvas.drawCircle(offsets[i], 4.5, dotPaint);
      canvas.drawCircle(offsets[i], 2.0, dotInnerPaint);

      // Tarih etiketleri (belli aralıklarla)
      if (i == 0 || i == offsets.length - 1 || i % 2 == 0) {
        final textSpan = TextSpan(
          text: dateLabels[i],
          style: const TextStyle(color: Colors.white54, fontSize: 9),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tp.layout();
        final textX = (offsets[i].dx - tp.width / 2).clamp(0.0, size.width - tp.width);
        tp.paint(canvas, Offset(textX, size.height - bottomPadding + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLineChartPainter oldDelegate) => true;
}

// ==========================================
// 🎨 CUSTOM PAINTER: İDMAN SÜRESİ ÇUBUK GRAFİĞİ
// ==========================================
class _WorkoutBarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color barColor;

  _WorkoutBarChartPainter({
    required this.values,
    required this.labels,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double bottomPadding = 24.0;
    final double topPadding = 16.0;
    final double chartHeight = size.height - bottomPadding - topPadding;

    double maxVal = values.reduce(math.max);
    if (maxVal <= 0) maxVal = 60.0;
    maxVal = (maxVal * 1.2).ceilToDouble();

    final int count = values.length;
    final double slotWidth = size.width / count;
    final double barWidth = (slotWidth * 0.55).clamp(8.0, 36.0);

    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double barHeight = (val / maxVal) * chartHeight;
      final double x = (i * slotWidth) + (slotWidth - barWidth) / 2;
      final double y = topPadding + chartHeight - barHeight;

      // Arka plan kılavuz barı
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, topPadding, barWidth, chartHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(bgRect, Paint()..color = Colors.white.withValues(alpha: 0.05));

      // Aktif bar
      if (barHeight > 0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(3),
        );
        final barPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [barColor.withValues(alpha: 0.4), barColor],
          ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

        canvas.drawRRect(barRect, barPaint);
      }

      // Değer Etiketi (Bar tepesi)
      if (val > 0) {
        final valSpan = TextSpan(
          text: '${val.toInt()}',
          style: GoogleFonts.orbitron(color: barColor, fontSize: 9, fontWeight: FontWeight.bold),
        );
        final valTp = TextPainter(text: valSpan, textDirection: TextDirection.ltr);
        valTp.layout();
        valTp.paint(canvas, Offset(x + (barWidth - valTp.width) / 2, y - 14));
      }

      // Alt Etiket
      final labelSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white54, fontSize: 9),
      );
      final labelTp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr);
      labelTp.layout();
      labelTp.paint(canvas, Offset(x + (barWidth - labelTp.width) / 2, size.height - bottomPadding + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutBarChartPainter oldDelegate) => true;
}

// ==========================================
// 🎨 CUSTOM PAINTER: KALORİ & HEDEF ÇUBUK GRAFİĞİ
// ==========================================
class _CalorieBarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double target;
  final Color barColor;
  final Color targetColor;

  _CalorieBarChartPainter({
    required this.values,
    required this.labels,
    required this.target,
    required this.barColor,
    required this.targetColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double bottomPadding = 24.0;
    final double topPadding = 16.0;
    final double chartHeight = size.height - bottomPadding - topPadding;

    double maxVal = values.reduce(math.max);
    if (target > maxVal) maxVal = target;
    maxVal = (maxVal * 1.25).ceilToDouble();
    if (maxVal <= 0) maxVal = 2500;

    final int count = values.length;
    final double slotWidth = size.width / count;
    final double barWidth = (slotWidth * 0.55).clamp(8.0, 36.0);

    // Hedef Çizgisi
    if (target > 0) {
      final targetY = topPadding + chartHeight * (1.0 - (target / maxVal));
      final targetPaint = Paint()
        ..color = targetColor
        ..strokeWidth = 1.5;

      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, targetY), Offset(startX + 6, targetY), targetPaint);
        startX += 10;
      }
    }

    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double barHeight = (val / maxVal) * chartHeight;
      final double x = (i * slotWidth) + (slotWidth - barWidth) / 2;
      final double y = topPadding + chartHeight - barHeight;

      if (barHeight > 0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(3),
        );
        final barPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [barColor.withValues(alpha: 0.35), barColor],
          ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

        canvas.drawRRect(barRect, barPaint);
      }

      // Alt Etiket
      final labelSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white54, fontSize: 9),
      );
      final labelTp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr);
      labelTp.layout();
      labelTp.paint(canvas, Offset(x + (barWidth - labelTp.width) / 2, size.height - bottomPadding + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _CalorieBarChartPainter oldDelegate) => true;
}
