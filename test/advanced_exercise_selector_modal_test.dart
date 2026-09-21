// test/advanced_exercise_selector_modal_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/task_model.dart';
import 'package:solo_leveling_app/screens/workout_planner_screen.dart';
import 'package:solo_leveling_app/widgets/advanced_exercise_selector_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
  });

  group('AdvancedExerciseSelectorModal (Gelişmiş Egzersiz Ekleme Modalı) Testleri', () {
    testWidgets('Modal açılır, canlı arama yapar ve seçilen hareketi set/tekrar ile callbacke aktarır', (tester) async {
      Gorev? eklenen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AdvancedExerciseSelectorModal.show(
                    context,
                    baslik: 'ZİNDANA EK HAREKET ENJEKTE ET',
                    onayButonMetni: 'ZİNDANA EKLE',
                    onEklendi: (g) => eklenen = g,
                  );
                },
                child: const Text('MODAL AC'),
              ),
            ),
          ),
        ),
      );

      // Modalı aç
      await tester.tap(find.text('MODAL AC'));
      await tester.pumpAndSettle();

      expect(find.text('ZİNDANA EK HAREKET ENJEKTE ET'), findsOneWidget);
      expect(find.text('ZİNDANA EKLE'), findsOneWidget);

      // Canlı arama yap: 'Squat'
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Squat');
      await tester.pumpAndSettle();

      // Squat sonuçları listelenmeli
      expect(find.text('Barbell Squat'), findsOneWidget);

      // Barbell Squat'a tıkla
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      // Hacim kademesinden '👑 Şampiyon (8 Set/Raund)' seç
      await tester.tap(find.text('👑 Şampiyon (8 Set/Raund)'));
      await tester.pumpAndSettle();

      // Onayla ve Ekle
      await tester.tap(find.text('ZİNDANA EKLE'));
      await tester.pumpAndSettle();

      // Modal kapandı ve callback tetiklendi
      expect(find.text('ZİNDANA EK HAREKET ENJEKTE ET'), findsNothing);
      expect(eklenen, isNotNull);
      expect(eklenen!.ad.contains('Barbell Squat'), isTrue);
      expect(eklenen!.ad.contains('8 Set'), isTrue);
    });

    testWidgets('Kardiyo kategorisi seçildiğinde kardiyo süresi seçicileri devreye girer', (tester) async {
      Gorev? eklenen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AdvancedExerciseSelectorModal.show(
                    context,
                    baslik: 'ZİNDANA EK HAREKET ENJEKTE ET',
                    onayButonMetni: 'ZİNDANA EKLE',
                    onEklendi: (g) => eklenen = g,
                  );
                },
                child: const Text('MODAL AC'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('MODAL AC'));
      await tester.pumpAndSettle();

      // Kardiyo çipine bas
      await tester.tap(find.text('Kardiyo'));
      await tester.pumpAndSettle();

      expect(find.text('KARDİYO SÜRESİ:'), findsOneWidget);
      expect(find.text('30 Dk'), findsOneWidget);

      // 30 Dk seç
      await tester.tap(find.text('30 Dk'));
      await tester.pumpAndSettle();

      // Kardiyo listesinden bir hareket seç (örn: 5 KM Avcı Koşusu)
      final cardioItem = find.text('5 KM Avcı Koşusu (Hunter Run)');
      expect(cardioItem, findsOneWidget);
      await tester.tap(cardioItem);
      await tester.pumpAndSettle();

      // Ekle
      await tester.tap(find.text('ZİNDANA EKLE'));
      await tester.pumpAndSettle();

      expect(eklenen, isNotNull);
      expect(eklenen!.ad.contains('[CARDIO]'), isTrue);
      expect(eklenen!.ad.contains('5 KM Avcı Koşusu'), isTrue);
    });

    testWidgets('WorkoutPlannerScreen üzerinden kütüphaneden ara ve ekle modalı tetiklenir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutPlannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Kütüphaneden Ara & Ekle butonunu bul
      final libSearchBtn = find.byTooltip('Kütüphaneden Ara & Ekle');
      expect(libSearchBtn, findsOneWidget);

      await tester.tap(libSearchBtn);
      await tester.pumpAndSettle();

      expect(find.text('PLANA EGZERSİZ ENJEKTE ET'), findsOneWidget);
      expect(find.text('SEÇİLİ GÜNLERE EKLE'), findsOneWidget);

      // Bir hareketi seç ve plana ekle
      await tester.tap(find.text('SEÇİLİ GÜNLERE EKLE'));
      await tester.pumpAndSettle();

      expect(find.text('PLANA EGZERSİZ ENJEKTE ET'), findsNothing);
    });
  });
}
