import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/dynamic_difficulty_engine.dart';
import 'package:solo_leveling_app/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.kilo = 70.0;
    SystemMemory.baslangicKilosu = 70.0;
    SystemMemory.yeniBasarimBildirimi.value = null;
  });

  group('Modül 6: Dinamik Zorluk Ayarlama Motoru (DDA) Testleri', () {
    test('DDA Engine streak ve fatigue durumuna göre doğru zorluk önerisi üretir', () {
      // 1. Normal -> Yüksek Upgrade Senaryosu
      SystemMemory.aktifZorluk = "Normal";
      SystemMemory.streakGunSayisi = 8;
      SystemMemory.fatigue.value = 30;

      final evalUpgrade = DynamicDifficultyEngine.analizEt();
      expect(evalUpgrade.action, DdaAction.upgrade);
      expect(evalUpgrade.onerilenZorluk, "Yüksek");

      // 2. Yüksek -> Cehennem Upgrade Senaryosu
      SystemMemory.aktifZorluk = "Yüksek";
      SystemMemory.streakGunSayisi = 15;
      SystemMemory.fatigue.value = 30;

      final evalCehennem = DynamicDifficultyEngine.analizEt();
      expect(evalCehennem.action, DdaAction.upgrade);
      expect(evalCehennem.onerilenZorluk, "Cehennem");

      // 3. Aşırı Yorgunluk Deload Senaryosu
      SystemMemory.fatigue.value = 85;

      final evalDeload = DynamicDifficultyEngine.analizEt();
      expect(evalDeload.action, DdaAction.deload);
      expect(evalDeload.onerilenZorluk, "Deload");

      // 4. Stabil Durum Maintain Senaryosu
      SystemMemory.aktifZorluk = "Normal";
      SystemMemory.streakGunSayisi = 2;
      SystemMemory.fatigue.value = 40;

      final evalMaintain = DynamicDifficultyEngine.analizEt();
      expect(evalMaintain.action, DdaAction.maintain);
    });

    test('zorluguUygula seçilen zorluğu sisteme entegre eder', () async {
      SystemMemory.aktifZorluk = "Normal";
      SystemMemory.aktifHedef = "Kilo Ver";

      final evalUpgrade = const DifficultyEvaluation(
        action: DdaAction.upgrade,
        mevcutZorluk: "Normal",
        onerilenZorluk: "Yüksek",
        baslik: "SİSTEM EVRİMİ",
        aciklama: "Açıklama",
        basariSkoru: 0.9,
        streak: 10,
      );

      await DynamicDifficultyEngine.zorluguUygula(evalUpgrade);
      expect(SystemMemory.aktifZorluk, "Yüksek");

      // Deload uygulama
      SystemMemory.fatigue.value = 80;
      final evalDeload = const DifficultyEvaluation(
        action: DdaAction.deload,
        mevcutZorluk: "Yüksek",
        onerilenZorluk: "Deload",
        baslik: "DELOAD",
        aciklama: "Açıklama",
        basariSkoru: 0.3,
        streak: 0,
      );

      await DynamicDifficultyEngine.zorluguUygula(evalDeload);
      expect(SystemMemory.fatigue.value, 0);
    });

    testWidgets('DashboardScreen üzerinde DDA Evolution Banner görüntülenir ve etkileşim çalışır',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SystemMemory.aktifZorluk = "Normal";
      SystemMemory.streakGunSayisi = 8;
      SystemMemory.basarimKademeleri['streak'] = 1;
      SystemMemory.fatigue.value = 20;

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // DDA banner ekranda belirmeli
      expect(find.text('SİSTEM EVRİMİ: ZORLUK KADEMESİ YÜKSELİŞİ'), findsOneWidget);
      final upgradeBtn = find.text('YÜKSEK ZORLUĞA GEÇ');
      expect(upgradeBtn, findsOneWidget);

      await tester.ensureVisible(upgradeBtn);
      await tester.tap(upgradeBtn);
      await tester.pump();

      expect(SystemMemory.aktifZorluk, "Yüksek");
      expect(find.text('SİSTEM: Yüksek protokolü devreye alındı!'), findsOneWidget);
    });
  });
}
