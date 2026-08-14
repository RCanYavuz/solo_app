// Dosya: lib/core/diyet_motoru.dart

class DiyetMotoru {
  static Map<String, int> makroHesapla(double kilo, String hedef) {
    double protein = 0;
    double yag = 0;
    double karb = 0;
    int toplamKalori = 0;

    if (hedef == "yag_yakma") {
      protein = kilo * 2.0; 
      yag = kilo * 0.8;     
      karb = kilo * 1.5;    
    } else if (hedef == "kilo_alma") {
      protein = kilo * 2.2; 
      yag = kilo * 1.0;
      karb = kilo * 4.0;    
    }

    toplamKalori = ((protein * 4) + (karb * 4) + (yag * 9)).round();

    return {
      "Kalori": toplamKalori,
      "Protein": protein.round(),
      "Yag": yag.round(),
      "Karbonhidrat": karb.round(),
    };
  }
}