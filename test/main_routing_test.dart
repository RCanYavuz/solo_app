import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/main.dart';
import 'package:solo_leveling_app/screens/setup_screen.dart';
import 'package:solo_leveling_app/screens/ana_ekran.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Başlangıç Yönlendirme (Startup Routing) Testleri', () {
    testWidgets('Kayıt yoksa (yeni kullanıcı) SetupScreen açılmalı', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await SystemMemory.baslat();

      expect(SystemMemory.kayitBulundu, isFalse);

      await tester.pumpWidget(const SoloApp());
      await tester.pump();

      expect(find.byType(SetupScreen), findsOneWidget);
      expect(find.byType(AnaEkran), findsNothing);
    });

    testWidgets('Kayıt varsa (mevcut kullanıcı) doğrudan AnaEkran açılmalı', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'level': 5,
        'oyuncuIsmi': 'JINWOO',
        'hp': 100,
        'mp': 20,
      });
      await SystemMemory.baslat();

      expect(SystemMemory.kayitBulundu, isTrue);

      await tester.pumpWidget(const SoloApp());
      await tester.pump();

      expect(find.byType(AnaEkran), findsOneWidget);
      expect(find.byType(SetupScreen), findsNothing);
    });
  });
}
