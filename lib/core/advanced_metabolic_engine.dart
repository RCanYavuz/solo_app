// lib/core/advanced_metabolic_engine.dart
// ============================================================
// GELİŞMİŞ BİLİMSEL METABOLİZMA & İDMAN YIPRANMA HESAPLAMA MOTORU
// US Navy Body Fat %, LBM, Katch-McArdle / Mifflin BMR,
// Dinamik TDEE, MET bazlı idman harcaması ve Katabolizma Telafisi.
// ============================================================

import 'dart:math';

class BodyCompositionResult {
  final double yagOraniYuzde;
  final double yagKutlesiKg;
  final double yagsizKasKutlesiKg; // LBM (Lean Body Mass)
  final String kompozisyonSinifi; // 'Atletik', 'Fit', 'Standart', 'Yüksek Yağ'
  final double bmr;
  final double tdee;
  final String hesaplamaYontemi;

  const BodyCompositionResult({
    required this.yagOraniYuzde,
    required this.yagKutlesiKg,
    required this.yagsizKasKutlesiKg,
    required this.kompozisyonSinifi,
    this.bmr = 1600.0,
    this.tdee = 2200.0,
    this.hesaplamaYontemi = 'US Navy & Katch-McArdle',
  });

  double get yagOrani => yagOraniYuzde;
  double get yagsizKutleKg => yagsizKasKutlesiKg;
  String get yagSinifi => kompozisyonSinifi;
}

class WorkloadImpactResult {
  final int yakilanKalori;
  final int telafiProteiniGram;
  final int telafiKarbonhidratiGram;
  final String katabolizmaSeviyesi; // 'Düşük', 'Orta', 'Yüksek', 'Kritik'
  final String sistemUyarisi;

  const WorkloadImpactResult({
    required this.yakilanKalori,
    required this.telafiProteiniGram,
    required this.telafiKarbonhidratiGram,
    required this.katabolizmaSeviyesi,
    required this.sistemUyarisi,
  });

  int get telafiProteini => telafiProteiniGram;
  int get telafiKarbonhidrati => telafiKarbonhidratiGram;
  String get katabolizmaRiski => katabolizmaSeviyesi;
}

class AdvancedMetabolicEngine {
  /// 1. US NAVY FORMÜLÜ İLE VÜCUT YAĞ ORANI (%) VE YAĞSIZ KAS KÜTLESİ (LBM) HESABI
  /// Erkek: 495 / (1.0324 - 0.19077 * log10(bel - boyun) + 0.15456 * log10(boy)) - 450
  /// Kadın: 495 / (1.29579 - 0.35004 * log10(bel + kalça - boyun) + 0.22100 * log10(boy)) - 450
  static BodyCompositionResult hesaplaVucutKompozisyonu({
    required double boyCm,
    required double kiloKg,
    required String cinsiyet,
    required double belCm,
    double? boyunCm,
    double? kalcaCm,
    int haftalikIdmanSayisi = 3,
    bool dovuscuMu = false,
    int yas = 25,
  }) {
    if (boyCm <= 0 || kiloKg <= 0) {
      return const BodyCompositionResult(
        yagOraniYuzde: 15.0,
        yagKutlesiKg: 10.5,
        yagsizKasKutlesiKg: 59.5,
        kompozisyonSinifi: 'Fit',
        bmr: 1600.0,
        tdee: 2200.0,
      );
    }

    // Varsayılan boyun ve bel değerleri
    double boyun = (boyunCm != null && boyunCm > 20) ? boyunCm : 38.0;
    double bel = (belCm > 40) ? belCm : (boyCm * 0.46);

    double yagYuzdesi = 15.0;
    final bool isErkek = cinsiyet.toLowerCase().contains('erkek') || cinsiyet.toLowerCase().contains('male');

    try {
      if (isErkek) {
        double fark = bel - boyun;
        if (fark <= 0) fark = 10.0;
        final val = 1.0324 - (0.19077 * (log(fark) / ln10)) + (0.15456 * (log(boyCm) / ln10));
        yagYuzdesi = (495 / val) - 450;
      } else {
        double kalca = (kalcaCm != null && kalcaCm > 40) ? kalcaCm : (bel * 1.15);
        double toplam = bel + kalca - boyun;
        if (toplam <= 0) toplam = 20.0;
        final val = 1.29579 - (0.35004 * (log(toplam) / ln10)) + (0.22100 * (log(boyCm) / ln10));
        yagYuzdesi = (495 / val) - 450;
      }
    } catch (_) {
      yagYuzdesi = isErkek ? 15.0 : 23.0;
    }

    // Sınırlandırma (Clamping)
    yagYuzdesi = yagYuzdesi.clamp(4.0, 55.0);

    final double yagKutlesi = (kiloKg * (yagYuzdesi / 100)).roundToDouble();
    final double lbm = (kiloKg - yagKutlesi).clamp(20.0, kiloKg);

    String sinif;
    if (isErkek) {
      if (yagYuzdesi < 10) {
        sinif = 'Atletik (Elite)';
      } else if (yagYuzdesi < 16) {
        sinif = 'Fit (Hunter)';
      } else if (yagYuzdesi < 22) {
        sinif = 'Standart';
      } else {
        sinif = 'Yüksek Yağ (Bulk/Aşırı)';
      }
    } else {
      if (yagYuzdesi < 18) {
        sinif = 'Atletik (Elite)';
      } else if (yagYuzdesi < 24) {
        sinif = 'Fit (Hunter)';
      } else if (yagYuzdesi < 30) {
        sinif = 'Standart';
      } else {
        sinif = 'Yüksek Yağ';
      }
    }

    // BMR ve TDEE hesaplama
    final int bmrVal = hesaplaBMR(
      boyCm: boyCm,
      kiloKg: kiloKg,
      yas: yas,
      cinsiyet: cinsiyet,
      yagsizKasKutlesiKg: lbm,
    );
    final int tdeeVal = hesaplaTDEE(
      bmr: bmrVal,
      haftalikIdmanSayisi: haftalikIdmanSayisi,
      dovusSporuMu: dovuscuMu,
    );

    return BodyCompositionResult(
      yagOraniYuzde: double.parse(yagYuzdesi.toStringAsFixed(1)),
      yagKutlesiKg: double.parse(yagKutlesi.toStringAsFixed(1)),
      yagsizKasKutlesiKg: double.parse(lbm.toStringAsFixed(1)),
      kompozisyonSinifi: sinif,
      bmr: bmrVal.toDouble(),
      tdee: tdeeVal.toDouble(),
      hesaplamaYontemi: lbm > 30 ? 'Katch-McArdle (LBM)' : 'Mifflin-St Jeor',
    );
  }

  /// 2. HİBRİT BAZAL METABOLİZMA HIZI (BMR) HESABI
  /// Eğer LBM (yağsız kütle) varsa Katch-McArdle formülü (en hassas):
  /// BMR = 370 + (21.6 * LBM)
  /// Yoksa Mifflin-St Jeor formülü.
  static int hesaplaBMR({
    required double boyCm,
    required double kiloKg,
    required int yas,
    required String cinsiyet,
    double? yagsizKasKutlesiKg,
  }) {
    if (yagsizKasKutlesiKg != null && yagsizKasKutlesiKg > 30) {
      // Katch-McArdle
      return (370 + (21.6 * yagsizKasKutlesiKg)).round();
    }

    // Mifflin-St Jeor
    final bool isErkek = cinsiyet.toLowerCase().contains('erkek') || cinsiyet.toLowerCase().contains('male');
    double bmr = (10 * kiloKg) + (6.25 * boyCm) - (5 * yas);
    bmr += isErkek ? 5 : -161;

    return bmr.round().clamp(1000, 3500);
  }

  /// 3. DİNAMİK TOPLAM GÜNLÜK ENERJİ HARCAMASI (TDEE)
  static int hesaplaTDEE({
    required int bmr,
    required int haftalikIdmanSayisi,
    bool dovusSporuMu = false,
  }) {
    double carpan;
    if (haftalikIdmanSayisi <= 1) {
      carpan = 1.2; // Sedanter
    } else if (haftalikIdmanSayisi <= 3) {
      carpan = 1.375; // Hafif Aktif
    } else if (haftalikIdmanSayisi <= 5) {
      carpan = dovusSporuMu ? 1.6 : 1.55; // Orta / Yoğun Aktif
    } else {
      carpan = dovusSporuMu ? 1.85 : 1.725; // Ekstrem / Şampiyon Seviye
    }

    return (bmr * carpan).round();
  }

  /// 4. MET BAZLI İDMAN YIPRANMASI VE KALORİ/PROTEİN TELAFİSİ
  /// Kalori = (MET * 3.5 * Kilo / 200) * SüreDakika
  static WorkloadImpactResult hesaplaIdmanYipranmasi({
    required int sureDakika,
    required double kiloKg,
    String idmanTuru = 'Boks', // 'Boks', 'Kickboks', 'MMA', 'Güreş', 'Ağırlık', 'Kardiyo'
    int rpeZorluk = 8, // 1-10 Algılanan Zorluk
  }) {
    if (sureDakika <= 0 || kiloKg <= 0) {
      return const WorkloadImpactResult(
        yakilanKalori: 0,
        telafiProteiniGram: 0,
        telafiKarbonhidratiGram: 0,
        katabolizmaSeviyesi: 'Düşük',
        sistemUyarisi: 'Antrenman harcaması tespit edilmedi.',
      );
    }

    double metDegeri;
    final tur = idmanTuru.toLowerCase();

    if (tur.contains('boks') || tur.contains('kick') || tur.contains('muay') || tur.contains('mma') || tur.contains('dövüş')) {
      metDegeri = 10.5; // Yoğun dövüş kondisyonu ve kum torbası
    } else if (tur.contains('güreş') || tur.contains('bjj')) {
      metDegeri = 11.5; // Maksimum izometrik güç ve boğuşma
    } else if (tur.contains('kardiyo') || tur.contains('koşu') || tur.contains('ip atlama') || tur.contains('tabata')) {
      metDegeri = 9.5;
    } else {
      // Ağırlık / Hipertrofi
      metDegeri = 6.5;
    }

    // RPE Düzeltmesi (8 standart)
    double rpeKatsayisi = (rpeZorluk / 8.0).clamp(0.7, 1.3);
    double efektifMet = metDegeri * rpeKatsayisi;

    // Harcanan Kalori
    int yakilanKalori = ((efektifMet * 3.5 * kiloKg / 200.0) * sureDakika).round();

    // Katabolizma ve Telafi Hesaplaması
    int telafiProteini = 0;
    int telafiKarb = 0;
    String katabolizmaSeviyesi;
    String sistemUyarisi;

    if (sureDakika >= 60 || yakilanKalori >= 550) {
      katabolizmaSeviyesi = 'Kritik';
      telafiProteini = (kiloKg * 0.4).round().clamp(25, 45); // +30-40g protein
      telafiKarb = (yakilanKalori * 0.4 / 4.0).round().clamp(40, 80); // Glikojen telafisi
      sistemUyarisi = '[SİSTEM UYARISI: $sureDakika dk yoğun $idmanTuru idmanında $yakilanKalori kcal yakıldı. Kas katabolizmasını önlemek için +${telafiProteini}g protein ve +$yakilanKalori kcal telafi protokolü aktif!]';
    } else if (sureDakika >= 35 || yakilanKalori >= 300) {
      katabolizmaSeviyesi = 'Yüksek';
      telafiProteini = (kiloKg * 0.25).round().clamp(15, 30);
      telafiKarb = (yakilanKalori * 0.35 / 4.0).round().clamp(25, 55);
      sistemUyarisi = '[SİSTEM BİLDİRİMİ: $sureDakika dk $idmanTuru seansı tamamlandı ($yakilanKalori kcal). Kas toparlanması için +${telafiProteini}g protein desteği önerilir.]';
    } else {
      katabolizmaSeviyesi = 'Düşük';
      telafiProteini = 10;
      telafiKarb = 20;
      sistemUyarisi = 'Standart idman hacmi ($yakilanKalori kcal). Günlük beslenme hedefinizi koruyun.';
    }

    return WorkloadImpactResult(
      yakilanKalori: yakilanKalori,
      telafiProteiniGram: telafiProteini,
      telafiKarbonhidratiGram: telafiKarb,
      katabolizmaSeviyesi: katabolizmaSeviyesi,
      sistemUyarisi: sistemUyarisi,
    );
  }

  /// 5. BİLİMSEL MAKRO HEDEFLERİ DAĞILIMI
  static Map<String, int> hesaplaBilimselMakrolar({
    required double kiloKg,
    required int hedefKalori,
    required String hedef, // 'Kilo Ver (Yağ Yak)', 'Kilo Al (Kas İnşa Et)', 'Koru'
    double? yagsizKasKutlesiKg,
  }) {
    double proteinCarpan;
    double yagOranYuzde;

    final h = hedef.toLowerCase();
    if (h.contains('ver') || h.contains('yağ yak') || h.contains('yag_yakma')) {
      // Definasyon: Kas kaybını önlemek için yüksek protein (2.2 - 2.4 g/kg LBM veya 2.0 g/kg total)
      proteinCarpan = (yagsizKasKutlesiKg != null && yagsizKasKutlesiKg > 30) ? 2.3 : 2.0;
      yagOranYuzde = 0.25; // Kalorinin %25'i sağlıklı yağlar
    } else if (h.contains('al') || h.contains('kas') || h.contains('kilo_alma')) {
      // Hipertrofi / Bulk: 1.8 - 2.0 g/kg protein, yüksek karbonhidrat
      proteinCarpan = 2.0;
      yagOranYuzde = 0.25;
    } else {
      // Koru / Standart
      proteinCarpan = 1.8;
      yagOranYuzde = 0.25;
    }

    final double hedefKilo = (yagsizKasKutlesiKg != null && yagsizKasKutlesiKg > 30) ? yagsizKasKutlesiKg : kiloKg;
    int proteinGram = (hedefKilo * proteinCarpan).round();
    int proteinKalori = proteinGram * 4;

    int yagKalori = (hedefKalori * yagOranYuzde).round();
    int yagGram = (yagKalori / 9.0).round();

    int kalanKalori = hedefKalori - proteinKalori - yagKalori;
    if (kalanKalori < 200) kalanKalori = 200;
    int karbGram = (kalanKalori / 4.0).round();

    return {
      'Kalori': hedefKalori,
      'Protein': proteinGram,
      'Yag': yagGram,
      'Karbonhidrat': karbGram,
    };
  }

  /// Hedef kiloya ulaşmak için delta, haftalık önerilen tempo, tahmini süre ve kalori projeksiyonu
  static Map<String, dynamic> hedefKiloProjeksiyonu({
    required double mevcutKilo,
    required double hedefKilo,
    required double tdee,
  }) {
    final double fark = double.parse((hedefKilo - mevcutKilo).toStringAsFixed(1));
    final bool kiloVerme = fark < 0;
    final double absFark = fark.abs();

    // Sağlıklı tempo: haftalık 0.5 kg verme veya 0.35 kg kas inşası
    final double haftalikPace = kiloVerme ? 0.5 : 0.35;
    final int tahminiHafta = absFark == 0 ? 0 : (absFark / haftalikPace).ceil();
    // 0.5 kg yağ dokusu ~ 3850 kcal / 7 gün = 550 kcal / gün açık
    final int gunlukKaloriFarki = absFark == 0 ? 0 : (kiloVerme ? -550 : 350);
    final int onerilenHedefKalori = ((tdee + gunlukKaloriFarki).round()).clamp(1200, 4500);

    return {
      'fark': fark,
      'kiloVerme': kiloVerme,
      'absFark': absFark,
      'haftalikPace': haftalikPace,
      'tahminiHafta': tahminiHafta,
      'gunlukKaloriFarki': gunlukKaloriFarki,
      'onerilenHedefKalori': onerilenHedefKalori,
    };
  }
}
