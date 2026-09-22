// test/assessment_flow_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/screens/profile_screen.dart';
import 'package:solo_leveling_app/screens/dashboard_screen.dart';
import 'package:solo_leveling_app/screens/setup_screen.dart';
import 'package:solo_leveling_app/widgets/awakening_test_dialog.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SystemMemory.hunterRank = "Unranked";
    SystemMemory.kilo = 75.0;
    SystemMemory.boy = 178.0;
    SystemMemory.ekipmanTuru = "Salon";
    SystemMemory.antrenmanGecmisi = "Başlangıç";
    SystemMemory.eklemKisiti = [];
    SystemMemory.sonTesttenBeriIdmanSayisi = 0;
    SystemMemory.dovusSporuYapiyorMu = false;
    SystemMemory.dovusBransi = "Boks";
    SystemMemory.gogusCm = 0.0;
    SystemMemory.belCm = 0.0;
    SystemMemory.kolCm = 0.0;
    SystemMemory.bacakCm = 0.0;
    SystemMemory.haftalikPlan = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: []};
  });

  group('Assessment & Retest UI Widget & Flow Tests', () {
    testWidgets('AwakeningTestDialog renders, accepts 1RM inputs and computes Projected Rank', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAwakeningTestDialog(context),
                child: const Text('OPEN DIALOG'),
              ),
            ),
          ),
        ),
      );

      // Tap button to open dialog
      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      // Verify dialog title & inputs exist
      expect(find.text('AWAKENING & RANK TEST'), findsOneWidget);
      expect(find.text('BARBELL / DB 1RM'), findsOneWidget);
      expect(find.text('CALISTHENICS REPS'), findsOneWidget);
      expect(find.text('COMBAT STAMINA'), findsOneWidget);

      // Enter 1RM values (Bench: 90, Squat: 120, Deadlift: 150 = 360 kg / 75 = 4.8x BW -> S-Rank)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      await tester.enterText(textFields.at(0), '90');
      await tester.enterText(textFields.at(1), '120');
      await tester.enterText(textFields.at(2), '150');
      await tester.pumpAndSettle();

      // Verify dynamic calculation
      expect(find.text('360.0 kg'), findsOneWidget);
      expect(find.text('4.80x BW'), findsOneWidget);
      expect(find.text('A-Rank (National)'), findsOneWidget);

      // Submit data
      await tester.tap(find.text('SUBMIT DATA'));
      await tester.pumpAndSettle();

      // Check registration reward modal appeared
      expect(find.text('[ AWAKENING REGISTERED ]'), findsOneWidget);
      expect(find.text('+100 EXP  |  +3 AP (Awakening Reward)'), findsOneWidget);

      // Verify SystemMemory state updated
      expect(SystemMemory.hunterRank, 'A-Rank (National)');
      expect(SystemMemory.maxBench, 90.0);
      expect(SystemMemory.maxSquat, 120.0);
      expect(SystemMemory.maxDeadlift, 150.0);
      expect(SystemMemory.sonTesttenBeriIdmanSayisi, 0);

      // Close modal
      await tester.tap(find.text('SYSTEM ACKNOWLEDGE'));
      await tester.pumpAndSettle();
      expect(find.text('[ AWAKENING REGISTERED ]'), findsNothing);
    });

    testWidgets('AwakeningTestDialog switches to Calisthenics Reps mode properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAwakeningTestDialog(context),
                child: const Text('OPEN DIALOG'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      // Switch to Calisthenics mode
      await tester.tap(find.text('CALISTHENICS REPS'));
      await tester.pumpAndSettle();

      // Verify rep input fields exist
      expect(find.text('Max Push-ups (Reps to failure)'), findsOneWidget);
      expect(find.text('Max Air Squats (Reps to failure)'), findsOneWidget);
      expect(find.text('Max Pull-ups (Reps to failure)'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '30'); // 30 pushups
      await tester.enterText(textFields.at(1), '50'); // 50 squats
      await tester.enterText(textFields.at(2), '15'); // 15 pullups
      await tester.pumpAndSettle();

      // Check that rank calculated without crashing
      expect(find.byType(ElevatedButton), findsWidgets);
      await tester.tap(find.text('SUBMIT DATA'));
      await tester.pumpAndSettle();

      expect(SystemMemory.hunterRank != "Unranked", isTrue);
    });

    testWidgets('AwakeningTestDialog switches to Combat Stamina mode and updates Combat Rank', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAwakeningTestDialog(context),
                child: const Text('OPEN DIALOG'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      // Switch to Combat Stamina mode
      await tester.tap(find.text('COMBAT STAMINA'));
      await tester.pumpAndSettle();

      // Verify combat inputs exist
      expect(find.text('Patlayıcı Şınav (Plyo Push-ups - Reps)'), findsOneWidget);
      expect(find.text('3 Dk Burpee (Raund Kondisyonu)'), findsOneWidget);
      expect(find.text('Max Plank (Saniye)'), findsOneWidget);
      expect(find.text('Max Barfiks (Pull-up Reps)'), findsOneWidget);

      // Enter combat metrics (30 plyo pushups, 40 burpees, 90s plank, 18 pullups)
      // Score: 30*2 + 40*3 + (9*2) + 18*4 = 60 + 120 + 18 + 72 = 270 -> S-Rank (Monarch)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(7)); // 4 combat stamina + 3 1RM strength

      await tester.enterText(textFields.at(0), '30');
      await tester.enterText(textFields.at(1), '40');
      await tester.enterText(textFields.at(2), '90');
      await tester.enterText(textFields.at(3), '18');

      // Also enter 1RM weights (Bench: 80, Squat: 100, Deadlift: 120 = 300 kg)
      await tester.enterText(textFields.at(4), '80');
      await tester.enterText(textFields.at(5), '100');
      await tester.enterText(textFields.at(6), '120');
      await tester.pumpAndSettle();

      expect(find.text('270.0 pts'), findsOneWidget);
      expect(find.text('300 kg (4.00x BW)'), findsOneWidget);
      expect(find.text('S-Rank (Monarch)'), findsOneWidget);

      await tester.tap(find.text('SUBMIT DATA'));
      await tester.pumpAndSettle();

      expect(SystemMemory.dovusSporuYapiyorMu, isTrue);
      expect(SystemMemory.hunterRank, 'S-Rank (Monarch)');
      expect(SystemMemory.maxPatlayiciSinav, 30);
      expect(SystemMemory.maxBurpeeKondisyon, 40);
      expect(SystemMemory.maxBench, 80.0);
      expect(SystemMemory.maxSquat, 100.0);
      expect(SystemMemory.maxDeadlift, 120.0);
    });

    testWidgets('TranslationManager.rankTitle stays synchronized with C-Rank and combat titles', (WidgetTester tester) async {
      // Normal athlete with C-Rank
      SystemMemory.hunterRank = "C-Rank (Knight)";
      SystemMemory.dovusSporuYapiyorMu = false;

      String titleNormal = TranslationManager.rankTitle(1, SystemMemory.hunterRank, SystemMemory.dovusSporuYapiyorMu);
      expect(titleNormal, contains('Knight Hunter (C-Rank)'));
      expect(titleNormal, isNot(contains('E-Rank')));

      // Combat athlete with C-Rank
      SystemMemory.dovusSporuYapiyorMu = true;
      String titleCombat = TranslationManager.rankTitle(1, SystemMemory.hunterRank, SystemMemory.dovusSporuYapiyorMu);
      expect(titleCombat, contains('Iron Fist Striker (C-Rank)'));
      expect(titleCombat, isNot(contains('E-Rank')));
    });

    testWidgets('ProfileScreen displays Rank, Equipment and Retest Progress', (WidgetTester tester) async {
      SystemMemory.hunterRank = "E-Rank (Rookie)";
      SystemMemory.sonTesttenBeriIdmanSayisi = 5; // 5 out of 8

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Rank and Equipment mode
      expect(find.text('E-Rank (Rookie)'), findsWidgets);
      expect(find.text('Equipment Mode:'), findsOneWidget);
      expect(find.text('Gym (Salon)'), findsOneWidget);
      expect(find.text('Next Rank Trial Progress:'), findsOneWidget);
      expect(find.text('5 / 8 Raids'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify button triggers dialog
      final testBtn = find.text('TAKE AWAKENING TEST');
      expect(testBtn, findsOneWidget);
      await tester.ensureVisible(testBtn);
      await tester.tap(testBtn);
      await tester.pumpAndSettle();

      expect(find.text('AWAKENING & RANK TEST'), findsOneWidget);
    });

    testWidgets('DashboardScreen displays Promotion Trial Banner when quota reached', (WidgetTester tester) async {
      SystemMemory.hunterRank = "E-Rank (Rookie)";
      SystemMemory.sonTesttenBeriIdmanSayisi = 8; // 8 / 8 -> quota fulfilled!

      expect(SystemMemory.retestGerekiyorMu, isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the glowing banner appears on dashboard
      expect(find.text('[ ⚔️ RANK PROMOTION TRIAL READY ]'), findsOneWidget);
      expect(find.text('ENTER PROMOTION TRIAL NOW'), findsOneWidget);

      // Tap trial button
      await tester.tap(find.text('ENTER PROMOTION TRIAL NOW'));
      await tester.pumpAndSettle();

      // Verify it opens Awakening dialog
      expect(find.text('AWAKENING & RANK TEST'), findsOneWidget);
    });

    testWidgets('SetupScreen 4-step wizard functions smoothly from Step 0 to Step 3', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 0: Identity
      expect(find.text('PHASE 01: IDENTITY'), findsOneWidget);
      expect(find.text('1 / 4'), findsOneWidget);
      expect(find.text('Birth Date *'), findsOneWidget);

      // Set birth date via date picker or tap
      await tester.tap(find.text('Birth Date *'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Proceed to Step 1
      await tester.tap(find.text('NEXT PHASE ->'));
      await tester.pumpAndSettle();

      // Step 1: Body Calibration
      expect(find.text('PHASE 02: BODY CALIBRATION'), findsOneWidget);
      expect(find.text('2 / 4'), findsOneWidget);
      expect(find.text('BODY SCAN MEASUREMENTS (cm - Optional)'), findsOneWidget);

      // Enter Height & Weight
      final heightField = find.widgetWithText(TextField, 'Height (cm) *');
      final weightField = find.widgetWithText(TextField, 'Weight (kg) *');
      await tester.enterText(heightField, '180');
      await tester.enterText(weightField, '78');

      // Enter body measurements
      final chestField = find.widgetWithText(TextField, 'Göğüs / Chest (cm)');
      final waistField = find.widgetWithText(TextField, 'Bel / Waist (cm)');
      await tester.enterText(chestField, '102');
      await tester.enterText(waistField, '82');
      await tester.pumpAndSettle();

      // Proceed to Step 2
      await tester.ensureVisible(find.text('NEXT PHASE ->'));
      await tester.tap(find.text('NEXT PHASE ->'));
      await tester.pumpAndSettle();

      // Step 2: Combat & Gear
      expect(find.text('PHASE 03: COMBAT & GEAR'), findsOneWidget);
      expect(find.text('3 / 4'), findsOneWidget);
      expect(find.text('DÖVÜŞ SPORLARI / BOKS'), findsOneWidget);

      // Toggle combat on
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Uğraştığınız Branşlar (Birden fazla seçebilirsiniz):'), findsOneWidget);
      expect(find.text('Boks'), findsOneWidget);
      expect(find.text('Kickboks'), findsOneWidget);
      expect(find.text('MMA'), findsOneWidget);

      // Select Kickboks as well
      await tester.tap(find.text('Kickboks'));
      await tester.pumpAndSettle();

      // Verify Target Focus Zones exist and select 'Karın & Göbek' and 'Göğüs'
      final focusTitle = find.text('ÖNCELİKLİ ODAK & YAĞ YAKIM BÖLGELERİ');
      await tester.ensureVisible(focusTitle);
      expect(focusTitle, findsOneWidget);

      final karinChip = find.text('Karın & Göbek');
      await tester.ensureVisible(karinChip);
      await tester.tap(karinChip);

      final gogusChip = find.text('Göğüs');
      await tester.ensureVisible(gogusChip);
      await tester.tap(gogusChip);
      await tester.pumpAndSettle();

      // Verify Joint Sensitivities exist
      final jointTitle = find.text('EKLEM HASSASİYETLERİ & SAKATLIK KORUMASI');
      await tester.ensureVisible(jointTitle);
      expect(jointTitle, findsOneWidget);
      expect(find.text('Omuz (Shoulder)'), findsOneWidget);
      expect(find.text('Diz (Knee)'), findsOneWidget);
      expect(find.text('Bel (Lower Back)'), findsOneWidget);

      // Proceed to Step 3
      final nextBtn = find.text('NEXT PHASE ->');
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Step 3: Awakening Test
      expect(find.text('PHASE 04: AWAKENING TEST'), findsOneWidget);
      expect(find.text('4 / 4'), findsOneWidget);
      expect(find.text('COMBAT STAMINA & POWER TEST'), findsOneWidget);
      expect(find.text('DÖVÜŞ KUVVET & AĞIRLIK TESTİ (1RM - OPSİYONEL)'), findsOneWidget);
      expect(find.text('AWAKEN THE SYSTEM'), findsOneWidget);
    });
  });
}
