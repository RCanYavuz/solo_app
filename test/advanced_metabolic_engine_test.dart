// test/advanced_metabolic_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_app/core/advanced_metabolic_engine.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/diyet_motoru.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdvancedMetabolicEngine Tests', () {
    test('hesaplaVucutKompozisyonu US Navy & Katch-McArdle erkek testi', () {
      final res = AdvancedMetabolicEngine.hesaplaVucutKompozisyonu(
        kiloKg: 80.0,
        boyCm: 180.0,
        belCm: 84.0,
        boyunCm: 38.0,
        cinsiyet: 'erkek',
        haftalikIdmanSayisi: 4,
        dovuscuMu: true,
      );

      expect(res.yagOrani, greaterThanOrEqualTo(8.0));
      expect(res.yagOrani, lessThanOrEqualTo(25.0));
      expect(res.yagsizKutleKg, greaterThan(55.0));
      expect(res.bmr, greaterThan(1500));
      expect(res.tdee, greaterThan(res.bmr));
      expect(res.hesaplamaYontemi, contains('Katch-McArdle'));
    });

    test('hesaplaVucutKompozisyonu US Navy kadin testi', () {
      final res = AdvancedMetabolicEngine.hesaplaVucutKompozisyonu(
        kiloKg: 60.0,
        boyCm: 165.0,
        belCm: 70.0,
        boyunCm: 32.0,
        kalcaCm: 95.0,
        cinsiyet: 'kadin',
        haftalikIdmanSayisi: 3,
      );

      expect(res.yagOrani, greaterThan(12.0));
      expect(res.yagsizKutleKg, greaterThan(40.0));
      expect(res.bmr, greaterThan(1100));
      expect(res.tdee, greaterThan(res.bmr));
    });

    test('hesaplaIdmanYipranmasi MET ve katabolizma telafi testi', () {
      final boksSonucu = AdvancedMetabolicEngine.hesaplaIdmanYipranmasi(
        kiloKg: 78.0,
        sureDakika: 60,
        idmanTuru: 'Boks / Combat',
      );

      expect(boksSonucu.yakilanKalori, greaterThan(400));
      expect(boksSonucu.telafiProteini, greaterThanOrEqualTo(20));
      expect(boksSonucu.telafiKarbonhidrati, greaterThan(40));
      expect(['Orta', 'Yüksek', 'Kritik'], contains(boksSonucu.katabolizmaRiski));

      final kisaFitness = AdvancedMetabolicEngine.hesaplaIdmanYipranmasi(
        kiloKg: 78.0,
        sureDakika: 20,
        idmanTuru: 'Fitness / Ağırlık',
      );
      expect(kisaFitness.katabolizmaRiski, equals('Düşük'));
      expect(kisaFitness.telafiProteini, equals(10));
    });

    test('hesaplaBilimselMakrolar cut and bulk testi', () {
      final cutMakrolar = AdvancedMetabolicEngine.hesaplaBilimselMakrolar(
        kiloKg: 80.0,
        hedefKalori: 2100,
        hedef: 'yag_yakma',
        yagsizKasKutlesiKg: 66.0,
      );

      expect(cutMakrolar['Kalori'], equals(2100));
      expect(cutMakrolar['Protein']!, greaterThanOrEqualTo(150)); // 2.0g+ / kg
      expect(cutMakrolar['Yag']!, greaterThan(40));

      final bulkMakrolar = AdvancedMetabolicEngine.hesaplaBilimselMakrolar(
        kiloKg: 80.0,
        hedefKalori: 2700,
        hedef: 'kilo_alma',
        yagsizKasKutlesiKg: 66.0,
      );

      expect(bulkMakrolar['Kalori'], equals(2700));
      expect(bulkMakrolar['Karbonhidrat']!, greaterThan(cutMakrolar['Karbonhidrat']!));
    });

    test('DiyetMotoru geriye donuk uyumluluk ve bilimsel motor gecisi', () {
      final makro = DiyetMotoru.makroHesapla(
        75.0,
        'yag_yakma',
        boy: 178,
        belCm: 80,
        cinsiyet: 'erkek',
        idmanGunuHaftalik: 4,
      );

      expect(makro['Kalori']!, greaterThan(1400));
      expect(makro['Protein']!, greaterThan(130));
      expect(makro['Karbonhidrat']!, greaterThan(50));
      expect(makro['Yag']!, greaterThan(35));
    });
  });

  group('SystemMemory Dietitian & Workload Tests', () {
    test('idmanYipranmasiIsle metrikleri gunceller', () {
      SystemMemory.kilo = 80.0;
      SystemMemory.bugunYakilanIdmanKalorisi = 0;
      SystemMemory.bugunTelafiProteini = 0;

      final res = SystemMemory.idmanYipranmasiIsle(dakika: 45, idmanTuru: 'Zindan Akını / Ağırlık');

      expect(res.yakilanKalori, greaterThan(200));
      expect(SystemMemory.bugunYakilanIdmanKalorisi, equals(res.yakilanKalori));
      expect(SystemMemory.bugunTelafiProteini, equals(res.telafiProteini));
      expect(SystemMemory.sonIdmanYipranmaRaporu, isNotNull);
    });

    test('diyetisyenListesiniKaydet ve diyetisyenListesiniSifirla', () {
      SystemMemory.diyetisyenListesiniKaydet(
        kalori: 2300,
        protein: 165,
        karb: 240,
        yag: 70,
        ogunler: [
          {'ad': 'Sabah', 'kalori': 500}
        ],
      );

      expect(SystemMemory.diyetisyenListesiAktif, isTrue);
      expect(SystemMemory.diyetisyenBazKalori, equals(2300));
      expect(SystemMemory.diyetisyenBazProtein, equals(165));
      expect(SystemMemory.gunlukHedefKalori, equals(2300));
      expect(SystemMemory.diyetisyenOgunleri.length, equals(1));

      SystemMemory.diyetisyenListesiniSifirla();
      expect(SystemMemory.diyetisyenListesiAktif, isFalse);
      expect(SystemMemory.diyetisyenOgunleri.isEmpty, isTrue);
    });

    test('hedefKiloProjeksiyonu ve hedefleriSistemeEntegreEt dogru calisir', () {
      final proj = AdvancedMetabolicEngine.hedefKiloProjeksiyonu(
        mevcutKilo: 80.0,
        hedefKilo: 75.0,
        tdee: 2400.0,
      );

      expect(proj['fark'], equals(-5.0));
      expect(proj['kiloVerme'], isTrue);
      expect(proj['haftalikPace'], equals(0.5));
      expect(proj['tahminiHafta'], equals(10));
      expect(proj['gunlukKaloriFarki'], equals(-550));
      expect(proj['onerilenHedefKalori'], equals(1850));

      // Sisteme entegre et
      SystemMemory.hedefleriSistemeEntegreEt(
        yeniHedefKilo: 75.0,
        yeniKalori: 1850,
        not: 'Haftada 0.5 kg verip kas korumak istiyorum.',
      );

      expect(SystemMemory.hedefKilo, equals(75.0));
      expect(SystemMemory.gunlukHedefKalori, equals(1850));
      expect(SystemMemory.normalGunlukHedefKalori, equals(1850));
      expect(SystemMemory.avciDiyetNotu, equals('Haftada 0.5 kg verip kas korumak istiyorum.'));
    });
  });
}
