// test/supplement_and_radar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solo_leveling_app/core/supplement_engine.dart';
import 'package:solo_leveling_app/core/voice_coach_system.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';
import 'package:solo_leveling_app/widgets/hunter_radar_chart.dart';
import 'package:solo_leveling_app/widgets/supplement_loadout_modal.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SystemMemory.kusanilanSuplementler.clear();
    SystemMemory.suHedefiMl = 3000;
    SystemMemory.sesliKocAktif.value = true;
  });

  group('SupplementEngine & Loadout Sinerji Testleri', () {
    test('Katalogda 4 temel suplement bulunmalı', () {
      expect(SupplementEngine.katalog.length, equals(4));
      expect(SupplementEngine.katalog.any((s) => s.id == 'creatine_monohydrate'), isTrue);
      expect(SupplementEngine.katalog.any((s) => s.id == 'pre_workout_caffeine'), isTrue);
    });

    test('Kreatin kuşanıldığında su hedefine +500 ml eklenmeli', () {
      final suArtisi = SupplementEngine.hesaplaToplamSuArtisi(['creatine_monohydrate']);
      expect(suArtisi, equals(500));

      final hacimBonusu = SupplementEngine.hesaplaToplamHacimBonusu(['pre_workout_caffeine', 'creatine_monohydrate']);
      expect(hacimBonusu, equals(15.0)); // 10 + 5
    });

    test('SystemMemory suplement kuşanma ve çıkarma su hedefini dinamik güncellemeli', () {
      expect(SystemMemory.suHedefiMl, equals(3000));

      // Kreatin kuşan
      SystemMemory.suplementKusan('creatine_monohydrate');
      expect(SystemMemory.suplementKusanildiMi('creatine_monohydrate'), isTrue);
      expect(SystemMemory.suHedefiMl, equals(3500));

      // Kreatin çıkar
      SystemMemory.suplementCikar('creatine_monohydrate');
      expect(SystemMemory.suplementKusanildiMi('creatine_monohydrate'), isFalse);
      expect(SystemMemory.suHedefiMl, equals(3000));
    });

    test('Boks ve ağırlık yoğunluğuna göre akıllı öneri motoru doğru tavsiyeleri üretmeli', () {
      final oneriler = SupplementEngine.hesaplaOneriler(
        kilo: 75.0,
        haftalikBoksDakikasi: 60,
        haftalikAgirlikDakikasi: 90,
        hedef: 'Kilo Al / Hacim',
        kusanilanIdler: [],
      );

      expect(oneriler.any((o) => o.contains('ELEKTROLİT UYARISI')), isTrue);
      expect(oneriler.any((o) => o.contains('KREATİN PROTOKOLÜ')), isTrue);
      expect(oneriler.any((o) => o.contains('PROTEİN ONARIMI')), isTrue);
    });

    test('VoiceCoachSystem Testleri Sesli koç mesajları sonSesliMesaj değerini güncellemeli', () async {
      await VoiceCoachSystem.dinlenmeBasladi(60, egzersizAdi: 'Bench Press');
      expect(VoiceCoachSystem.sonSesliMesaj.value, contains('60 saniye toparlan'));

      await VoiceCoachSystem.dinlenmeGeriSayim(3);
      expect(VoiceCoachSystem.sonSesliMesaj.value, equals('Son 3...'));

      await VoiceCoachSystem.dinlenmeBitti(egzersizAdi: 'Bench Press');
      expect(VoiceCoachSystem.sonSesliMesaj.value, contains('Dinlenme süren doldu'));
    });

    test('VoiceCoachSystem Testleri Sesli koç kapatıldığında mesaj gönderilmemeli', () async {
      SystemMemory.sesliKocAktif.value = false;
      VoiceCoachSystem.sonSesliMesaj.value = null;

      await VoiceCoachSystem.dinlenmeBasladi(45);
      expect(VoiceCoachSystem.sonSesliMesaj.value, isNull);
    });
  });

  group('HunterRadarChart & UI Widget Testleri', () {
    testWidgets('HunterRadarChart statları ve sınıf etiketini çizer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HunterRadarChart(
              str: 80,
              agi: 30,
              vit: 40,
              intStat: 20,
              per: 25,
            ),
          ),
        ),
      );

      final radarTitle = TranslationManager.isTurkish ? '[ BİYOMETRİK STAT RADARI ]' : '[ BIOMETRIC STAT RADAR ]';
      final classLabel = TranslationManager.isTurkish ? 'BERSERKER / AĞIR VURUŞÇU' : 'BERSERKER / HEAVY HITTER';
      expect(find.text(radarTitle), findsOneWidget);
      expect(find.text(classLabel), findsOneWidget);
    });

    testWidgets('SupplementLoadoutModal açılır ve kuşanma butonunu tetikler', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => SupplementLoadoutModal.goster(ctx),
                child: const Text('Modal Aç'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Modal Aç'));
      await tester.pumpAndSettle();

      final titleText = TranslationManager.isTurkish ? '[ METABOLİK DONANIM ]' : '[ METABOLIC LOADOUT ]';
      expect(find.text(titleText), findsOneWidget);
      expect(find.text('Kreatin Monohidrat (Creapure)'), findsOneWidget);

      final kusanBtnText = TranslationManager.isTurkish ? 'KUŞAN' : 'EQUIP';
      final kusanBtn = find.text(kusanBtnText).first;
      await tester.tap(kusanBtn);
      await tester.pumpAndSettle();

      final kusandiText = TranslationManager.isTurkish ? '✓ KUŞANILDI' : '✓ EQUIPPED';
      expect(find.text(kusandiText), findsWidgets);
      expect(SystemMemory.kusanilanSuplementler.isNotEmpty, isTrue);

      // Modal kapat
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text(titleText), findsNothing);
    });
  });
}
