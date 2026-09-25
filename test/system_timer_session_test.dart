// test/system_timer_session_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/system_session_manager.dart';
import 'package:solo_leveling_app/widgets/global_timer_hud.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.appLanguage.value = 'tr';
    SystemSessionManager.instance.resetDeepWork();
    SystemSessionManager.instance.stopRestTimer();
  });

  tearDown(() {
    SystemSessionManager.instance.resetDeepWork();
    SystemSessionManager.instance.stopRestTimer();
  });

  group('SystemSessionManager & Wall-Clock Timer Reliability Tests', () {
    test('startDeepWork sets targetEndTime and computes remainingSeconds correctly', () {
      final manager = SystemSessionManager.instance;
      manager.startDeepWork(topic: 'Yapay Zeka Mimarisi', focusMinutes: 25, restMinutes: 5);

      expect(manager.deepWork.isRunning, isTrue);
      expect(manager.deepWork.isPaused, isFalse);
      expect(manager.deepWork.topic, 'Yapay Zeka Mimarisi');
      expect(manager.deepWork.targetEndTime, isNotNull);
      expect(manager.deepWork.remainingSeconds, inInclusiveRange(24 * 60 + 58, 25 * 60));
    });

    test('didChangeAppLifecycleState(resumed) reconciles elapsed time when phone unlocked', () {
      final manager = SystemSessionManager.instance;
      manager.startDeepWork(topic: 'Kodlama', focusMinutes: 25, restMinutes: 5);

      // Simüle et: Telefon 10 dakika kilitlendi (targetEndTime 15 dakika sonraya kaymış gibi)
      manager.deepWork.targetEndTime = DateTime.now().add(const Duration(minutes: 15));

      // Resumed çağrıldığında
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Kalan saniye 15 dakika civarında olmalı (takılı kalmamış!)
      expect(manager.deepWork.remainingSeconds, inInclusiveRange(14 * 60 + 55, 15 * 60));
    });

    test('resumed after targetEndTime automatically finishes phase and grants rewards', () {
      final manager = SystemSessionManager.instance;
      final int initialTotalFocus = SystemMemory.toplamOdaklanmaDakikasi;

      manager.startDeepWork(topic: 'Sistem Algoritmaları', focusMinutes: 20, restMinutes: 5);

      // Simüle et: Süre doldu (targetEndTime geçmişte)
      manager.deepWork.targetEndTime = DateTime.now().subtract(const Duration(seconds: 10));

      // Telefon açıldı (resumed)
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Odak seansı tamamlanmış olmalı
      expect(SystemMemory.toplamOdaklanmaDakikasi, initialTotalFocus + 20);
      expect(manager.deepWork.phase, DeepWorkPhase.rest);
      expect(manager.deepWork.completedSessions, 1);
      expect(manager.deepWork.pendingCompletionReward, isNotNull);
    });

    test('RestTimer tracks wall-clock time and supports addRestSeconds', () {
      final manager = SystemSessionManager.instance;
      bool completed = false;

      manager.startRestTimer(
        seconds: 60,
        exerciseName: 'Bench Press',
        onComplete: () => completed = true,
      );

      expect(manager.restTimer.isRunning, isTrue);
      expect(manager.restTimer.remainingSeconds, inInclusiveRange(58, 60));

      // +30s ekle
      manager.addRestSeconds(30);
      expect(manager.restTimer.remainingSeconds, inInclusiveRange(88, 90));

      // Süre bittiğinde
      manager.restTimer.targetEndTime = DateTime.now().subtract(const Duration(seconds: 1));
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(completed, isTrue);
      expect(manager.restTimer.isRunning, isFalse);
    });
  });

  group('GlobalTimerHUD Widget Tests', () {
    testWidgets('GlobalTimerHUD is invisible when no timer is active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalTimerHUD(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('BİLİŞSEL ZİNDAN'), findsNothing);
    });

    testWidgets('GlobalTimerHUD renders glowing HUD when Deep Work is running', (tester) async {
      final manager = SystemSessionManager.instance;
      manager.startDeepWork(topic: 'Rust Async', focusMinutes: 50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalTimerHUD(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('BİLİŞSEL ZİNDAN'), findsOneWidget);
      expect(find.text('Rust Async'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Duraklat
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      expect(manager.deepWork.isPaused, isTrue);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('GlobalTimerHUD renders Rest HUD when rest timer is minimized', (tester) async {
      final manager = SystemSessionManager.instance;
      manager.startRestTimer(seconds: 45, exerciseName: 'Overhead Press');
      manager.minimizeRestTimer();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalTimerHUD(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('DİNLENME'), findsOneWidget);
      expect(find.text('Overhead Press'), findsOneWidget);
      expect(find.text('+30s'), findsOneWidget);

      // +30s tıkla
      await tester.tap(find.text('+30s'));
      await tester.pump();
      expect(manager.restTimer.remainingSeconds, inInclusiveRange(70, 75));
    });
  });
}
