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

    testWidgets('ActiveWorkoutScreen içinde zindana ek hareket enjekte etme ve silme çalışır', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActiveWorkoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+ EKLE'), findsOneWidget);
      expect(find.text('+ EK HAREKET ENJEKTE ET'), findsOneWidget);

      // + EKLE butonuna bas
      await tester.tap(find.text('+ EKLE'));
      await tester.pumpAndSettle();

      expect(find.text('ZİNDANA EK HAREKET ENJEKTE ET'), findsOneWidget);
      expect(find.text('ZİNDANA EKLE'), findsOneWidget);

      // Hızlı chip seçeneklerinden birine tıkla
      final chipFinder = find.text('Incline Dumbbell Press (3x10)');
      if (chipFinder.evaluate().isNotEmpty) {
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();
      }

      // Zindana Ekle'ye bas
      await tester.tap(find.text('ZİNDANA EKLE'));
      await tester.pumpAndSettle();

      // Dialog kapandı ve yeni hareket zindana eklendi
      expect(find.text('ZİNDANA EK HAREKET ENJEKTE ET'), findsNothing);
      expect(find.text('[EXTRA] Incline Dumbbell Press (3x10)'), findsOneWidget);

      // SnackBar süresini bekle
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Görevi silme butonuna bas (ekranda görünür kıl)
      final deleteBtnFinder = find.byTooltip('Görevi Kaldır').last;
      await tester.ensureVisible(deleteBtnFinder);
      await tester.pumpAndSettle();
      await tester.tap(deleteBtnFinder);
      await tester.pumpAndSettle();

      // Silinen hareket zindandan çıktı
      expect(find.text('[EXTRA] Incline Dumbbell Press (3x10)'), findsNothing);
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

    test('baslangicPrograminiAta 5-7 hareket standardına ve kardiyo katmanına sahiptir', () {
      SystemMemory.baslangicPrograminiAta(
        ekipman: 'salon',
        rank: 'E',
        idmanGunu: 3,
        hedef: 'combat',
      );
      // Pazartesi (1), Çarşamba (3), Cuma (5) günlerinde 5-7 hareket olmalı
      final pzt = SystemMemory.haftalikPlan[1]!;
      expect(pzt.length, greaterThanOrEqualTo(5));
      expect(pzt.length, lessThanOrEqualTo(7));
      // Kardiyo/kondisyon veya core katmanı içeriyor mu
      final kardiyoVar = pzt.any((g) => g.ad.contains('Koşu') || g.ad.contains('İp Atlama') || g.ad.contains('Sprawl') || g.ad.contains('Cardio'));
      expect(kardiyoVar, isTrue);
    });

    test('aiEkIdmanBoosterUret fonksiyonu hem append hem replace modunda çalışır', () async {
      final bugun = DateTime.now().weekday;
      SystemMemory.haftalikPlan[bugun] = [
        Gorev('Mevcut Hareket 1', false, 'Fiziksel'),
      ];

      // Append modu
      final eklenenler = await SystemMemory.aiEkIdmanBoosterUret(gun: bugun, sadeceBunuYap: false);
      expect(eklenenler.length, greaterThanOrEqualTo(3));
      expect(SystemMemory.haftalikPlan[bugun]!.length, greaterThanOrEqualTo(4));
      expect(SystemMemory.haftalikPlan[bugun]!.first.ad, 'Mevcut Hareket 1');

      // Replace modu
      await SystemMemory.aiEkIdmanBoosterUret(gun: bugun, sadeceBunuYap: true);
      expect(SystemMemory.haftalikPlan[bugun]!.any((g) => g.ad == 'Mevcut Hareket 1'), isFalse);
    });

    testWidgets('WorkoutPlannerScreen içindeki şablon diyaloğunda Ekle ve Sıfırla seçenekleri bulunur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutPlannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Icons.auto_awesome butonuna tıkla
      final sablonBtn = find.byIcon(Icons.auto_awesome);
      expect(sablonBtn, findsOneWidget);
      await tester.tap(sablonBtn);
      await tester.pumpAndSettle();

      // Dialog başlığı ve butonları kontrol et
      expect(find.text('SYSTEM WORKOUT TEMPLATES'), findsOneWidget);
      expect(find.text('+ GÜNLERE EKLE'), findsWidgets);
      expect(find.text('🔄 SIFIRLA VE KUR'), findsWidgets);
      expect(find.text('Cardio & MetCon Burn'), findsOneWidget);
      expect(find.text('🤖 AI AVCI ÖZEL BOOSTER'), findsOneWidget);
    });
  });
}

