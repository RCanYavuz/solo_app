import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/models/task_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.hp.value = 100;
    SystemMemory.maxHp = 100;
    SystemMemory.mp.value = 20;
    SystemMemory.maxMp = 20;
    SystemMemory.fatigue.value = 0;
    SystemMemory.level.value = 5;
    SystemMemory.dogumTarihi = null;
  });

  group('Sistem İyileştirmeleri ve Düzeltmeleri Test Paketi', () {
    test('1. tartiGuncelle dogumTarihi null olduğunda çökmez ve güvenli çalışır', () {
      SystemMemory.dogumTarihi = null;
      expect(() => SystemMemory.tartiGuncelle(75.0), returnsNormally);
      expect(SystemMemory.kilo, 75.0);
    });

    test('2. gunSonuHesaplasmasi idman kalorisi ve toparlanma değerlerini sıfırlar', () {
      SystemMemory.bugunYakilanIdmanKalorisi = 450;
      SystemMemory.bugunTelafiProteini = 35;
      SystemMemory.bugunTelafiKarbonhidrati = 50;
      SystemMemory.sonIdmanYipranmaRaporu = {'ozet': 'Agir Idman'};
      SystemMemory.uyunanSaat = 8;
      SystemMemory.fatigue.value = 80;

      SystemMemory.gunSonuHesaplasmasi(1);

      expect(SystemMemory.bugunYakilanIdmanKalorisi, 0);
      expect(SystemMemory.bugunTelafiProteini, 0);
      expect(SystemMemory.bugunTelafiKarbonhidrati, 0);
      expect(SystemMemory.sonIdmanYipranmaRaporu, isNull);
      // 8 saat uyku x 12 = 96 toparlanma -> 80 - 96 -> 0
      expect(SystemMemory.fatigue.value, 0);
    });

    test('3. zindanAkiniBitir yorgunluk (fatigue) değerini artırır', () {
      SystemMemory.maxExp.value = 10000;
      SystemMemory.exp.value = 0;
      SystemMemory.fatigue.value = 10;
      // 10 dakika (600 sn) idman -> 50 EXP kazanır, seviye atlamaz
      SystemMemory.zindanAkiniBitir(600);

      expect(SystemMemory.fatigue.value, greaterThan(10));
      expect(SystemMemory.fatigue.value, lessThanOrEqualTo(100));
    });

    test('4. bossGuncelle hafta boyunca tamamlanan görevlerin kümülatif hasarını hesaplar', () {
      SystemMemory.level.value = 10;
      SystemMemory.haftalikPlan[7] = [Gorev('Pazar Görevi', true, 'Fiziksel')];
      SystemMemory.haftalikPlan[1] = [Gorev('Pazartesi Görevi', true, 'Fiziksel')];
      SystemMemory.haftalikPlan[3] = [Gorev('Çarşamba Görevi', true, 'Fiziksel')];

      SystemMemory.bossGuncelle(gunIndex: 7);

      expect(SystemMemory.bossMaxHP, 1000);
      expect(SystemMemory.bossHP.value, lessThan(1000));
    });

    test('5. yeniGunKontrolu multi-day devamsızlıkta kaçırılan gün cezası uygular', () {
      SystemMemory.golgeModuAktif = false;
      SystemMemory.redGateAktif = false;
      SystemMemory.streakGunSayisi = 5;
      SystemMemory.hp.value = 100;

      DateTime ucGunOnce = DateTime.now().subtract(const Duration(days: 3));
      SystemMemory.sonGirisTarihi = "${ucGunOnce.year}-${ucGunOnce.month.toString().padLeft(2, '0')}-${ucGunOnce.day.toString().padLeft(2, '0')}";

      SystemMemory.yeniGunKontrolu();

      expect(SystemMemory.streakGunSayisi, 0);
      expect(SystemMemory.hp.value, lessThan(100));
      expect(SystemMemory.geceRaporu, contains('[SYSTEM PENALTY]'));
    });

    test('6. baslangicPrograminiAta dinlenme günlerine zihinsel (MIND/PERCEPTION) görevleri ekler', () {
      SystemMemory.baslangicPrograminiAta(
        ekipman: 'salon',
        rank: 'E',
        idmanGunu: 3,
        hedef: 'combat',
      );

      final sali = SystemMemory.haftalikPlan[2]!;
      expect(sali.isNotEmpty, isTrue);
      expect(sali.any((g) => g.ad.contains('[MIND]')), isTrue);
      expect(sali.any((g) => g.ad.contains('[PERCEPTION]')), isTrue);
      expect(sali.any((g) => g.tip == 'Zihinsel'), isTrue);
    });

    test('7. basarimKademeGuncelle yeni kademe aşıldığında bildirim üretir', () {
      SystemMemory.basarimKademeleri.clear();
      SystemMemory.yeniBasarimBildirimi.value = null;

      bool yukseldi = SystemMemory.basarimKademeGuncelle('streak', 1, 'Iron Will', '7 Gün Seri');
      expect(yukseldi, isTrue);
      expect(SystemMemory.basarimKademeleri['streak'], 1);
      expect(SystemMemory.yeniBasarimBildirimi.value, contains('[ACHIEVEMENT ASCENDED]'));

      bool ayniMi = SystemMemory.basarimKademeGuncelle('streak', 1, 'Iron Will', '7 Gün Seri');
      expect(ayniMi, isFalse);
    });
  });
}
