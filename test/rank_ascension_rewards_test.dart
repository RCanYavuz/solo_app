import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.level.value = 1;
    SystemMemory.maxExp.value = 100;
    SystemMemory.hunterRank = "Unranked";
    SystemMemory.ap.value = 0;
    SystemMemory.exp.value = 0;
    SystemMemory.altin.value = 0;
    SystemMemory.otomatikStatDagitimiAktif.value = false;
  });

  group('Rütbe Yükseliş Ödülleri & Otomatik Stat Dağıtım Testleri', () {
    test('rankKademesi tüm rütbeleri doğru derecelendirir', () {
      expect(SystemMemory.rankKademesi('Unranked'), 0);
      expect(SystemMemory.rankKademesi('E-Rank (Rookie)'), 1);
      expect(SystemMemory.rankKademesi('D-Rank (Hunter)'), 2);
      expect(SystemMemory.rankKademesi('C-Rank (Knight)'), 3);
      expect(SystemMemory.rankKademesi('B-Rank (Elite)'), 4);
      expect(SystemMemory.rankKademesi('A-Rank (National)'), 5);
      expect(SystemMemory.rankKademesi('S-Rank (Monarch)'), 6);
    });

    test('rankYukselisOduluHesapla kademe atlamalarında doğru AP ve EXP hesaplar', () {
      // E -> D (1 -> 2): D-Rank ödülü: +8 AP, +400 EXP, +1000 Altın
      final odulEtoD = SystemMemory.rankYukselisOduluHesapla('E-Rank (Rookie)', 'D-Rank (Hunter)');
      expect(odulEtoD['tierFarki'], 1);
      expect(odulEtoD['ap'], 8);
      expect(odulEtoD['exp'], 400);
      expect(odulEtoD['altin'], 1000);

      // D -> C (2 -> 3): C-Rank ödülü: +12 AP, +800 EXP, +2000 Altın
      final odulDtoC = SystemMemory.rankYukselisOduluHesapla('D-Rank (Hunter)', 'C-Rank (Knight)');
      expect(odulDtoC['tierFarki'], 1);
      expect(odulDtoC['ap'], 12);
      expect(odulDtoC['exp'], 800);

      // E -> C (1 -> 3): 8 + 12 = 20 AP, 400 + 800 = 1200 EXP
      final odulEtoC = SystemMemory.rankYukselisOduluHesapla('E-Rank (Rookie)', 'C-Rank (Knight)');
      expect(odulEtoC['tierFarki'], 2);
      expect(odulEtoC['ap'], 20);
      expect(odulEtoC['exp'], 1200);

      // Aynı rütbe veya düşüş: 0 ödül
      final odulAyni = SystemMemory.rankYukselisOduluHesapla('C-Rank (Knight)', 'C-Rank (Knight)');
      expect(odulAyni['ap'], 0);
      expect(odulAyni['tierFarki'], 0);
    });

    test('awakeningTestKaydet rütbe atlandığında AP ve EXP kazandırır', () {
      // İlk uyanış: E-Rank (5 AP + 200 EXP ile 1 Level Up = 5 + 3 = 8 AP)
      final ilkSonuc = SystemMemory.awakeningTestKaydet(
        bench: 40,
        squat: 50,
        deadlift: 60,
        rank: 'E-Rank (Rookie)',
      );

      expect(ilkSonuc['rankYukseldi'], true);
      expect(ilkSonuc['kazanilanAp'], 5); // Unranked -> E: 5 AP
      expect(SystemMemory.hunterRank, 'E-Rank (Rookie)');
      expect(SystemMemory.ap.value, 8); // 5 AP rütbe + 3 AP level up

      // İkinci test: E-Rank'ten D-Rank'e yükselme (8 AP rütbe + 400 EXP ile 2 Level Up = 8 + 6 = 14 AP)
      final ikinciSonuc = SystemMemory.awakeningTestKaydet(
        bench: 80,
        squat: 100,
        deadlift: 120,
        rank: 'D-Rank (Hunter)',
      );

      expect(ikinciSonuc['rankYukseldi'], true);
      expect(ikinciSonuc['eskiRank'], 'E-Rank (Rookie)');
      expect(ikinciSonuc['yeniRank'], 'D-Rank (Hunter)');
      expect(ikinciSonuc['kazanilanAp'], 8); // E -> D: +8 AP
      expect(SystemMemory.hunterRank, 'D-Rank (Hunter)');
      expect(SystemMemory.ap.value, 8 + 14); // 8 + (8 AP rütbe + 6 AP level up) = 22 AP
    });

    test('otomatikStatDagitimiAktif true olduğunda kazanılan puanlar anında statlara dağıtılır', () {
      SystemMemory.hunterRank = 'E-Rank (Rookie)';
      SystemMemory.ap.value = 0;
      SystemMemory.str.value = 10;
      SystemMemory.agi.value = 10;
      SystemMemory.vit.value = 10;
      SystemMemory.intStat.value = 10;
      SystemMemory.per.value = 10;
      SystemMemory.otomatikStatDagitimiAktif.value = true;

      final sonuc = SystemMemory.awakeningTestKaydet(
        bench: 80,
        squat: 100,
        deadlift: 120,
        rank: 'D-Rank (Hunter)',
      );

      expect(sonuc['rankYukseldi'], true);
      expect(sonuc['otomatikDagitildi'], true);
      expect(SystemMemory.ap.value, 0); // Puanlar otomatik dağıtıldı

      // Toplam statların 8 (rütbe) + 6 (level up) = 14 arttığını doğrula
      final toplamStat = SystemMemory.str.value +
          SystemMemory.agi.value +
          SystemMemory.vit.value +
          SystemMemory.intStat.value +
          SystemMemory.per.value;
      expect(toplamStat, 50 + 14);
    });
  });
}
