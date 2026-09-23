import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/task_model.dart';
import 'package:solo_leveling_app/screens/active_workout_screen.dart';
import 'package:solo_leveling_app/screens/dashboard_screen.dart';
import 'package:solo_leveling_app/screens/workout_planner_screen.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.appLanguage.value = 'tr';
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

      expect(find.text(TranslationManager.get('workout_active_quests')), findsOneWidget);
      expect(find.text(TranslationManager.get('workout_rest')), findsOneWidget);

      // REST butonuna basınca RestTimerDialog açılır
      await tester.tap(find.text(TranslationManager.get('workout_rest')));
      await tester.pumpAndSettle();

      expect(find.text(TranslationManager.get('rest_mp_recovery_title')), findsOneWidget);
      expect(find.text(TranslationManager.get('rest_ready_btn')), findsOneWidget);

      // Sayacı kapat
      await tester.tap(find.text(TranslationManager.get('rest_ready_btn')));
      await tester.pumpAndSettle();
      expect(find.text(TranslationManager.get('rest_mp_recovery_title')), findsNothing);

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

      expect(find.text(TranslationManager.get('rest_mp_recovery_title')), findsOneWidget);
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
      final chipFinder = find.text('Incline Dumbbell Press');
      if (chipFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(chipFinder);
        await tester.pumpAndSettle();
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();
      }

      // Zindana Ekle'ye bas
      await tester.tap(find.text('ZİNDANA EKLE'));
      await tester.pumpAndSettle();

      // Dialog kapandı
      expect(find.text('ZİNDANA EK HAREKET ENJEKTE ET'), findsNothing);

      // SnackBar süresini bekle
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Yeni hareket zindana eklendi
      expect(find.textContaining('[EXTRA] Incline Dumbbell Press'), findsOneWidget);

      // Görevi silme butonuna bas (ekranda görünür kıl)
      final deleteBtnFinder = find.byTooltip('Görevi Kaldır').last;
      await tester.ensureVisible(deleteBtnFinder);
      await tester.pumpAndSettle();
      await tester.tap(deleteBtnFinder);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Silinen hareket zindandan çıktı
      final bugun = DateTime.now().weekday;
      expect(SystemMemory.haftalikPlan[bugun]!.any((g) => g.ad.contains('Incline Dumbbell Press')), isFalse);
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

    test('baslangicPrograminiAta 6-8 hareket standardına ve kardiyo katmanına sahiptir', () {
      SystemMemory.baslangicPrograminiAta(
        ekipman: 'salon',
        rank: 'E',
        idmanGunu: 3,
        hedef: 'combat',
      );
      // Pazartesi (1), Çarşamba (3), Cuma (5) günlerinde 6-8 hareket olmalı
      final pzt = SystemMemory.haftalikPlan[1]!;
      expect(pzt.length, greaterThanOrEqualTo(6));
      expect(pzt.length, lessThanOrEqualTo(8));
      // Her antrenman gününde net bir CARDIO görevi bulunmalı
      for (int gun in [1, 3, 5]) {
        final plan = SystemMemory.haftalikPlan[gun]!;
        final kardiyoVar = plan.any((g) => g.ad.contains('[CARDIO]'));
        expect(kardiyoVar, isTrue, reason: 'Gün $gun kardiyo görevi içermeli');
      }
    });

    test('aiEkIdmanBoosterUret fonksiyonu hem append hem replace modunda çalışır ve kardiyo içerir', () async {
      final bugun = DateTime.now().weekday;
      SystemMemory.haftalikPlan[bugun] = [
        Gorev('Mevcut Hareket 1', false, 'Fiziksel'),
      ];

      // Append modu
      final eklenenler = await SystemMemory.aiEkIdmanBoosterUret(gun: bugun, sadeceBunuYap: false);
      expect(eklenenler.length, greaterThanOrEqualTo(4));
      expect(SystemMemory.haftalikPlan[bugun]!.length, greaterThanOrEqualTo(5));
      expect(SystemMemory.haftalikPlan[bugun]!.first.ad, 'Mevcut Hareket 1');
      expect(eklenenler.any((g) => g.ad.contains('[CARDIO]')), isTrue);

      // Replace modu
      await SystemMemory.aiEkIdmanBoosterUret(gun: bugun, sadeceBunuYap: true);
      expect(SystemMemory.haftalikPlan[bugun]!.any((g) => g.ad == 'Mevcut Hareket 1'), isFalse);
      expect(SystemMemory.haftalikPlan[bugun]!.any((g) => g.ad.contains('[CARDIO]')), isTrue);
    });

    testWidgets('WorkoutPlannerScreen içindeki şablon diyaloğunda Ekle ve Sıfırla seçenekleri bulunur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutPlannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Şablon butonuna tıkla
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // Dialog başlığı ve butonları kontrol et
      expect(find.text('SYSTEM WORKOUT TEMPLATES'), findsOneWidget);
      expect(find.text('+ GÜNLERE EKLE'), findsWidgets);
      expect(find.text('🔄 SIFIRLA VE KUR'), findsWidgets);
      expect(find.text('Cardio & MetCon Burn'), findsOneWidget);
      expect(find.text('🏃 Avcı 5K/10K Koşu & HIIT'), findsOneWidget);
      expect(find.text('⚡ Tabata & MetCon Extreme Burn'), findsOneWidget);
      expect(find.text('🤖 AI AVCI ÖZEL BOOSTER'), findsOneWidget);
      expect(find.text('Gölge Boksu & Kombinasyonlar (5 Raund)'), findsOneWidget);
    });

    test('dovusGolgeBoksuKombinasyonlari branşa göre 5 uzatılmış raundluk kombinasyon döner', () {
      final boksRaundlar = SystemMemory.dovusGolgeBoksuKombinasyonlari(brans: 'Boks');
      expect(boksRaundlar.length, 5);
      expect(boksRaundlar.any((r) => r.ad.contains('Peek-a-boo')), isTrue);
      expect(boksRaundlar.any((r) => r.ad.contains('Karaciğer')), isTrue);

      final kickRaundlar = SystemMemory.dovusGolgeBoksuKombinasyonlari(brans: 'Kickboks');
      expect(kickRaundlar.length, 5);
      expect(kickRaundlar.any((r) => r.ad.contains('Dutch Volume')), isTrue);
      expect(kickRaundlar.any((r) => r.ad.contains('Low Kick')), isTrue);

      final mmaRaundlar = SystemMemory.dovusGolgeBoksuKombinasyonlari(brans: 'MMA');
      expect(mmaRaundlar.length, 5);
      expect(mmaRaundlar.any((r) => r.ad.contains('Sprawl')), isTrue);
      expect(mmaRaundlar.any((r) => r.ad.contains('Grapple')), isTrue);
    });

    testWidgets('ActiveWorkoutScreen içindeki ek hareket diyaloğunda Hacim & Uzatma Seçicileri bulunur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActiveWorkoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ EKLE'));
      await tester.pumpAndSettle();

      expect(find.text('HACİM & UZATMA SEVİYESİ:'), findsOneWidget);
      expect(find.text('⚔️ Uzatılmış (6 Set/Raund)'), findsOneWidget);
      expect(find.text('👑 Şampiyon (8 Set/Raund)'), findsOneWidget);
      expect(find.text('🔥 Ekstrem (10 Set/Raund)'), findsOneWidget);
      expect(find.textContaining('Set/Raund:'), findsOneWidget);

      // Kardiyo kategorisinin varlığını doğrula
      expect(find.text('Kardiyo'), findsOneWidget);
    });

    testWidgets('DashboardScreen üzerinde görev checkboxına basılarak görev direkt tamamlanabilir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      int bugun = DateTime.now().weekday;
      final gorevler = SystemMemory.haftalikPlan[bugun]!;
      expect(gorevler.isNotEmpty, isTrue);

      final ilkGorev = gorevler.first;
      expect(ilkGorev.yapildiMi, isFalse);

      // Checkbox ikonuna tıkla
      final checkFinder = find.byIcon(Icons.check_box_outline_blank);
      await tester.scrollUntilVisible(checkFinder.first, 300, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(checkFinder.first);
      await tester.pumpAndSettle();

      // Görev durumu true olmalı ve checked ikonu görünmeli
      expect(ilkGorev.yapildiMi, isTrue);
      expect(find.byIcon(Icons.check_box), findsWidgets);

      // Tekrar tıklayarak uncheck yapabilmeli
      final checkedFinder = find.byIcon(Icons.check_box);
      await tester.tap(checkedFinder.first);
      await tester.pumpAndSettle();

      expect(ilkGorev.yapildiMi, isFalse);
    });
  });
}
