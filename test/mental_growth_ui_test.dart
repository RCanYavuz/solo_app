import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/mental_task_model.dart';
import 'package:solo_leveling_app/screens/deep_work_timer_screen.dart';
import 'package:solo_leveling_app/widgets/study_planner_modal.dart';
import 'package:solo_leveling_app/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.gunlukZihinselGorevler.value = [];
  });

  group('Faz 2: UI & Widget Testleri (StudyPlannerModal, DeepWorkTimer, Dashboard)', () {
    testWidgets('DeepWorkTimerScreen doğru render edilir ve kontroller çalışır', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeepWorkTimerScreen(
            initialTopic: 'Yapay Zeka Mimarisi',
            initialMinutes: 25,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BİLİŞSEL ZİNDAN // DEEP WORK'), findsOneWidget);
      expect(find.text('BAŞLAT'), findsOneWidget);
      expect(find.text('BİTİR'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);

      // Başlat butonuna basıldığında sayacın Duraklat butonuna dönüştüğünü doğrula
      await tester.tap(find.text('BAŞLAT'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('DURAKLAT'), findsOneWidget);

      // Duraklat
      await tester.tap(find.text('DURAKLAT'));
      await tester.pump();
      expect(find.text('BAŞLAT'), findsOneWidget);
    });

    testWidgets('StudyPlannerModal ekranda açılır, alan ve süre seçimi yapılabilir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => StudyPlannerModal.show(ctx),
                child: const Text('AÇ'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('AÇ'));
      await tester.pumpAndSettle();

      expect(find.text('SİSTEM // ZİHİNSEL GELİŞİM PROTOKOLÜ'), findsOneWidget);
      expect(find.text('GÖREV PROTOKOLÜNÜ ÜRET'), findsOneWidget);
      expect(find.text('25 dk'), findsOneWidget);
      expect(find.text('45 dk'), findsOneWidget);

      // 45 dk seç
      await tester.tap(find.text('45 dk'));
      await tester.pump();

      // Görev protokolünü üret butonuna tıkla (offline fallback devreye girer)
      await tester.tap(find.text('GÖREV PROTOKOLÜNÜ ÜRET'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('GÖREVLERİ GÜNLÜK LİSTEYE EKLE'), findsOneWidget);
    });

    testWidgets('DashboardScreen üzerinde filtre çipleri ve zihinsel görevler render edilir', (tester) async {
      SystemMemory.gunlukZihinselGorevler.value = [
        MentalTask(
          id: 'test_task_dash',
          title: 'Sistem Mimarisi Okuması',
          category: 'Book',
          targetMinutes: 30,
          targetPages: 15,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TÜMÜ'), findsOneWidget);
      expect(find.text('⚔️ FİZİKSEL'), findsOneWidget);
      expect(find.text('🧠 ZİHİNSEL'), findsOneWidget);

      // Zihinsel görev başlığı ekranda olmalı
      expect(find.text('Sistem Mimarisi Okuması'), findsOneWidget);

      // Alt butonlarda hem Fiziksel hem Bilişsel Zindan olmalı
      expect(find.text('FİZİKSEL ZİNDAN'), findsOneWidget);
      expect(find.text('BİLİŞSEL ZİNDAN'), findsOneWidget);

      // Sadece Zihinsel filtresine tıkla
      await tester.tap(find.text('🧠 ZİHİNSEL'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Sistem Mimarisi Okuması'), findsOneWidget);
    });
  });
}
