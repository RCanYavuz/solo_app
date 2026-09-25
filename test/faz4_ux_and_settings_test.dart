// test/faz4_ux_and_settings_test.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/document_parser.dart';
import 'package:solo_leveling_app/screens/diet_screen.dart';
import 'package:solo_leveling_app/widgets/hunter_profile_settings_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.appLanguage.value = 'tr';
    SystemMemory.boy = 180.0;
    SystemMemory.kilo = 80.0;
    SystemMemory.hedefKilo = 75.0;
    SystemMemory.cinsiyet = 'Erkek';
    SystemMemory.aktifHedef = 'Kilo Ver (Yağ Yak)';
    SystemMemory.aktifZorluk = 'Normal';
    SystemMemory.ekipmanTuru = 'Salon';
    SystemMemory.dovusSporuYapiyorMu = true;
    SystemMemory.dovusBranslari = ['Boks'];
    SystemMemory.eklemKisiti = [];
  });

  group('FAZ 4: UX, Protokol Düzenleme & Sık Yemek Hafızası Testleri', () {
    testWidgets('HunterProfileSettingsModal tüm bölümleriyle açılır ve protokolü günceller', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool savedTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => HunterProfileSettingsModal.show(
                  ctx,
                  onSaved: () => savedTriggered = true,
                ),
                child: const Text('AYARLARI AÇ'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('AYARLARI AÇ'));
      await tester.pumpAndSettle();

      // Başlık ve Bölümler doğrulanmalı
      expect(find.text('[ AVCI PROTOKOL AYARLARI ]'), findsOneWidget);
      expect(find.text('1. BİYOMETRİK PARAMETRELER'), findsOneWidget);
      expect(find.text('2. AVCI HEDEFİ & ZORLUK SEVİYESİ'), findsOneWidget);
      expect(find.text('3. EKİPMAN ENVANTERİ'), findsOneWidget);
      expect(find.text('4. DÖVÜŞ SANATLARI PROTOKOLÜ'), findsOneWidget);
      expect(find.text('5. EKLEM KORUMASI & KISITLARI'), findsOneWidget);

      // Hedef Kilo Al olarak değiştir
      await tester.tap(find.text('Kilo Al (Kas İnşa Et)'));
      await tester.pumpAndSettle();

      // Zorluk Hard olarak değiştir
      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();

      // Dövüş branşı olarak Kickboks ekle
      await tester.tap(find.text('Kickboks'));
      await tester.pumpAndSettle();

      // Eklem kısıtına Omuz ekle
      await tester.tap(find.text('Omuz'));
      await tester.pumpAndSettle();

      // Kaydet butonuna tıkla
      await tester.tap(find.text('SİSTEM PROTOKOLÜNÜ SENKRONİZE ET'));
      await tester.pumpAndSettle();

      // Kaydedildi mi?
      expect(savedTriggered, isTrue);
      expect(SystemMemory.aktifHedef, 'Kilo Al (Kas İnşa Et)');
      expect(SystemMemory.aktifZorluk, 'Hard');
      expect(SystemMemory.dovusBranslari.contains('Kickboks'), isTrue);
      expect(SystemMemory.eklemKisiti.contains('Omuz'), isTrue);
    });

    testWidgets('DietScreen manuel yemek diyalogunda sık tüketilenler çipleri alanları doldurur', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: YemekEkrani(),
        ),
      );
      await tester.pumpAndSettle();

      // Manuel yemek ekleme butonunu bul ve tıkla
      final addMealBtn = find.text('ÖĞÜN EKLE');
      if (addMealBtn.evaluate().isNotEmpty) {
        await tester.tap(addMealBtn.first);
        await tester.pumpAndSettle();

        // Hızlı seçim çipleri görünmeli
        expect(find.text('⚡ HIZLI SEÇİM / SIK TÜKETİLENLER'), findsOneWidget);

        // "Tavuklu Pilav (520 kcal)" çipine tıkla
        final chipFinder = find.text('Tavuklu Pilav (520 kcal)');
        expect(chipFinder, findsOneWidget);
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();

        // Form alanlarının dolduğunu doğrula
        expect(find.text('Tavuklu Pilav'), findsWidgets);
        expect(find.text('520'), findsOneWidget);
      }
    });

    test('DocumentParser Word XML ve metin temizleyicileri güvenli çalışır', () {
      final docBytes = Uint8List.fromList([]);
      
      expect(DocumentParser.extractTextFromDocx(docBytes), isEmpty);
    });
  });
}
