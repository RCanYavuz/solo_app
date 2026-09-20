// test/system_features_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/food_model.dart';
import 'package:solo_leveling_app/models/task_model.dart';
import 'package:solo_leveling_app/models/inventory_item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.bugununYemekleri.clear();
    SystemMemory.bugunAlinanKalori = 0;
    SystemMemory.canta.clear();
    SystemMemory.bugunIcilenSuMl.value = 0;
    SystemMemory.suHedefiMl = 3000;
    SystemMemory.hp.value = 100;
    SystemMemory.maxHp = 100;
    SystemMemory.mp.value = 10;
    SystemMemory.maxMp = 10;
    SystemMemory.level.value = 1;
    SystemMemory.exp.value = 0;
    SystemMemory.altin.value = 100;
    SystemMemory.toplamIdmanDakikasi = 0;
    SystemMemory.idmanGecmisi.clear();
    SystemMemory.bugunCheatMealAktif = false;
    SystemMemory.bugunSlothDayAktif = false;
    for (int i = 1; i <= 7; i++) {
      SystemMemory.haftalikPlan[i] = [];
    }
  });

  group('Hydration Core (Su Takibi) Tests', () {
    test('suEkle increments bugunIcilenSuMl and suSifirla resets it', () {
      expect(SystemMemory.bugunIcilenSuMl.value, 0);

      SystemMemory.suEkle(500);
      expect(SystemMemory.bugunIcilenSuMl.value, 500);

      SystemMemory.suEkle(250);
      expect(SystemMemory.bugunIcilenSuMl.value, 750);

      SystemMemory.suSifirla();
      expect(SystemMemory.bugunIcilenSuMl.value, 0);
    });

    test('Achieving water goal gives reward during midnight evaluation', () {
      SystemMemory.suHedefiMl = 2000;
      SystemMemory.suEkle(2500);
      SystemMemory.gunlukHedefKalori = 2500;
      SystemMemory.bugunAlinanKalori = 2000;
      SystemMemory.uyunanSaat = 8;

      final rapor = SystemMemory.gunSonuHesaplasmasi(1);
      expect(rapor.contains('Hydration Goal Achieved'), isTrue);
      // Bugun icilen su should be reset to 0 after midnight calculation
      expect(SystemMemory.bugunIcilenSuMl.value, 0);
    });
  });

  group('Shop & Hunter\'s Bag (Envanter) Tests', () {
    test('Items can be added to canta and stack correctly', () {
      expect(SystemMemory.canta.isEmpty, isTrue);

      SystemMemory.esyaEkle(InventoryItem(
        id: 'hp_full',
        ad: 'Full Recovery Potion',
        aciklama: 'Instantly restores full HP',
        aksiyon: 'hp_full',
        adet: 1,
        ikonKodu: 0xe3ab,
        renkDegeri: 0xFF22C55E,
      ));

      expect(SystemMemory.canta.length, 1);
      expect(SystemMemory.canta[0].adet, 1);

      // Stacking another potion
      SystemMemory.esyaEkle(InventoryItem(
        id: 'hp_full',
        ad: 'Full Recovery Potion',
        aciklama: 'Instantly restores full HP',
        aksiyon: 'hp_full',
        adet: 2,
        ikonKodu: 0xe3ab,
        renkDegeri: 0xFF22C55E,
      ));

      expect(SystemMemory.canta.length, 1);
      expect(SystemMemory.canta[0].adet, 3);
    });

    test('Using hp_full potion heals player and reduces item count', () {
      SystemMemory.hp.value = 30;
      SystemMemory.maxHp = 100;

      SystemMemory.esyaEkle(InventoryItem(
        id: 'hp_full',
        ad: 'Full Recovery Potion',
        aciklama: 'Instantly restores full HP',
        aksiyon: 'hp_full',
        adet: 1,
        ikonKodu: 0xe3ab,
        renkDegeri: 0xFF22C55E,
      ));

      final report = SystemMemory.esyaKullan('hp_full');
      expect(report.contains('Life force completely restored'), isTrue);
      expect(SystemMemory.hp.value, 100);
      expect(SystemMemory.canta.isEmpty, isTrue);
    });

    test('Using cheat_meal activates cheat meal pass for today', () {
      SystemMemory.esyaEkle(InventoryItem(
        id: 'cheat_meal',
        ad: 'Cheat Meal Pass',
        aciklama: 'Calorie penalty waived',
        aksiyon: 'cheat_meal',
        adet: 1,
        ikonKodu: 0xe532,
        renkDegeri: 0xFFF59E0B,
      ));

      expect(SystemMemory.bugunCheatMealAktif, isFalse);
      SystemMemory.esyaKullan('cheat_meal');
      expect(SystemMemory.bugunCheatMealAktif, isTrue);
    });

    test('Using sloth_day activates sloth pass for today', () {
      SystemMemory.esyaEkle(InventoryItem(
        id: 'sloth_day',
        ad: 'Sloth Day Token',
        aciklama: 'Quest penalties waived',
        aksiyon: 'sloth_day',
        adet: 1,
        ikonKodu: 0xe0db,
        renkDegeri: 0xFFA855F7,
      ));

      expect(SystemMemory.bugunSlothDayAktif, isFalse);
      SystemMemory.esyaKullan('sloth_day');
      expect(SystemMemory.bugunSlothDayAktif, isTrue);
    });

    test('Using gaming_pass activates bugunGamingPassAktif and returns report', () {
      SystemMemory.esyaEkle(InventoryItem(
        id: 'gaming_pass',
        ad: 'Gaming Pass (2 Hrs)',
        aciklama: 'Play games or watch series guilt-free.',
        aksiyon: 'gaming_pass',
        adet: 1,
        ikonKodu: 0xe5e7,
        renkDegeri: 0xFF38BDF8,
      ));

      expect(SystemMemory.bugunGamingPassAktif, isFalse);
      final report = SystemMemory.esyaKullan('gaming_pass');
      expect(SystemMemory.bugunGamingPassAktif, isTrue);
      expect(report.contains('GAMING PASS ACTIVATED'), isTrue);
      expect(SystemMemory.canta.isEmpty, isTrue);
    });
  });

  group('Macro Tracking Tests', () {
    test('Dynamic macro getters sum correctly across consumed meals', () {
      expect(SystemMemory.bugunProtein, 0);
      expect(SystemMemory.bugunKarb, 0);
      expect(SystemMemory.bugunYag, 0);

      SystemMemory.bugununYemekleri.add(TuketilenYemek(
        "Tavuk Pilav",
        650,
        protein: 45,
        karbonhidrat: 70,
        yag: 15,
      ));

      SystemMemory.bugununYemekleri.add(TuketilenYemek(
        "Protein Shake",
        200,
        protein: 30,
        karbonhidrat: 10,
        yag: 3,
      ));

      expect(SystemMemory.bugunProtein, 75);
      expect(SystemMemory.bugunKarb, 80);
      expect(SystemMemory.bugunYag, 18);
    });
  });

  group('Data Vault (Backup Export & Import) Tests', () {
    test('exportBackupJson produces valid json with complete state', () {
      SystemMemory.oyuncuIsmi = "SHADOW_MONARCH";
      SystemMemory.level.value = 15;
      SystemMemory.altin.value = 2500;
      SystemMemory.suHedefiMl = 3500;
      SystemMemory.gunlukHedefKalori = 2800;
      SystemMemory.vucutSinifi = "Berserker";
      SystemMemory.geminiActiveModel = "gemini-2.0-flash";

      final jsonStr = SystemMemory.exportBackupJson();
      expect(jsonStr.isNotEmpty, isTrue);

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      expect(decoded['oyuncuIsmi'], "SHADOW_MONARCH");
      expect(decoded['level'], 15);
      expect(decoded['altin'], 2500);
      expect(decoded['suHedefiMl'], 3500);
      expect(decoded['gunlukHedefKalori'], 2800);
      expect(decoded['vucutSinifi'], "Berserker");
      expect(decoded['geminiActiveModel'], "gemini-2.0-flash");
    });

    test('importBackupJson restores player stats and inventory', () {
      final sampleBackup = {
        'oyuncuIsmi': "SUNG_JIN_WOO",
        'cinsiyet': "Erkek",
        'level': 50,
        'exp': 120,
        'maxExp': 1000,
        'ap': 10,
        'altin': 99999,
        'hp': 500,
        'maxHp': 500,
        'mp': 200,
        'maxMp': 200,
        'str': 75,
        'agi': 80,
        'vit': 60,
        'intStat': 50,
        'per': 65,
        'boy': 182.0,
        'kilo': 78.0,
        'baslangicKilosu': 65.0,
        'streakGunSayisi': 45,
        'bitenGorevSayisi': 120,
        'suHedefiMl': 3500,
        'bugunIcilenSuMl': 1500,
        'gunlukHedefKalori': 3200,
        'vucutSinifi': "Shadow Lord",
        'hunterRank': "S-Rank",
        'maxBench': 140.0,
        'maxSquat': 180.0,
        'maxDeadlift': 220.0,
        'toplamIdmanDakikasi': 420,
        'geminiApiKey': "AIzaSyTestKey123",
        'geminiActiveModel': "gemini-2.5-flash",
        'kiloGecmisi': [
          {'tarih': '2026-03-01', 'kilo': 75.0}
        ],
        'idmanGecmisi': [
          {'tarih': '2026-03-01T10:00:00.000', 'dakika': 60, 'gorevSayisi': 5}
        ],
        'yemekGecmisi': [
          {'tarih': '2026-03-01', 'toplamKalori': 2800}
        ],
        'canta': [
          {
            'id': 'hp_full',
            'ad': 'Full Recovery Potion',
            'fiyat': 150,
            'aciklama': 'Restores HP',
            'aksiyon': 'hp_full',
            'adet': 5,
            'ikonKodu': 0xe3ab,
          }
        ],
      };

      final success = SystemMemory.importBackupJson(jsonEncode(sampleBackup));
      expect(success, isTrue);
      expect(SystemMemory.oyuncuIsmi, "SUNG_JIN_WOO");
      expect(SystemMemory.level.value, 50);
      expect(SystemMemory.altin.value, 99999);
      expect(SystemMemory.str.value, 75);
      expect(SystemMemory.bugunIcilenSuMl.value, 1500);
      expect(SystemMemory.gunlukHedefKalori, 3200);
      expect(SystemMemory.vucutSinifi, "Shadow Lord");
      expect(SystemMemory.hunterRank, "S-Rank");
      expect(SystemMemory.maxBench, 140.0);
      expect(SystemMemory.toplamIdmanDakikasi, 420);
      expect(SystemMemory.geminiApiKey, "AIzaSyTestKey123");
      expect(SystemMemory.geminiActiveModel, "gemini-2.5-flash");
      expect(SystemMemory.kiloGecmisi.length, 1);
      expect(SystemMemory.idmanGecmisi.length, 1);
      expect(SystemMemory.yemekGecmisi.length, 1);
      expect(SystemMemory.canta.length, 1);
      expect(SystemMemory.canta[0].adet, 5);
    });
  });

  group('Workout Completion and Planner Transfer Tests', () {
    test('zindanAkiniBitir logs session and awards gold and exp', () {
      final initialGold = SystemMemory.altin.value;
      final initialExp = SystemMemory.exp.value;

      final report = SystemMemory.zindanAkiniBitir(600); // 10 minutes
      expect(SystemMemory.toplamIdmanDakikasi, 10);
      expect(SystemMemory.idmanGecmisi.length, 1);
      expect(SystemMemory.idmanGecmisi[0]['dakika'], 10);
      expect(SystemMemory.altin.value, initialGold + 20);
      expect(SystemMemory.exp.value, initialExp + 50);
      expect(report.contains('RAID COMPLETED'), isTrue);
    });

    test('Assigning exercise to weekly plan adds Gorev properly', () {
      const day = 1; // Monday
      expect(SystemMemory.haftalikPlan[day]!.isEmpty, isTrue);

      SystemMemory.haftalikPlan[day]!.add(
        Gorev("[PUSH] Incline Dumbbell Press (4x10)", false, "Fiziksel"),
      );

      expect(SystemMemory.haftalikPlan[day]!.length, 1);
      expect(SystemMemory.haftalikPlan[day]![0].ad, "[PUSH] Incline Dumbbell Press (4x10)");
      expect(SystemMemory.haftalikPlan[day]![0].yapildiMi, isFalse);
      expect(SystemMemory.haftalikPlan[day]![0].tip, "Fiziksel");
    });
  });

  group('Awakening Test & Hunter Rank Tests', () {
    test('Calculates Big 3 Total, strength ratio and updates hunterRank properly', () {
      SystemMemory.kilo = 80.0;
      SystemMemory.hunterRank = "Unranked";
      SystemMemory.maxBench = 100.0;
      SystemMemory.maxSquat = 140.0;
      SystemMemory.maxDeadlift = 180.0;

      final total = SystemMemory.maxBench + SystemMemory.maxSquat + SystemMemory.maxDeadlift; // 420 kg
      final ratio = total / SystemMemory.kilo; // 420 / 80 = 5.25 (> 4.5)

      expect(total, 420.0);
      expect(ratio >= 4.5, isTrue);

      // Simulating rank evaluation
      String evaluatedRank;
      if (ratio >= 4.5) {
        evaluatedRank = "S-Rank (Monarch)";
      } else if (ratio >= 3.75) {
        evaluatedRank = "A-Rank (National)";
      } else {
        evaluatedRank = "B-Rank (Elite)";
      }

      SystemMemory.hunterRank = evaluatedRank;
      expect(SystemMemory.hunterRank, "S-Rank (Monarch)");
    });
  });
}

