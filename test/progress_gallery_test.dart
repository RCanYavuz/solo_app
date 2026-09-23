import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';
import 'package:solo_leveling_app/widgets/progress_gallery_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 1x1 Transparent PNG
  final Uint8List dummyImageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.ilerlemeFotolari = [];
  });

  group('Modül 5: İlerleme Fotoğrafları & Transformation Vault Testleri', () {
    test('SystemMemory ilerleme fotoğrafları ekleme, silme ve kalıcı kaydetme çalışır', () async {
      expect(SystemMemory.ilerlemeFotolari.isEmpty, isTrue);

      await SystemMemory.ilerlemeFotoEkle(
        fotoBytes: dummyImageBytes,
        kilo: 75.0,
        not: 'İlk Kayıt',
        tarih: DateTime(2026, 1, 1),
      );

      await SystemMemory.ilerlemeFotoEkle(
        fotoBytes: dummyImageBytes,
        kilo: 78.5,
        not: 'Kas Artışı',
        tarih: DateTime(2026, 3, 1),
      );

      expect(SystemMemory.ilerlemeFotolari.length, 2);
      expect(SystemMemory.ilerlemeFotolari.first['kilo'], 75.0);
      expect(SystemMemory.ilerlemeFotolari.last['kilo'], 78.5);

      // SharedPreferences testi
      await SystemMemory.kaydet();
      SystemMemory.ilerlemeFotolari = [];
      await SystemMemory.baslat();

      expect(SystemMemory.ilerlemeFotolari.length, 2);

      // Silme testi
      await SystemMemory.ilerlemeFotoSil(0);
      expect(SystemMemory.ilerlemeFotolari.length, 1);
      expect(SystemMemory.ilerlemeFotolari.first['kilo'], 78.5);
    });

    testWidgets('ProgressGalleryModal Timeline ve Before/After sekmeleri doğru render edilir',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 2 adet giriş ekle
      await SystemMemory.ilerlemeFotoEkle(
        fotoBytes: dummyImageBytes,
        kilo: 70.0,
        not: 'Başlangıç formu',
        tarih: DateTime(2026, 1, 1),
      );

      await SystemMemory.ilerlemeFotoEkle(
        fotoBytes: dummyImageBytes,
        kilo: 74.0,
        not: 'Hacimlenme dönemi',
        tarih: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressGalleryModal(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Başlık görünmeli
      expect(find.text('TRANSFORMATION VAULT'), findsOneWidget);

      // Timeline sekmesi içeriği
      expect(find.text('70.0 KG'), findsOneWidget);
      expect(find.text('74.0 KG'), findsOneWidget);
      expect(find.text('Başlangıç formu'), findsOneWidget);

      // Before & After sekmesine geç
      final beforeAfterTab = find.text('BEFORE & AFTER');
      expect(beforeAfterTab, findsOneWidget);
      await tester.tap(beforeAfterTab);
      await tester.pumpAndSettle();

      // Karşılaştırma çubuğu değerleri
      final initialLabel = TranslationManager.isTurkish ? 'BAŞLANGIÇ' : 'INITIAL';
      final currentLabel = TranslationManager.isTurkish ? 'GÜNCEL' : 'CURRENT';
      expect(find.text(initialLabel), findsOneWidget);
      expect(find.text('70.0 KG'), findsWidgets);
      expect(find.text(currentLabel), findsOneWidget);
      expect(find.text('74.0 KG'), findsWidgets);
      expect(find.text('+4.0 KG'), findsOneWidget);
    });
  });
}
