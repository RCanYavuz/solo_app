import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/services/notification_service.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';
import 'package:solo_leveling_app/screens/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await NotificationService.instance.init(testMode: true);
    await SystemMemory.baslat();
  });

  group('Modül 1: NotificationService & Hatırlatıcı Birim Testleri', () {
    test('NotificationService test modunda güvenle başlatılır ve izin verir', () async {
      final notif = NotificationService.instance;
      expect(notif.isTest, isTrue);

      final izin = await notif.izinIste();
      expect(izin, isTrue);
    });

    test('Anlık bildirim ve hatırlatıcı planlamaları hatasız çalışır', () async {
      final notif = NotificationService.instance;

      await expectLater(
        notif.anlikBildirimGonder(
          title: '[SİSTEM UYARISI]',
          body: 'Test Bildirimi Gönderildi',
        ),
        completes,
      );

      await expectLater(
        notif.suHatirlaticisiPlanla(intervalHours: 3),
        completes,
      );

      await expectLater(
        notif.idmanHatirlaticisiPlanla(hour: 19, minute: 30),
        completes,
      );

      await expectLater(
        notif.geceHesaplasmaHatirlaticisiPlanla(),
        completes,
      );

      await expectLater(
        notif.testBildirimiGonder(),
        completes,
      );

      await expectLater(
        notif.suHatirlaticisiIptal(),
        completes,
      );

      await expectLater(
        notif.idmanHatirlaticisiIptal(),
        completes,
      );

      await expectLater(
        notif.tumBildirimleriIptalEt(),
        completes,
      );
    });

    test('SystemMemory bildirim tercihleri ve bildirimleriSenkronizeEt düzgün çalışır', () async {
      SystemMemory.suBildirimiAktif = false;
      SystemMemory.idmanBildirimiAktif = true;
      SystemMemory.idmanBildirimSaati = 20;
      SystemMemory.idmanBildirimDakikasi = 15;
      SystemMemory.geceBildirimiAktif = true;

      await expectLater(SystemMemory.bildirimleriSenkronizeEt(), completes);

      // Tercihleri kaydet ve yeni SharedPreferences üzerinden oku
      await SystemMemory.kaydet();

      // Sıfırlayıp tekrar yükle
      SystemMemory.suBildirimiAktif = true;
      SystemMemory.idmanBildirimiAktif = false;
      SystemMemory.idmanBildirimSaati = 10;
      await SystemMemory.baslat();

      expect(SystemMemory.suBildirimiAktif, isFalse);
      expect(SystemMemory.idmanBildirimiAktif, isTrue);
      expect(SystemMemory.idmanBildirimSaati, 20);
      expect(SystemMemory.idmanBildirimDakikasi, 15);
      expect(SystemMemory.geceBildirimiAktif, isTrue);
    });
  });

  group('Modül 1: ProfileScreen Bildirim Direktifleri UI Testleri', () {
    testWidgets('ProfileScreen içinde SYSTEM DIRECTIVES kartı görüntülenir ve etkileşim sağlanır',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SystemMemory.appLanguage.value = 'tr';
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // SYSTEM DIRECTIVES kartı arayüzde bulunmalı
      final directivesFinder = find.text(TranslationManager.get('profile_system_directives'));
      expect(directivesFinder, findsOneWidget);

      // Hidrasyon ve Zindan çağrısı switchleri bulunmalı
      expect(find.text('Hidrasyon Protokolü (Su)'), findsOneWidget);
      expect(find.text('Zindan Çağrısı (İdman)'), findsOneWidget);
      expect(find.text('Gece Hesaplaşması Uyarısı'), findsOneWidget);

      // Test bildirimi tetikleme butonu bulunmalı ve tıklanabilmeli
      final testBtnFinder = find.text('TEST BİLDİRİMİ TETİKLE');
      expect(testBtnFinder, findsOneWidget);

      await tester.ensureVisible(testBtnFinder);
      await tester.tap(testBtnFinder);
      await tester.pump();

      // SnackBar görünürlüğü kontrolü
      expect(find.text('SYSTEM: Test bildirimi gönderildi!'), findsOneWidget);
    });
  });
}
