// test/faz3_analytics_and_calendar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/services/notification_service.dart';
import 'package:solo_leveling_app/screens/analytics_screen.dart';
import 'package:solo_leveling_app/screens/calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    await NotificationService.instance.init(testMode: true);
    SystemMemory.appLanguage.value = 'tr';
    SystemMemory.kilo = 80.0;
    SystemMemory.hedefKilo = 75.0;
    SystemMemory.kiloGecmisi = [
      {'tarih': '2026-09-01 10:00:00', 'kilo': 83.0},
      {'tarih': '2026-09-10 10:00:00', 'kilo': 81.5},
      {'tarih': '2026-09-20 10:00:00', 'kilo': 80.0},
    ];
    SystemMemory.idmanGecmisi = [
      {
        'tarih': '2026-09-24 18:30:00',
        'dakika': 45,
        'gorevSayisi': 6,
        'yakilanKalori': 350,
      }
    ];
    SystemMemory.yemekGecmisi = [
      {
        'tarih': '2026-09-24',
        'toplamKalori': 2100,
        'hedefKalori': 2200,
        'protein': 150,
        'karb': 220,
        'yag': 60,
      }
    ];
    SystemMemory.maxBench = 100.0;
    SystemMemory.maxSquat = 140.0;
    SystemMemory.maxDeadlift = 180.0;
    SystemMemory.streakGunSayisi = 5;
  });

  group('FAZ 3: Veri Görselleştirme, İstatistik Paneli & Takvim Rozetleri', () {
    testWidgets('AnalyticsScreen 4 sekmesi ve metrik kartları ile başarıyla açılır', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AnalyticsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Başlık ve Sekmeler
      expect(find.text('[ SİSTEM // GELİŞİM & İLERLEME ANALİZİ ]'), findsOneWidget);
      expect(find.text('KİLO TRENDİ'), findsOneWidget);
      expect(find.text('İDMAN HACMİ'), findsOneWidget);
      expect(find.text('BESLENME TRENDİ'), findsOneWidget);
      expect(find.text('1RM KUVVET'), findsOneWidget);

      // Kilo Metrikleri
      expect(find.text('80.0 kg'), findsWidgets);
      expect(find.text('75.0 kg'), findsOneWidget);
      expect(find.text('-3.0 kg'), findsOneWidget); // 80 - 83 = -3 kg

      // 2. Sekmeye geç: İDMAN HACMİ
      await tester.tap(find.text('İDMAN HACMİ'));
      await tester.pumpAndSettle();
      expect(find.text('ZİNDAN HACMİ & SÜRE DAĞILIMI'), findsOneWidget);

      // 3. Sekmeye geç: BESLENME TRENDİ
      await tester.tap(find.text('BESLENME TRENDİ'));
      await tester.pumpAndSettle();
      expect(find.text('KALORİ ALIMI & HEDEF ÇİZGİSİ'), findsOneWidget);

      // 4. Sekmeye geç: 1RM KUVVET
      await tester.tap(find.text('1RM KUVVET'));
      await tester.pumpAndSettle();
      expect(find.text('420.0 kg'), findsOneWidget); // 100 + 140 + 180 = 420 kg
      expect(find.text('5.25x BW'), findsOneWidget); // 420 / 80 = 5.25x BW
      expect(find.text('S-Rank Apex Hunter'), findsOneWidget); // 5.25x >= 4.5
    });

    testWidgets('CalendarScreen üzerinde idman ve diyet rozetleri gösterilir ve analitik butonuna basılabilir', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Takvim AppBar'ında Analiz butonu olmalı
      final analyticsBtn = find.byIcon(Icons.insights);
      expect(analyticsBtn, findsOneWidget);

      // 24 Eylül 2026 tarihine tıkla (idman ve diyet var)
      final dateFinder = find.text('24');
      if (dateFinder.evaluate().isNotEmpty) {
        await tester.tap(dateFinder.first);
        await tester.pumpAndSettle();
        // Alt panelde hem idman hem beslenme arşivi başlığı olmalı
        expect(find.text('BESLENME VE ENERJİ ARŞİVİ'), findsOneWidget);
      }

      // Analiz butonuna tıkla
      await tester.tap(analyticsBtn);
      await tester.pumpAndSettle();

      // AnalyticsScreen açılmalı
      expect(find.text('[ SİSTEM // GELİŞİM & İLERLEME ANALİZİ ]'), findsOneWidget);
    });

    test('Akıllı Streak Bildirimi planlama ve güncelleme hatasız çalışır', () async {
      // 5 günlük streak varken ve tamamlanmamış görev varken
      await NotificationService.instance.akilliStreakBildirimiGuncelle(
        streak: 5,
        kalanGorevSayisi: 3,
      );

      // streak 0 iken otomatik iptal edilir
      await NotificationService.instance.akilliStreakBildirimiGuncelle(
        streak: 0,
        kalanGorevSayisi: 3,
      );

      // görevler bitince (kalan=0) otomatik iptal edilir
      await NotificationService.instance.akilliStreakBildirimiGuncelle(
        streak: 5,
        kalanGorevSayisi: 0,
      );

      // SystemMemory üzerinden senkronizasyon hatasız döner
      await expectLater(SystemMemory.streakBildiriminiGuncelle(), completes);
    });
  });
}
