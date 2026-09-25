// lib/core/system_session_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../controllers/system_memory.dart';
import 'audio_system.dart';
import 'services/notification_service.dart';
import 'translation_manager.dart';
import 'voice_coach_system.dart';

enum DeepWorkPhase { focus, rest }

/// Bilişsel Zindan (Deep Work) aktif oturum durumu
class DeepWorkSessionState {
  bool isRunning = false;
  bool isPaused = false;
  String topic = '';
  DeepWorkPhase phase = DeepWorkPhase.focus;
  int focusMinutes = 25;
  int restMinutes = 5;
  int initialSecondsForPhase = 25 * 60;
  DateTime? targetEndTime;
  int pausedRemainingSeconds = 25 * 60;
  int completedSessions = 0;
  int totalFocusedMinutes = 0;
  bool keepScreenOn = true;

  // Son tamamlanan seans ödül bilgisi (UI diyalogları için)
  Map<String, dynamic>? pendingCompletionReward;

  int get remainingSeconds {
    if (!isRunning) return initialSecondsForPhase;
    if (isPaused) return pausedRemainingSeconds;
    if (targetEndTime == null) return 0;
    final diff = targetEndTime!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  double get progress {
    if (initialSecondsForPhase <= 0) return 0.0;
    final rem = remainingSeconds;
    return (1.0 - (rem / initialSecondsForPhase)).clamp(0.0, 1.0);
  }
}

/// Dinlenme Sayacı (Rest Timer) aktif oturum durumu
class RestTimerSessionState {
  bool isRunning = false;
  bool isPaused = false;
  String? exerciseName;
  int totalSeconds = 60;
  DateTime? targetEndTime;
  int pausedRemainingSeconds = 60;
  bool isMinimized = false;
  VoidCallback? onComplete;

  int get remainingSeconds {
    if (!isRunning) return 0;
    if (isPaused) return pausedRemainingSeconds;
    if (targetEndTime == null) return 0;
    final diff = targetEndTime!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  double get progress {
    if (totalSeconds <= 0) return 0.0;
    final rem = remainingSeconds;
    return (1.0 - (rem / totalSeconds)).clamp(0.0, 1.0);
  }
}

/// Tüm uygulama boyunca sürelerin kilit ekranında veya başka ekranlarda
/// takılmadan, gerçek duvar saati (DateTime.now) ile akmasını sağlayan
/// ve kullanıcı arayüzü mini HUD'ını besleyen merkezi seans yöneticisi.
class SystemSessionManager with ChangeNotifier, WidgetsBindingObserver {
  static final SystemSessionManager instance = SystemSessionManager._internal();

  SystemSessionManager._internal() {
    WidgetsBinding.instance.addObserver(this);
    _startGlobalTicker();
  }

  final DeepWorkSessionState deepWork = DeepWorkSessionState();
  final RestTimerSessionState restTimer = RestTimerSessionState();

  Timer? _ticker;

  // Global periyodik saat (Saniyede bir kez tüm arayüzü günceller)
  void _startGlobalTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  void _onTick() {
    bool stateChanged = false;

    // 1. Deep Work Kontrolü
    if (deepWork.isRunning && !deepWork.isPaused && deepWork.targetEndTime != null) {
      final now = DateTime.now();
      if (now.isAfter(deepWork.targetEndTime!)) {
        _finishDeepWorkPhase();
        stateChanged = true;
      } else {
        stateChanged = true;
      }
    }

    // 2. Rest Timer Kontrolü
    if (restTimer.isRunning && !restTimer.isPaused && restTimer.targetEndTime != null) {
      final now = DateTime.now();
      final rem = restTimer.remainingSeconds;
      if (rem <= 3 && rem > 0) {
        VoiceCoachSystem.dinlenmeGeriSayim(rem);
      }
      if (now.isAfter(restTimer.targetEndTime!)) {
        _finishRestTimer();
        stateChanged = true;
      } else {
        stateChanged = true;
      }
    }

    if (stateChanged) {
      notifyListeners();
    }
  }

  // =========================================================================
  // APP LIFECYCLE (TELEFON KİLİTLENDİĞİNDE VEYA GERİ AÇILDIĞINDA)
  // =========================================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Telefon kilitlendi veya arka plana alındı.
      // Zamanlanmış yüksek öncelikli bildirimleri kur!
      _scheduleBackgroundAlerts();
    } else if (state == AppLifecycleState.resumed) {
      // Telefon kilidi açıldı veya uygulamaya dönüldü!
      // Duvar saatini (DateTime.now) baz alarak geçen süreyi derhal telafi et.
      _reconcileTimeOnResume();
    }
  }

  void _scheduleBackgroundAlerts() {
    // Deep work bildirimi planla
    if (deepWork.isRunning && !deepWork.isPaused && deepWork.targetEndTime != null) {
      final isTr = TranslationManager.isTurkish;
      final title = isTr
          ? (deepWork.phase == DeepWorkPhase.focus ? '⏳ [BİLİŞSEL ZİNDAN TAMAMLANDI]' : '⚡ [DİNLENME MODU TAMAMLANDI]')
          : (deepWork.phase == DeepWorkPhase.focus ? '⏳ [DEEP WORK PROTOCOL COMPLETE]' : '⚡ [RECOVERY PROTOCOL COMPLETE]');
      final body = isTr
          ? '${deepWork.topic} seansı bitti. Tebrikler avcı, ödüllerin seni bekliyor!'
          : '${deepWork.topic} session finished. Excellent work Hunter, claim your rewards!';

      NotificationService.instance.zamanliBildirimPlanla(
        id: NotificationService.idDeepWorkTimer,
        title: title,
        body: body,
        hedefZaman: deepWork.targetEndTime!,
      );
    }

    // Rest timer bildirimi planla
    if (restTimer.isRunning && !restTimer.isPaused && restTimer.targetEndTime != null) {
      final isTr = TranslationManager.isTurkish;
      final title = isTr ? '⏱️ [DİNLENME SÜRESİ BİTTİ]' : '⏱️ [REST PERIOD FINISHED]';
      final body = isTr
          ? '${restTimer.exerciseName ?? "Sıradaki set"} için dinlenme tamamlandı. Demir seni bekliyor!'
          : 'Rest complete for ${restTimer.exerciseName ?? "next set"}. Time to lift!';

      NotificationService.instance.zamanliBildirimPlanla(
        id: NotificationService.idRestTimer,
        title: title,
        body: body,
        hedefZaman: restTimer.targetEndTime!,
      );
    }
  }

  void _reconcileTimeOnResume() {
    final now = DateTime.now();

    // 1. Deep work telafisi
    if (deepWork.isRunning && !deepWork.isPaused && deepWork.targetEndTime != null) {
      if (now.isAfter(deepWork.targetEndTime!)) {
        _finishDeepWorkPhase();
      }
    }

    // 2. Rest timer telafisi
    if (restTimer.isRunning && !restTimer.isPaused && restTimer.targetEndTime != null) {
      if (now.isAfter(restTimer.targetEndTime!)) {
        _finishRestTimer();
      }
    }

    notifyListeners();
  }

  // =========================================================================
  // DEEP WORK METOTLARI
  // =========================================================================
  void startDeepWork({
    String? topic,
    int? focusMinutes,
    int? restMinutes,
  }) {
    if (topic != null) deepWork.topic = topic;
    if (focusMinutes != null) deepWork.focusMinutes = focusMinutes;
    if (restMinutes != null) deepWork.restMinutes = restMinutes;

    deepWork.phase = DeepWorkPhase.focus;
    deepWork.initialSecondsForPhase = deepWork.focusMinutes * 60;
    deepWork.targetEndTime = DateTime.now().add(Duration(seconds: deepWork.initialSecondsForPhase));
    deepWork.isRunning = true;
    deepWork.isPaused = false;
    deepWork.pendingCompletionReward = null;

    _applyWakelock();
    AudioSystem.playDungeonStart();
    notifyListeners();
  }

  void pauseDeepWork() {
    if (!deepWork.isRunning || deepWork.isPaused) return;
    deepWork.pausedRemainingSeconds = deepWork.remainingSeconds;
    deepWork.isPaused = true;
    deepWork.targetEndTime = null;

    NotificationService.instance.bildirimIptal(NotificationService.idDeepWorkTimer);
    _applyWakelock();
    AudioSystem.playButtonClick();
    notifyListeners();
  }

  void resumeDeepWork() {
    if (!deepWork.isRunning || !deepWork.isPaused) return;
    deepWork.targetEndTime = DateTime.now().add(Duration(seconds: deepWork.pausedRemainingSeconds));
    deepWork.isPaused = false;

    _applyWakelock();
    AudioSystem.playButtonClick();
    notifyListeners();
  }

  void resetDeepWork() {
    deepWork.isRunning = false;
    deepWork.isPaused = false;
    deepWork.phase = DeepWorkPhase.focus;
    deepWork.initialSecondsForPhase = deepWork.focusMinutes * 60;
    deepWork.pausedRemainingSeconds = deepWork.initialSecondsForPhase;
    deepWork.targetEndTime = null;

    NotificationService.instance.bildirimIptal(NotificationService.idDeepWorkTimer);
    _applyWakelock();
    notifyListeners();
  }

  void manualFinishDeepWorkEarly(BuildContext? context) {
    if (!deepWork.isRunning) return;

    final passedSec = deepWork.initialSecondsForPhase - deepWork.remainingSeconds;
    final passedMinutes = (passedSec / 60).floor();

    if (passedMinutes >= 5 && deepWork.phase == DeepWorkPhase.focus) {
      deepWork.totalFocusedMinutes += passedMinutes;
      SystemMemory.deepWorkTamamlandi(
        dakika: passedMinutes,
        baslik: deepWork.topic.trim().isEmpty ? 'Deep Work' : deepWork.topic.trim(),
      );
      AudioSystem.playQuestComplete();

      if (context != null && context.mounted) {
        final isTr = TranslationManager.isTurkish;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF38BDF8),
            content: Text(
              isTr
                  ? '$passedMinutes dakikalık odaklanma oturumu kaydedildi! (+${passedMinutes * 2} EXP)'
                  : '$passedMinutes minute focus session logged! (+${passedMinutes * 2} EXP)',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
    resetDeepWork();
  }

  void _finishDeepWorkPhase() {
    NotificationService.instance.bildirimIptal(NotificationService.idDeepWorkTimer);

    if (deepWork.phase == DeepWorkPhase.focus) {
      deepWork.completedSessions++;
      deepWork.totalFocusedMinutes += deepWork.focusMinutes;
      AudioSystem.playQuestComplete();

      // SystemMemory'ye ödülleri işle
      SystemMemory.deepWorkTamamlandi(
        dakika: deepWork.focusMinutes,
        baslik: deepWork.topic.trim().isEmpty ? 'Deep Work' : deepWork.topic.trim(),
      );

      final expReward = deepWork.focusMinutes * 2;
      final intReward = (deepWork.focusMinutes / 15).ceil();
      final perReward = (deepWork.focusMinutes / 20).ceil();

      deepWork.pendingCompletionReward = {
        'exp': expReward,
        'int': intReward,
        'per': perReward,
        'topic': deepWork.topic,
        'minutes': deepWork.focusMinutes,
        'session': deepWork.completedSessions,
      };

      // Dinlenme moduna geç
      deepWork.phase = DeepWorkPhase.rest;
      deepWork.initialSecondsForPhase = deepWork.restMinutes * 60;
      deepWork.targetEndTime = DateTime.now().add(Duration(seconds: deepWork.initialSecondsForPhase));
      deepWork.isRunning = true;
      deepWork.isPaused = false;

      // Anlık tebrik bildirimi
      final isTr = TranslationManager.isTurkish;
      NotificationService.instance.anlikBildirimGonder(
        title: isTr ? '🎉 [BİLİŞSEL ZİNDAN TAMAMLANDI]' : '🎉 [DEEP WORK COMPLETED]',
        body: isTr
            ? '${deepWork.topic} tamamlandı. +$expReward EXP, +$intReward INT, +$perReward PER kazanıldı!'
            : '${deepWork.topic} completed. +$expReward EXP, +$intReward INT, +$perReward PER gained!',
      );
    } else {
      AudioSystem.playLevelUp();
      // Odak moduna dön ve bekle
      deepWork.phase = DeepWorkPhase.focus;
      deepWork.initialSecondsForPhase = deepWork.focusMinutes * 60;
      deepWork.pausedRemainingSeconds = deepWork.initialSecondsForPhase;
      deepWork.targetEndTime = null;
      deepWork.isRunning = false;
      deepWork.isPaused = false;

      final isTr = TranslationManager.isTurkish;
      NotificationService.instance.anlikBildirimGonder(
        title: isTr ? '⚡ [DİNLENME PROTOKOLÜ BİTTİ]' : '⚡ [RECOVERY PROTOCOL FINISHED]',
        body: isTr
            ? 'Zihin toplandı. Yeni bir odak seansı başlatmaya hazırsın!'
            : 'Mind refreshed. Ready to start a new focus session!',
      );
    }

    _applyWakelock();
    notifyListeners();
  }

  void setKeepScreenOn(bool enable) {
    deepWork.keepScreenOn = enable;
    _applyWakelock();
    notifyListeners();
  }

  void _applyWakelock() {
    if (!kIsWeb) {
      if ((deepWork.isRunning && !deepWork.isPaused && deepWork.keepScreenOn) ||
          (restTimer.isRunning && !restTimer.isPaused)) {
        WakelockPlus.enable().catchError((_) {});
      } else {
        WakelockPlus.disable().catchError((_) {});
      }
    }
  }

  // =========================================================================
  // REST TIMER METOTLARI
  // =========================================================================
  void startRestTimer({
    required int seconds,
    String? exerciseName,
    VoidCallback? onComplete,
  }) {
    restTimer.totalSeconds = seconds;
    restTimer.exerciseName = exerciseName;
    restTimer.onComplete = onComplete;
    restTimer.targetEndTime = DateTime.now().add(Duration(seconds: seconds));
    restTimer.isRunning = true;
    restTimer.isPaused = false;
    restTimer.isMinimized = false;

    VoiceCoachSystem.dinlenmeBasladi(seconds, egzersizAdi: exerciseName);
    _applyWakelock();
    notifyListeners();
  }

  void addRestSeconds(int seconds) {
    if (!restTimer.isRunning) return;
    final currentRem = restTimer.remainingSeconds;
    final newTotal = currentRem + seconds;
    restTimer.totalSeconds = newTotal;
    restTimer.targetEndTime = DateTime.now().add(Duration(seconds: newTotal));
    notifyListeners();
  }

  void minimizeRestTimer() {
    restTimer.isMinimized = true;
    notifyListeners();
  }

  void stopRestTimer() {
    restTimer.isRunning = false;
    restTimer.isPaused = false;
    restTimer.targetEndTime = null;
    restTimer.isMinimized = false;
    NotificationService.instance.bildirimIptal(NotificationService.idRestTimer);
    _applyWakelock();
    notifyListeners();
  }

  void _finishRestTimer() {
    NotificationService.instance.bildirimIptal(NotificationService.idRestTimer);
    VoiceCoachSystem.dinlenmeBitti(egzersizAdi: restTimer.exerciseName);

    final callback = restTimer.onComplete;
    stopRestTimer();
    callback?.call();
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}
