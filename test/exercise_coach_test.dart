import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/exercise_coach.dart';
import 'package:solo_leveling_app/models/task_model.dart';
import 'package:solo_leveling_app/widgets/rest_timer_dialog.dart';
import 'package:solo_leveling_app/widgets/exercise_detail_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
  });

  group('ExerciseCoach Taktik ve Swap Motoru Testleri', () {
    test('Şınav için hedef kas ve form kuralları doğru döner', () {
      final taktik = ExerciseCoach.getTactics('[COMBAT] Boks: Patlayıcı Şınav (4x8)');
      expect(taktik.ad.toLowerCase().contains('şınav'), isTrue);
      expect(taktik.hedefKaslar.toLowerCase().contains('göğüs'), isTrue);
      expect(taktik.formKurallari.length, greaterThanOrEqualTo(3));
      expect(taktik.alternatifler.isNotEmpty, isTrue);
    });

    test('Bench Press için eklem koruma ve alternatifleri doğru döner', () {
      final taktik = ExerciseCoach.getTactics('[PHY] Bench Press (4x10)');
      expect(taktik.hedefKaslar.toLowerCase().contains('triceps'), isTrue);
      expect(taktik.alternatifler.any((a) => a.contains('Floor Press')), isTrue);
    });

    test('Bilinmeyen bir hareket girildiğinde genel akıllı taktik döner', () {
      final taktik = ExerciseCoach.getTactics('Özel Dövüş Jimnastiği (3x15)');
      expect(taktik.formKurallari.isNotEmpty, isTrue);
      expect(taktik.alternatifler.isNotEmpty, isTrue);
    });

    test('swapExercise ile haftalık plandaki hareket başarıyla güncellenir', () async {
      SystemMemory.haftalikPlan[1] = [
        Gorev('[PHY] Bench Press (4x10)', false, 'Fiziksel'),
      ];

      final sonuc = await ExerciseCoach.swapExercise(
        gun: 1,
        index: 0,
        yeniHareketAdi: 'Dumbbell Floor Press (Omuz Dostu) (4x10)',
      );

      expect(sonuc, isTrue);
      expect(SystemMemory.haftalikPlan[1]![0].ad, 'Dumbbell Floor Press (Omuz Dostu) (4x10)');
    });
  });

  group('Set & Ağırlık Takip Modeli Testleri', () {
    test('Gorev içine SetKaydi eklenebilir ve JSON serileştirmesi korunur', () {
      final gorev = Gorev('Incline Dumbbell Press', false, 'Fiziksel');
      expect(gorev.setler, isEmpty);

      gorev.setler.add(SetKaydi(setNo: 1, kilo: 30.0, tekrar: 10, tamamlandi: true));
      gorev.setler.add(SetKaydi(setNo: 2, kilo: 32.5, tekrar: 8, tamamlandi: false));

      final json = gorev.toJson();
      final geriDonen = Gorev.fromJson(json);

      expect(geriDonen.setler.length, 2);
      expect(geriDonen.setler[0].kilo, 30.0);
      expect(geriDonen.setler[0].tamamlandi, isTrue);
      expect(geriDonen.setler[1].tekrar, 8);
      expect(geriDonen.setler[1].tamamlandi, isFalse);
    });
  });

  group('UI Modalları Widget Testleri', () {
    testWidgets('RestTimerDialog render olur ve süre butonları çalışır', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestTimerDialog(initialSeconds: 60, exerciseName: 'Patlayıcı Şınav'),
          ),
        ),
      );

      expect(find.text('MP RECOVERY (REST TIMER)'), findsOneWidget);
      expect(find.text('Patlayıcı Şınav'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
      expect(find.text('+15 SN'), findsOneWidget);

      await tester.tap(find.text('30s'));
      await tester.pump();
      expect(find.text('00:30'), findsOneWidget);
    });

    testWidgets('ExerciseDetailModal taktik bilgilerini ve YouTube butonunu render eder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseDetailModal(gorevAdi: '[COMBAT] Bench Press (4x10)'),
          ),
        ),
      );

      expect(find.text('HEDEF KASLAR'), findsOneWidget);
      expect(find.text('KRİTİK FORM KURALLARI'), findsOneWidget);
      expect(find.text('YOUTUBE REHBERİ'), findsOneWidget);
    });
  });
}
