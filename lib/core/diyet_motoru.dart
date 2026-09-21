// Dosya: lib/core/diyet_motoru.dart
import 'advanced_metabolic_engine.dart';
import '../controllers/system_memory.dart';

class DiyetMotoru {
  /// Gelişmiş bilimsel hesaplama motorunu kullanarak hedefe ve vücut kompozisyonuna göre makroları türetir
  static Map<String, int> makroHesapla(
    double kilo,
    String hedef, {
    double? boy,
    double? belCm,
    String? cinsiyet,
    int? idmanGunuHaftalik,
  }) {
    final double actualBoy = boy ?? (SystemMemory.boy > 0 ? SystemMemory.boy : 175.0);
    final double actualBel = belCm ?? SystemMemory.belCm;
    final String actualCinsiyet = cinsiyet ?? SystemMemory.cinsiyet;
    final int actualIdmanGunu = idmanGunuHaftalik ?? SystemMemory.haftalikIdmanGunuSayisi;

    final kompozisyon = AdvancedMetabolicEngine.hesaplaVucutKompozisyonu(
      boyCm: actualBoy,
      kiloKg: kilo > 0 ? kilo : 70.0,
      cinsiyet: actualCinsiyet,
      belCm: actualBel,
      haftalikIdmanSayisi: actualIdmanGunu,
      dovuscuMu: SystemMemory.dovuscuMu,
    );

    int hedefKalori;
    if (SystemMemory.diyetisyenListesiAktif && SystemMemory.diyetisyenBazKalori > 0) {
      hedefKalori = SystemMemory.diyetisyenBazKalori;
    } else if (SystemMemory.gunlukHedefKalori > 0) {
      hedefKalori = SystemMemory.gunlukHedefKalori;
    } else {
      hedefKalori = kompozisyon.tdee.round();
    }

    return AdvancedMetabolicEngine.hesaplaBilimselMakrolar(
      kiloKg: kilo,
      hedefKalori: hedefKalori,
      hedef: hedef,
      yagsizKasKutlesiKg: kompozisyon.yagsizKasKutlesiKg,
    );
  }
}