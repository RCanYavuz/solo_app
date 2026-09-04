import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/task_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Setup test weekly plan
    SystemMemory.haftalikPlan.clear();
    for (int i = 1; i <= 7; i++) {
      SystemMemory.haftalikPlan[i] = [
        Gorev('Quest Day $i', true, 'Fiziksel'),
      ];
    }
    SystemMemory.gunlukHedefKalori = 2000;
    SystemMemory.bugunAlinanKalori = 1800;
    SystemMemory.uyunanSaat = 8;
  });

  test('gunSonuHesaplasmasi only resets the evaluated day, not all 7 days', () {
    // Before reset, all days are yapildiMi == true
    for (int i = 1; i <= 7; i++) {
      expect(SystemMemory.haftalikPlan[i]!.first.yapildiMi, isTrue);
    }

    // Evaluate Tuesday (day 2)
    SystemMemory.gunSonuHesaplasmasi(2);

    // Only day 2 should be reset to false!
    expect(SystemMemory.haftalikPlan[2]!.first.yapildiMi, isFalse,
        reason: 'Evaluated day quests should be reset');

    // All other days (1, 3, 4, 5, 6, 7) must remain true!
    for (int i = 1; i <= 7; i++) {
      if (i == 2) continue;
      expect(SystemMemory.haftalikPlan[i]!.first.yapildiMi, isTrue,
          reason: 'Non-evaluated day $i must not be reset');
    }
  });

  test('geminiActiveModel can be updated and retrieved from SystemMemory', () {
    expect(SystemMemory.geminiActiveModel, 'gemini-1.5-flash');
    SystemMemory.geminiActiveModel = 'gemini-2.0-flash';
    expect(SystemMemory.geminiActiveModel, 'gemini-2.0-flash');
  });
}
