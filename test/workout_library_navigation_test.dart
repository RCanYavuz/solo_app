import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/screens/status_screen.dart';
import 'package:solo_leveling_app/screens/workout_planner_screen.dart';
import 'package:solo_leveling_app/screens/workout_library_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'level': 1});
    await SystemMemory.baslat();
  });

  group('Antrenman Kütüphanesi Navigasyon Testleri', () {
    testWidgets('StatusWindow ekranından Antrenman Kütüphanesine geçiş yapılabilmeli', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatusWindow(),
        ),
      );
      await tester.pumpAndSettle();

      final libraryButton = find.byTooltip('Workout Library');
      expect(libraryButton, findsOneWidget);

      await tester.tap(libraryButton);
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutLibraryScreen), findsOneWidget);
    });

    testWidgets('WorkoutPlannerScreen ekranından Antrenman Kütüphanesine geçiş yapılabilmeli', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutPlannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final libraryButton = find.byTooltip('Workout Library');
      expect(libraryButton, findsOneWidget);

      await tester.tap(libraryButton);
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutLibraryScreen), findsOneWidget);
    });
  });
}
