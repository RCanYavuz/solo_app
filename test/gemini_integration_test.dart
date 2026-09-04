import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/screens/profile_screen.dart';
import 'package:solo_leveling_app/screens/diet_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SystemMemory.oyuncuIsmi = "Sung Jin-Woo";
    SystemMemory.geminiApiKey = "";
    SystemMemory.geminiActiveModel = "gemini-1.5-flash";
    SystemMemory.gunlukHedefKalori = 2500;
    SystemMemory.bugunAlinanKalori = 0;
    SystemMemory.bugununYemekleri.clear();
  });

  group('Gemini Profile and Diet Integration Tests', () {
    testWidgets('ProfileScreen renders AI Core card and allows updating API Key', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AI CORE HologramCard exists
      expect(find.text('AI CORE / GEMINI'), findsOneWidget);
      expect(find.text('NO KEY'), findsOneWidget);
      expect(find.text('SET KEY'), findsOneWidget);
      expect(find.text('DIAGNOSTIC'), findsOneWidget);

      // Tap 'SET KEY'
      await tester.tap(find.text('SET KEY'));
      await tester.pumpAndSettle();

      // Verify Dialog
      expect(find.text('GEMINI CORE PROTOCOL'), findsOneWidget);
      expect(find.text('SAVE KEY'), findsOneWidget);

      // Enter API key
      final keyField = find.byType(TextField).first;
      await tester.enterText(keyField, 'AIzaSyFakeKeyForTest123');
      await tester.pumpAndSettle();

      // Tap 'SAVE KEY'
      await tester.tap(find.text('SAVE KEY'));
      await tester.pumpAndSettle();

      // Verify SystemMemory got updated
      expect(SystemMemory.geminiApiKey, 'AIzaSyFakeKeyForTest123');
      expect(find.text('CONFIGURED'), findsOneWidget);
    });

    testWidgets('DietScreen Add Item dialog shows AI Decoder and warns when key missing', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: YemekEkrani(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the FAB / Add Item button
      final addFab = find.byIcon(Icons.add);
      expect(addFab, findsOneWidget);
      await tester.tap(addFab);
      await tester.pumpAndSettle();

      // Verify dialog and AI decoder are visible
      expect(find.text('ADD INVENTORY ITEM'), findsOneWidget);
      expect(find.text('AI DECODER (GEMINI)'), findsOneWidget);
      expect(find.text('DECODE WITH AI'), findsOneWidget);

      // Tap Decode without text
      await tester.tap(find.text('DECODE WITH AI'));
      await tester.pumpAndSettle();
      expect(find.text('Enter meal description first.'), findsOneWidget);

      // Enter text when key is empty
      final aiField = find.widgetWithText(TextField, 'e.g. 2 eggs, 1 slice bread, 50g cheese');
      await tester.enterText(aiField, '2 eggs');
      await tester.pumpAndSettle();

      await tester.tap(find.text('DECODE WITH AI'));
      await tester.pumpAndSettle();
      expect(find.text('API Key missing. Configure in Profile.'), findsOneWidget);
    });
  });
}
