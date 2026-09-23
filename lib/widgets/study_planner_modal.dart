import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/services/gemini_service.dart';
import '../controllers/system_memory.dart';
import '../models/mental_task_model.dart';
import '../core/audio_system.dart';
import '../core/translation_manager.dart';

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
  String? _selectedAlan;
  int _selectedDuration = 45;
  bool _isLoading = false;
  List<MentalTask>? _generatedTasks;
  String? _errorMessage;

  List<String> get _alanlar => TranslationManager.isTurkish
      ? [
          'Yazılım & Kodlama',
          'Yabancı Dil (İngilizce/Japonca)',
          'Akademik & Sınav Hazırlığı',
          'Kitap Okuma & Analiz',
          'Finans & Strateji',
          'Kişisel Gelişim & Felsefe',
        ]
      : [
          'Software & Coding',
          'Foreign Languages (English/Japanese)',
          'Academic & Exam Prep',
          'Reading & Analytical Study',
          'Finance & Strategy',
          'Self-Mastery & Philosophy',
        ];

  String get _currentAlan => (_selectedAlan != null && _alanlar.contains(_selectedAlan))
      ? _selectedAlan!
      : _alanlar.first;

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
        alan: _currentAlan,
        seviye: SystemMemory.hunterRank,
        hedef: _goalController.text.trim().isEmpty
            ? (TranslationManager.isTurkish ? 'Genel Gelişim ve Ustalık' : 'General Mastery & Skill Progression')
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
                TranslationManager.isTurkish
                    ? '${_generatedTasks!.length} Yeni Zihinsel Görev Sisteme Enjekte Edildi!'
                    : '${_generatedTasks!.length} New Mental Quests Injected into System!',
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
                        TranslationManager.isTurkish ? 'SİSTEM // ZİHİNSEL GELİŞİM PROTOKOLÜ' : 'SYSTEM // MENTAL GROWTH PROTOCOL',
                        style: GoogleFonts.orbitron(
                          color: AppColors.systemCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        TranslationManager.isTurkish
                            ? 'Yapay Zeka Destekli Bilişsel ve Mesleki Görev Motoru'
                            : 'AI-Powered Cognitive & Vocational Quest Engine',
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
              TranslationManager.isTurkish ? 'GELİŞİM ALANI SEÇİN' : 'SELECT GROWTH DOMAIN',
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
                  value: _currentAlan,
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
              TranslationManager.isTurkish ? 'GÜNLÜK HEDEF ODAKLANMA SÜRESİ' : 'DAILY TARGET FOCUS TIME',
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
                            '$sure ${TranslationManager.isTurkish ? "dk" : "min"}',
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
              TranslationManager.isTurkish ? 'ÖZEL HEDEF / KONU DETAYI (İSTEĞE BAĞLI)' : 'SPECIFIC OBJECTIVE / TOPIC (OPTIONAL)',
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
                hintText: TranslationManager.isTurkish ? 'Örn: Flutter State Management, Clean Code Kitabı...' : 'e.g., Flutter State Management, Clean Code Book...',
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
                            TranslationManager.isTurkish ? 'SİSTEM PROTOKOLÜ DERLİYOR...' : 'SYSTEM COMPILING PROTOCOL...',
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
                            TranslationManager.isTurkish ? 'GÖREV PROTOKOLÜNÜ ÜRET' : 'GENERATE QUEST PROTOCOL',
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
                          TranslationManager.isTurkish ? 'SİSTEM TARAFINDAN ÖNERİLEN GÖREVLER' : 'RECOMMENDED SYSTEM QUESTS',
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
                                    '${task.targetMinutes} ${TranslationManager.isTurkish ? "dk" : "min"} | +${task.rewardExp} EXP | +${task.rewardInt} INT | +${task.rewardPer} PER',
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
                          TranslationManager.isTurkish ? 'GÖREVLERİ GÜNLÜK LİSTEYE EKLE' : 'INJECT QUESTS INTO DAILY PROTOCOL',
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
