import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/services/gemini_service.dart';
import '../controllers/system_memory.dart';
import '../models/mental_task_model.dart';
import '../core/audio_system.dart';

class StudyPlannerModal extends StatefulWidget {
  const StudyPlannerModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const StudyPlannerModal(),
    );
  }

  @override
  State<StudyPlannerModal> createState() => _StudyPlannerModalState();
}

class _StudyPlannerModalState extends State<StudyPlannerModal> {
  final _goalController = TextEditingController();
  String _selectedAlan = 'Yazılım & Kodlama';
  int _selectedDuration = 45;
  bool _isLoading = false;
  List<MentalTask>? _generatedTasks;
  String? _errorMessage;

  final List<String> _alanlar = [
    'Yazılım & Kodlama',
    'Yabancı Dil (İngilizce/Japonca)',
    'Akademik & Sınav Hazırlığı',
    'Kitap Okuma & Analiz',
    'Finans & Strateji',
    'Kişisel Gelişim & Felsefe',
  ];

  final List<int> _sureler = [25, 45, 60, 90];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _generatedTasks = null;
    });

    try {
      final tasks = await GeminiService.aiCalismaPlaniUret(
        alan: _selectedAlan,
        seviye: SystemMemory.hunterRank,
        hedef: _goalController.text.trim().isEmpty
            ? 'Genel Gelişim ve Ustalık'
            : _goalController.text.trim(),
        gunlukDakika: _selectedDuration,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _generatedTasks = tasks;
        });
        AudioSystem.playQuestComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Protokol oluşturulurken hata oluştu: $e';
        });
      }
    }
  }

  void _acceptPlan() {
    if (_generatedTasks == null || _generatedTasks!.isEmpty) return;

    for (final task in _generatedTasks!) {
      SystemMemory.zihinselGorevEkle(task);
    }

    AudioSystem.playLevelUp();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.systemCyan.withValues(alpha: 0.9),
        content: Row(
          children: [
            const Icon(Icons.psychology, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_generatedTasks!.length} Yeni Zihinsel Görev Sisteme Enjekte Edildi!',
                style: GoogleFonts.rajdhani(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 20 + bottomInset,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(
          color: AppColors.systemCyan.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.systemCyan.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Handle & Title
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.systemCyan.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.systemCyan.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.systemCyan.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.systemCyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SİSTEM // ZİHİNSEL GELİŞİM PROTOKOLÜ',
                        style: GoogleFonts.orbitron(
                          color: AppColors.systemCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Yapay Zeka Destekli Bilişsel ve Mesleki Görev Motoru',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),

            // Alan Seçimi
            Text(
              'GELİŞİM ALANI SEÇİN',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAlan,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0F172A),
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _alanlar.map((alan) {
                    return DropdownMenuItem<String>(
                      value: alan,
                      child: Text(alan),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAlan = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Günlük Süre
            Text(
              'GÜNLÜK HEDEF ODAKLANMA SÜRESİ',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _sureler.map((sure) {
                final isSelected = _selectedDuration == sure;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDuration = sure),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.systemCyan.withValues(alpha: 0.2)
                              : Colors.black38,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.systemCyan
                                : Colors.white24,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '$sure dk',
                            style: GoogleFonts.orbitron(
                              color: isSelected
                                  ? AppColors.systemCyan
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Spesifik Hedef
            Text(
              'ÖZEL HEDEF / KONU DETAYI (İSTEĞE BAĞLI)',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _goalController,
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Örn: Flutter State Management, Clean Code Kitabı...',
                hintStyle: GoogleFonts.rajdhani(color: Colors.white38),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.systemCyan),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Plan Oluştur Butonu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.systemCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 6,
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'SİSTEM PROTOKOLÜ DERLİYOR...',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'GÖREV PROTOKOLÜNÜ ÜRET',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.rajdhani(color: Colors.redAccent, fontSize: 13),
              ),
            ],

            // Üretilen Görevlerin Önizlemesi
            if (_generatedTasks != null && _generatedTasks!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  border: Border.all(
                    color: AppColors.systemCyan.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist_rtl,
                          color: AppColors.systemCyan,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SİSTEM TARAFINDAN ÖNERİLEN GÖREVLER',
                          style: GoogleFonts.orbitron(
                            color: AppColors.systemCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._generatedTasks!.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '▶ ',
                              style: TextStyle(
                                color: AppColors.systemCyan,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${task.targetMinutes} dk | +${task.rewardExp} EXP | +${task.rewardInt} INT | +${task.rewardPer} PER',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _acceptPlan,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          'GÖREVLERİ GÜNLÜK LİSTEYE EKLE',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
