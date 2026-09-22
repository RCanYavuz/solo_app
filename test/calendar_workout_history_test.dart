import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';
import 'package:solo_leveling_app/screens/calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
  });

  group('Modül 3: CalendarScreen İdman Geçmişi ve Rapor Testleri', () {
    testWidgets('Takvimde yapılan idmanlar listelenir ve tıklandığında Dungeon Raid Report modalı açılır',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      SystemMemory.idmanGecmisi = [
        {
          'tarih': now.toIso8601String(),
          'dakika': 40,
          'gorevSayisi': 5,
        }
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Takvimde zindan akını listelenmeli
      expect(find.text(TranslationManager.get('calendar_dungeon_logs')), findsOneWidget);
      expect(find.textContaining('40'), findsWidgets);

      // İdman kaydına tıkla
      final raidItem = find.textContaining('40').first;
      await tester.tap(raidItem);
      await tester.pumpAndSettle();

      // Modal pencerenin açıldığını doğrula
      expect(find.text('[ DUNGEON RAID REPORT ]'), findsOneWidget);
      expect(find.text('40 DK'), findsOneWidget);
      expect(find.text('+600 EXP'), findsOneWidget);
      expect(find.text('~280 KCAL'), findsOneWidget);

      // Kapat butonuna bas
      final closeBtn = find.text('KAPAT');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('[ DUNGEON RAID REPORT ]'), findsNothing);
    });
  });
}
