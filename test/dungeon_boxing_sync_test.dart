// test/dungeon_boxing_sync_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/task_model.dart';
import 'package:solo_leveling_app/screens/active_workout_screen.dart';
import 'package:solo_leveling_app/screens/boxing_timer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    final bugun = DateTime.now().weekday;
    SystemMemory.haftalikPlan[bugun] = [
      Gorev('[COMBAT] Shadow Boxing (5x3dk)', false, 'Fiziksel'),
    ];
  });

  testWidgets('ActiveWorkoutScreen içinden BoxingTimerScreen açıldığında HUD görünür, sayaclar senkron akar ve zindan erken kapanmaz', (tester) async {
    DateTime sahteSaat = DateTime(2026, 9, 21, 10, 0, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: ActiveWorkoutScreen(
          nowProvider: () => sahteSaat,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('ACTIVE RAID'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    // Saati 10 saniye ileri alalım ve frame tetikleyelim
    sahteSaat = sahteSaat.add(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:10'), findsOneWidget);

    // Boks butonuna bas (Combat Sim)
    final boksButon = find.byTooltip('Combat Sim');
    expect(boksButon, findsOneWidget);
    await tester.tap(boksButon);
    await tester.pumpAndSettle();

    // BoxingTimerScreen ekranındayız
    expect(find.byType(BoxingTimerScreen), findsOneWidget);

    // Zindan Canlı HUD banner'ı görünmeli ve zindanda geçen süreyi göstermeli
    expect(find.text('⚔️ ACTIVE RAID IN PROGRESS'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);

    // Boks ekranında 15 saniye antrenman yapılsın
    sahteSaat = sahteSaat.add(const Duration(seconds: 15));
    await tester.pump(const Duration(seconds: 1));

    // Zindan sayacı boks ekranında da 00:25'e çıkmış olmalı!
    expect(find.text('00:25'), findsOneWidget);

    // Boks ekranından zindana geri dön
    final backBtn = find.byType(BackButton);
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn);
    } else {
      Navigator.of(tester.element(find.byType(BoxingTimerScreen))).pop();
    }
    await tester.pumpAndSettle();

    // Tekrar ActiveWorkoutScreen üzerindeyiz
    expect(find.text('ACTIVE RAID'), findsOneWidget);
    // Zindan sayacı kesinlikle 00:25 olmalı!
    expect(find.text('00:25'), findsOneWidget);
  });

  testWidgets('BoxingTimerScreen içinde antrenman tamamlandığında zindan kapatılmaz, raid HUD ile zindana dönüş sağlanır', (tester) async {
    DateTime sahteSaat = DateTime(2026, 9, 21, 10, 0, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: ActiveWorkoutScreen(
          nowProvider: () => sahteSaat,
        ),
      ),
    );
    await tester.pump();

    // Boks butonuna bas (Combat Sim)
    await tester.tap(find.byTooltip('Combat Sim'));
    await tester.pumpAndSettle();

    // BoxingTimerScreen ekranındayız
    expect(find.byType(BoxingTimerScreen), findsOneWidget);

    // Boks antrenmanını bitir dialogunu tetiklemek için start/pause butonuna veya timer bitişine bakalım
    // Free settings modunda START / PAUSE yapalım
    final startBtn = find.text('START');
    if (startBtn.evaluate().isNotEmpty) {
      await tester.tap(startBtn);
      await tester.pump();
    }

    // State üzerinden antrenmaniBitir tetikleyelim
    final state = tester.state(find.byType(BoxingTimerScreen)) as dynamic;
    state.antrenmaniBitir();
    await tester.pumpAndSettle();

    // COMBAT PROTOCOL COMPLETE başlığı çıkmalı (Zindanı yok etmeyen diyalog)
    expect(find.text('[ COMBAT PROTOCOL COMPLETE ]'), findsOneWidget);
    expect(find.text('RETURN TO ACTIVE RAID'), findsOneWidget);

    // Butona basıldığında diyaloğu ve boks ekranını kapatıp zindana döner
    await tester.tap(find.text('RETURN TO ACTIVE RAID'));
    await tester.pumpAndSettle();

    // Zindan hala açık olmalı!
    expect(find.text('ACTIVE RAID'), findsOneWidget);
  });
}
