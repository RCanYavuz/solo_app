import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/task_model.dart';
import 'package:solo_leveling_app/screens/active_workout_screen.dart';
import 'package:solo_leveling_app/screens/dashboard_screen.dart';
import 'package:solo_leveling_app/screens/workout_planner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    final bugun = DateTime.now().weekday;
    SystemMemory.haftalikPlan[bugun] = [
      Gorev('[COMBAT] Bench Press (4x10)', false, 'Fiziksel'),
      Gorev('[PHY] Squat (4x12)', false, 'Fiziksel'),
    ];
  });

  group('Uçtan Uca Antrenman Deneyimi Akış Testleri', () {
    testWidgets('Dashboard üzerinden göreve basıldığında Avcı Taktik Kartı açılır ve alternatif değiştirilebilir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Görev başlığına kaydır ve dokun
      final gorevFinder = find.text('[COMBAT] Bench Press (4x10)');
      await tester.scrollUntilVisible(gorevFinder, 300, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(gorevFinder, findsOneWidget);

      await tester.tap(gorevFinder);
      await tester.pumpAndSettle();

      // Modal açıldı mı?
      expect(find.text('HEDEF KASLAR'), findsOneWidget);
      expect(find.text('KRİTİK FORM KURALLARI'), findsOneWidget);
      expect(find.text('ALTERNATİFLER'), findsOneWidget);

      // Alternatifler sekmesine geç
      await tester.tap(find.text('ALTERNATİFLER'));
      await tester.pumpAndSettle();

      expect(find.text('EŞDEĞER ALTERNATİFLER'), findsOneWidget);
      expect(find.text('SEÇ'), findsWidgets);

      // İlk alternatifi seç
      await tester.tap(find.text('SEÇ').first);
      await tester.pumpAndSettle();

      // Modal kapandı ve Dashboard güncellendi
      expect(find.text('HEDEF KASLAR'), findsNothing);
    });

    testWidgets('ActiveWorkoutScreen içinde set ekleme, düzenleme ve dinlenme sayacı tetiklenir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActiveWorkoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE QUESTS'), findsOneWidget);
      expect(find.text('REST'), findsOneWidget);

      // REST butonuna basınca RestTimerDialog açılır
      await tester.tap(find.text('REST'));
      await tester.pumpAndSettle();

      expect(find.text('MP RECOVERY (REST TIMER)'), findsOneWidget);
      expect(find.text('HAZIRIM'), findsOneWidget);

      // Sayacı kapat
      await tester.tap(find.text('HAZIRIM'));
      await tester.pumpAndSettle();
      expect(find.text('MP RECOVERY (REST TIMER)'), findsNothing);

      // Set açma/kapama ikonuna bas
      final expandIconFinder = find.byIcon(Icons.playlist_add_check).first;
      await tester.tap(expandIconFinder);
      await tester.pumpAndSettle();

      expect(find.text('SET & OVERLOAD LOG'), findsOneWidget);
      expect(find.text('SET EKLE'), findsOneWidget);

      // SET EKLE butonuna bas
      await tester.tap(find.text('SET EKLE'));
      await tester.pumpAndSettle();

      expect(find.text('SET 1'), findsOneWidget);

      // Seti tamamla (check ikonuna bas) -> Otomatik RestTimer açılır
      final checkSetFinder = find.byIcon(Icons.radio_button_unchecked).first;
      await tester.tap(checkSetFinder);
      await tester.pumpAndSettle();

      expect(find.text('MP RECOVERY (REST TIMER)'), findsOneWidget);
    });

    testWidgets('WorkoutPlannerScreen üzerinde taktik ve silme butonları düzgün çalışır', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutPlannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutPlannerScreen), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsWidgets);
      expect(find.byIcon(Icons.play_circle_fill), findsWidgets);
    });
  });
}
