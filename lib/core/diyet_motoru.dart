// Dosya: lib/core/diyet_motoru.dart

class DiyetMotoru {
  static Map<String, int> makroHesapla(double kilo, String hedef) {
    double protein = 0;
    double yag = 0;
    double karb = 0;
    int toplamKalori = 0;

    final h = hedef.toLowerCase();
    if (h == "yag_yakma" || h.contains("kilo ver") || h.contains("yağ yak") || h.contains("yag yak")) {
      protein = kilo * 2.0; 
      yag = kilo * 0.8;     
      karb = kilo * 1.5;    
    } else if (h == "kilo_alma" || h.contains("kilo al") || h.contains("kas inşa") || h.contains("kas insa")) {
      protein = kilo * 2.2; 
      yag = kilo * 1.0;
      karb = kilo * 4.0;    
    } else {
      protein = kilo * 2.0;
      yag = kilo * 0.8;
      karb = kilo * 1.5;
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