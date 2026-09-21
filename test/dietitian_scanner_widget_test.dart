// test/dietitian_scanner_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/widgets/dietitian_scanner_modal.dart';
import 'package:solo_leveling_app/screens/macro_dashboard_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SystemMemory.boy = 180;
    SystemMemory.kilo = 80;
    SystemMemory.belCm = 84;
    SystemMemory.cinsiyet = 'erkek';
    SystemMemory.diyetisyenListesiAktif = false;
  });

  testWidgets('DietitianScannerModal render olur ve girdi alanları mevcuttur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DietitianScannerModal(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DİYETİSYEN MENÜ ENTEGRASYONU'), findsOneWidget);
    expect(find.text('DİYETİSYEN PLANI: [DEVRE DIŞI]'), findsOneWidget);
    expect(find.text('KAMERAYLA ÇEK'), findsOneWidget);
    expect(find.text('GALERİDEN SEÇ'), findsOneWidget);
    expect(find.text('DİYETİSYEN HEDEFLERİNİ ONAYLA'), findsOneWidget);
  });

  testWidgets('MacroDashboardScreen biyometrik US Navy kartı ve sliderları gösterir', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MacroDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('🧬 AVCI METABOLİK RAPORU (US NAVY)'), findsOneWidget);
    expect(find.text('YAĞ ORANI'), findsOneWidget);
    expect(find.text('YAĞSIZ KÜTLE (LBM)'), findsOneWidget);
    expect(find.text('BOY'), findsOneWidget);
    expect(find.text('BEL ÇEVRESİ'), findsOneWidget);
  });
}
