import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/screens/dashboard_screen.dart';
import 'package:solo_leveling_app/widgets/sleep_tracker_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.uyunanSaat = 0;
  });

  group('Modül 2: SleepTrackerCard Widget Testleri', () {
    testWidgets('SleepTrackerCard ekranda belirir, artı/eksi butonları ve hazır çipler çalışır',
        (WidgetTester tester) async {
      int callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SleepTrackerCard(
              onSleepChanged: () => callbackCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Başlık ve metinler görünür olmalı
      expect(find.text('RECOVERY CHAMBER'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('HRS SLEPT'), findsOneWidget);
      expect(find.text('Henüz uyku verisi girilmedi.'), findsOneWidget);

      // Artı butonuna bas
      final addBtn = find.byTooltip('Artır');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(SystemMemory.uyunanSaat, 1);
      expect(find.text('1'), findsOneWidget);
      expect(callbackCount, 1);

      // 8h hazır çipine bas
      final chip8 = find.text('8h');
      expect(chip8, findsOneWidget);
      await tester.tap(chip8);
      await tester.pumpAndSettle();

      expect(SystemMemory.uyunanSaat, 8);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('✨ OPTİMAL: +2 MP & Tam Yorgunluk Arınması.'), findsOneWidget);
      expect(callbackCount, 2);

      // Eksi butonuna bas
      final removeBtn = find.byTooltip('Azalt');
      await tester.tap(removeBtn);
      await tester.pumpAndSettle();

      expect(SystemMemory.uyunanSaat, 7);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('DashboardScreen üzerinde SleepTrackerCard düzgün render edilir',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SleepTrackerCard), findsOneWidget);
      expect(find.text('RECOVERY CHAMBER'), findsOneWidget);
    });
  });
}
