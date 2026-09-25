import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/translation_manager.dart';
import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';
import '../core/system_session_manager.dart';

class DeepWorkTimerScreen extends StatefulWidget {
  final String? initialTopic;
  final int? initialMinutes;

  const DeepWorkTimerScreen({
    super.key,
    this.initialTopic,
    this.initialMinutes,
  });

  @override
  State<DeepWorkTimerScreen> createState() => _DeepWorkTimerScreenState();
}

class _DeepWorkTimerScreenState extends State<DeepWorkTimerScreen> {
  late int _focusDurationMinutes;
  int _restDurationMinutes = 5;

  late String _topic;
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final session = SystemSessionManager.instance.deepWork;
    if (session.isRunning) {
      _focusDurationMinutes = session.focusMinutes;
      _restDurationMinutes = session.restMinutes;
      _topic = session.topic;
    } else {
      _focusDurationMinutes = widget.initialMinutes ?? 25;
      _topic = widget.initialTopic ?? (TranslationManager.isTurkish ? 'Kodlama / Araştırma' : 'Coding / Research');
    }
    _topicController.text = _topic;

    SystemSessionManager.instance.addListener(_onSessionStateChanged);
  }

  void _onSessionStateChanged() {
    if (!mounted) return;
    final session = SystemSessionManager.instance.deepWork;
    if (session.pendingCompletionReward != null) {
      final reward = Map<String, dynamic>.from(session.pendingCompletionReward!);
      session.pendingCompletionReward = null;
      _showCompletionDialog(reward);
    }
    setState(() {});
  }

  @override
  void dispose() {
    SystemSessionManager.instance.removeListener(_onSessionStateChanged);
    _topicController.dispose();
    super.dispose();
  }

  void _startTimer() {
    final manager = SystemSessionManager.instance;
    if (manager.deepWork.isRunning && manager.deepWork.isPaused) {
      manager.resumeDeepWork();
    } else {
      final topicText = _topicController.text.trim().isEmpty ? _topic : _topicController.text.trim();
      manager.startDeepWork(
        topic: topicText,
        focusMinutes: _focusDurationMinutes,
        restMinutes: _restDurationMinutes,
      );
    }
  }

  void _pauseTimer() {
    SystemSessionManager.instance.pauseDeepWork();
  }

  void _manualFinishEarly() {
    SystemSessionManager.instance.manualFinishDeepWorkEarly(context);
  }

  void _minimizeToBackground() {
    final session = SystemSessionManager.instance.deepWork;
    if (session.isRunning && mounted) {
      final isTr = TranslationManager.isTurkish;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF070B14),
          content: Row(
            children: [
              Icon(Icons.hourglass_top, color: AppColors.systemCyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTr
                      ? 'Bilişsel zindan arka planda çalışıyor. Yüzen HUD çubuğundan takip edebilirsin.'
                      : 'Cognitive dungeon running in background. You can track it via the floating HUD.',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _showCompletionDialog(Map<String, dynamic> reward) {
    final expReward = reward['exp'] ?? (_focusDurationMinutes * 2);
    final intReward = reward['int'] ?? ((_focusDurationMinutes / 15).ceil());
    final perReward = reward['per'] ?? ((_focusDurationMinutes / 20).ceil());
    final minutes = reward['minutes'] ?? _focusDurationMinutes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF030712),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: AppColors.systemCyan, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.stars, color: AppColors.systemCyan),
            const SizedBox(width: 8),
            Text(
              TranslationManager.isTurkish ? 'ODAKLANMA PROTOKOLÜ TAMAMLANDI' : 'FOCUS PROTOCOL COMPLETE',
              style: GoogleFonts.orbitron(
                color: AppColors.systemCyan,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationManager.isTurkish
                  ? 'Avcı zihinsel konsantrasyonunu korudu ve zihinsel zindanı temizledi.'
                  : 'Hunter maintained mental concentration and cleared the cognitive dungeon.',
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: AppColors.systemCyan.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  _statRow(TranslationManager.isTurkish ? 'KAZANILAN TECRÜBE' : 'EXP GAINED', '+$expReward EXP', Colors.yellowAccent),
                  const SizedBox(height: 6),
                  _statRow(TranslationManager.isTurkish ? 'ZEKA (INT) ARTIŞI' : 'INTELLIGENCE (INT) UP', '+$intReward INT', AppColors.systemCyan),
                  const SizedBox(height: 6),
                  _statRow(TranslationManager.isTurkish ? 'SEZGİ (PER) ARTIŞI' : 'PERCEPTION (PER) UP', '+$perReward PER', Colors.purpleAccent),
                  const SizedBox(height: 6),
                  _statRow(TranslationManager.isTurkish ? 'TOPLAM ODAK' : 'TOTAL FOCUS', '$minutes ${TranslationManager.isTurkish ? "DK" : "MIN"}', Colors.white),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.systemCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              TranslationManager.isTurkish ? 'DEVAM ET' : 'CONTINUE',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(color: Colors.white60, fontSize: 11),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: valColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(int totalSec) {
    final minutes = (totalSec ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSec % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final session = SystemSessionManager.instance.deepWork;
    final isRunning = session.isRunning && !session.isPaused;
    final isPaused = session.isPaused;
    final remainingSeconds = session.remainingSeconds;
    final progress = session.progress;
    final isFocus = session.phase == DeepWorkPhase.focus;
    final themeColor = isFocus ? AppColors.systemCyan : Colors.purpleAccent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _minimizeToBackground();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF030712),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.systemCyan, size: 20),
            onPressed: _minimizeToBackground,
          ),
          title: Text(
            TranslationManager.isTurkish ? 'BİLİŞSEL ZİNDAN // DEEP WORK' : 'COGNITIVE DUNGEON // DEEP WORK',
            style: GoogleFonts.orbitron(
              color: AppColors.systemCyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
          actions: [
            if (session.isRunning)
              IconButton(
                icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white70),
                tooltip: TranslationManager.isTurkish ? 'Arka Plana Al' : 'Minimize to HUD',
                onPressed: _minimizeToBackground,
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Konu ve Protokol Seçimi (Timer dururken değiştirilebilir)
                HologramCard(
                  neonRenk: themeColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${TranslationManager.isTurkish ? "AKTİF PROTOKOL" : "ACTIVE PROTOCOL"}: ${isFocus ? (TranslationManager.isTurkish ? "ODAKLANMA" : "FOCUS") : (TranslationManager.isTurkish ? "DİNLENME" : "REST")}',
                            style: GoogleFonts.orbitron(
                              color: themeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: themeColor, width: 1),
                            ),
                            child: Text(
                              '${TranslationManager.isTurkish ? "SEANS" : "SESSION"}: #${session.completedSessions}',
                              style: GoogleFonts.orbitron(
                                color: themeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _topicController,
                        enabled: !session.isRunning,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: TranslationManager.isTurkish ? 'ÇALIŞILAN KONU VEYA KİTAP' : 'STUDY TOPIC / BOOK',
                          labelStyle: GoogleFonts.orbitron(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: themeColor),
                          ),
                        ),
                      ),
                      if (!session.isRunning) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _durationChip(TranslationManager.isTurkish ? '25 dk (Pomodoro)' : '25 min (Pomodoro)', 25, 5),
                            const SizedBox(width: 8),
                            _durationChip(TranslationManager.isTurkish ? '50 dk (Derin)' : '50 min (Deep)', 50, 10),
                            const SizedBox(width: 8),
                            _durationChip(TranslationManager.isTurkish ? '90 dk (Ultra)' : '90 min (Ultra)', 90, 15),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // EKRANI AÇIK TUT (WAKELOCK) KONTROLÜ
                InkWell(
                  onTap: () {
                    SystemSessionManager.instance.setKeepScreenOn(!session.keepScreenOn);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      border: Border.all(
                        color: session.keepScreenOn ? AppColors.systemCyan.withValues(alpha: 0.6) : Colors.white12,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          session.keepScreenOn ? Icons.lightbulb : Icons.lightbulb_outline,
                          color: session.keepScreenOn ? AppColors.systemCyan : Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          TranslationManager.isTurkish ? 'EKRANI AÇIK TUT: ' : 'KEEP SCREEN ON: ',
                          style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white70),
                        ),
                        Text(
                          session.keepScreenOn
                              ? (TranslationManager.isTurkish ? 'AÇIK' : 'ON')
                              : (TranslationManager.isTurkish ? 'KAPALI' : 'OFF'),
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: session.keepScreenOn ? AppColors.systemCyan : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Dairesel Zaman Sayacı
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(remainingSeconds),
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: themeColor.withValues(alpha: 0.8),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isFocus
                                ? (TranslationManager.isTurkish ? 'BİLİŞSEL ODAK' : 'COGNITIVE FOCUS')
                                : (TranslationManager.isTurkish ? 'YENİLENME MODU' : 'RECOVERY MODE'),
                            style: GoogleFonts.orbitron(
                              color: themeColor,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Kontrol Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isRunning)
                      ElevatedButton.icon(
                        onPressed: _startTimer,
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: Text(
                          isPaused
                              ? (TranslationManager.isTurkish ? 'DEVAM ET' : 'RESUME')
                              : (TranslationManager.isTurkish ? 'BAŞLAT' : 'START'),
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          elevation: 8,
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _pauseTimer,
                        icon: const Icon(Icons.pause, size: 24),
                        label: Text(
                          TranslationManager.isTurkish ? 'DURAKLAT' : 'PAUSE',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _manualFinishEarly,
                      icon: const Icon(Icons.stop, size: 20),
                      label: Text(
                        TranslationManager.isTurkish ? 'BİTİR' : 'FINISH',
                        style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ARKA PLANA AL BUTONU
                if (session.isRunning)
                  TextButton.icon(
                    onPressed: _minimizeToBackground,
                    icon: Icon(Icons.arrow_downward, color: themeColor, size: 16),
                    label: Text(
                      TranslationManager.isTurkish ? 'SİSTEMİ ARKA PLANA AL' : 'MINIMIZE TO SYSTEM HUD',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // İstatistik Kartı
                HologramCard(
                  neonRenk: Colors.white24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(
                        TranslationManager.isTurkish ? 'TOPLAM ODAK' : 'TOTAL FOCUS',
                        '${session.totalFocusedMinutes} ${TranslationManager.isTurkish ? "DK" : "MIN"}',
                        Icons.timer_outlined,
                        AppColors.systemCyan,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _statItem(
                        TranslationManager.isTurkish ? 'BİTİRİLEN SEANS' : 'COMPLETED SESSIONS',
                        '${session.completedSessions}',
                        Icons.check_circle_outline,
                        Colors.greenAccent,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _statItem(
                        TranslationManager.isTurkish ? 'GENEL SİSTEM' : 'SYSTEM TOTAL',
                        '${SystemMemory.toplamOdaklanmaDakikasi} ${TranslationManager.isTurkish ? "DK" : "MIN"}',
                        Icons.military_tech_outlined,
                        Colors.purpleAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _durationChip(String label, int focusMin, int restMin) {
    final isSelected = _focusDurationMinutes == focusMin;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _focusDurationMinutes = focusMin;
            _restDurationMinutes = restMin;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.systemCyan.withValues(alpha: 0.2) : Colors.black45,
            border: Border.all(
              color: isSelected ? AppColors.systemCyan : Colors.white24,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.rajdhani(
                    color: isSelected ? AppColors.systemCyan : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
