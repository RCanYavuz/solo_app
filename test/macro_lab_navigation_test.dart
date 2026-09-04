import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/screens/diet_screen.dart';
import 'package:solo_leveling_app/screens/macro_dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'level': 1,
      'gunlukHedefKalori': 2000,
      'bugunAlinanKalori': 500,
    });
    await SystemMemory.baslat();
  });

  group('Makro Laboratuvarı Navigasyon ve Diyet Ekranı Testleri', () {
    testWidgets('YemekEkrani üzerinden Makro Laboratuvarına geçiş yapılabilmeli', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: YemekEkrani(),
        ),
      );
      await tester.pumpAndSettle();

      final macroButton = find.byTooltip('Macro Lab');
      expect(macroButton, findsOneWidget);

      await tester.tap(macroButton);
      await tester.pumpAndSettle();

      expect(find.byType(MacroDashboardScreen), findsOneWidget);
    });

    testWidgets('Geçersiz kalori girdisi uygulamanın çökmesine yol açmamalı', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: YemekEkrani(),
        ),
      );
      await tester.pumpAndSettle();

      final addItemBtn = find.text('ADD ITEM');
      expect(addItemBtn, findsOneWidget);

      await tester.tap(addItemBtn);
      await tester.pumpAndSettle();

      // İsim gir ama kaloriye geçersiz harf/boşluk gir
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Elma');
      await tester.enterText(textFields.last, 'invalid_number');

      final dialogAddBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'ADD ITEM'),
      );
      await tester.tap(dialogAddBtn);
      await tester.pumpAndSettle();

      // Çökmeden hata uyarısı göstermeli
      expect(find.text('SYSTEM WARNING: Enter valid item name and calorie amount!'), findsOneWidget);
    });
  });
}
