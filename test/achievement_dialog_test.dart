import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_app/widgets/achievement_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Modül 4: AchievementDialog Widget Testleri', () {
    testWidgets('AchievementDialog açılır, yıldızları, başlığı ve ödül kabul butonunu doğru çizer',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AchievementDialog.show(
                    context,
                    message:
                        "[ACHIEVEMENT ASCENDED]\nIron Will (Tier 3)\nTarget Unlocked: 30 Day Streak",
                  );
                },
                child: const Text('TETİKLE'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tetikle butonuna bas
      await tester.tap(find.text('TETİKLE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog içeriği doğrulanır
      expect(find.text('[ SYSTEM ANNOUNCEMENT ]'), findsOneWidget);
      expect(find.text('ACHIEVEMENT ASCENDED'), findsOneWidget);
      expect(find.text('★★★☆☆☆'), findsOneWidget);
      expect(find.text('Iron Will (Tier 3)'), findsOneWidget);
      expect(find.text('Target Unlocked: 30 Day Streak'), findsOneWidget);

      // Ödül kabul et butonuna bas
      final acceptBtn = find.text('ACCEPT REWARD');
      expect(acceptBtn, findsOneWidget);
      await tester.tap(acceptBtn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog kapandı
      expect(find.text('[ SYSTEM ANNOUNCEMENT ]'), findsNothing);
    });
  });
}
