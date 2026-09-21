// lib/core/supplement_engine.dart
// ============================================================
// SUPLEMENT KUŞANMA (SUPPLEMENT LOADOUT) & METABOLİK SİNERJİ MOTORU
// Avcının aldığı takviyeleri ekipman gibi kuşanmasını sağlar.
// Kuşanılan suplementlere göre idman toleransı, su hedefi ve
// katabolizma koruması dinamik olarak güncellenir.
// ============================================================

enum SupplementCategory { preWorkout, creatine, protein, electrolyte }

class SupplementItem {
  final String id;
  final String ad;
  final SupplementCategory kategori;
  final String dozaj;
  final String aciklama;
  final String antrenmanEtkisi;
  final int suEtkisiMl;
  final double hacimEtkisiYuzde;
  final String iconKodu;

  const SupplementItem({
    required this.id,
    required this.ad,
    required this.kategori,
    required this.dozaj,
    required this.aciklama,
    required this.antrenmanEtkisi,
    this.suEtkisiMl = 0,
    this.hacimEtkisiYuzde = 0.0,
    required this.iconKodu,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'kategori': kategori.name,
    'dozaj': dozaj,
    'aciklama': aciklama,
    'antrenmanEtkisi': antrenmanEtkisi,
    'suEtkisiMl': suEtkisiMl,
    'hacimEtkisiYuzde': hacimEtkisiYuzde,
    'iconKodu': iconKodu,
  };
}

class SupplementEngine {
  /// Sistemdeki standart suplement kataloğu
  static const List<SupplementItem> katalog = [
    SupplementItem(
      id: 'pre_workout_caffeine',
      ad: 'Pre-Workout & Kafein Booster',
      kategori: SupplementCategory.preWorkout,
      dozaj: '200mg Kafein + 3g Beta-Alanin',
      aciklama: 'Merkezi sinir sistemi uyarımı ve laktik asit tamponlama.',
      antrenmanEtkisi: 'Hacim toleransını +%10 artırır; son sette Booster Drop-Set imkanı sağlar.',
      suEtkisiMl: 250,
      hacimEtkisiYuzde: 10.0,
      iconKodu: 'flash_on',
    ),
    SupplementItem(
      id: 'creatine_monohydrate',
      ad: 'Kreatin Monohidrat (Creapure)',
      kategori: SupplementCategory.creatine,
      dozaj: '5g Günlük',
      aciklama: 'Hücre içi fosfokreatin ve ATP yenilenmesi, maksimum kuvvet artışı.',
      antrenmanEtkisi: 'Ağır setlerde +1 tekrar dayanıklılığı sağlar; hücre içi hidrasyonu artırır.',
      suEtkisiMl: 500, // Kreatin için zorunlu +500 ml su
      hacimEtkisiYuzde: 5.0,
      iconKodu: 'fitness_center',
    ),
    SupplementItem(
      id: 'whey_isolate_protein',
      ad: 'Whey Protein İzole / EAA',
      kategori: SupplementCategory.protein,
      dozaj: '25g Protein (BCAA Zengin)',
      aciklama: 'Hızlı sindirilen protein ve esansiyel aminoasit takviyesi.',
      antrenmanEtkisi: 'Ağır idman yıpranmasında kas lifi onarımını hızlandırır, katabolizmayı bloke eder.',
      suEtkisiMl: 250,
      hacimEtkisiYuzde: 0.0,
      iconKodu: 'local_fire_department',
    ),
    SupplementItem(
      id: 'electrolyte_matrix',
      ad: 'Elektrolit & Magnezyum Matrisi',
      kategori: SupplementCategory.electrolyte,
      dozaj: 'Sodyum, Potasyum, Magnezyum',
      aciklama: 'Yoğun terlemeyle kaybedilen minerallerin telafisi ve sinir iletimi.',
      antrenmanEtkisi: 'Boks raundlarında ve kardiyoda kramp riskini sıfırlar, dayanıklılığı korur.',
      suEtkisiMl: 300,
      hacimEtkisiYuzde: 5.0,
      iconKodu: 'water_drop',
    ),
  ];

  /// Kuşanılan suplement ID'lerine göre toplam su artışını (ml) hesaplar.
  static int hesaplaToplamSuArtisi(List<String> kusanilanIdler) {
    int toplam = 0;
    for (final id in kusanilanIdler) {
      final item = katalog.cast<SupplementItem?>().firstWhere((s) => s?.id == id, orElse: () => null);
      if (item != null) {
        toplam += item.suEtkisiMl;
      }
    }
    return toplam;
  }

  /// Kuşanılan suplement ID'lerine göre toplam idman hacim bonusunu (% cinsinden) hesaplar.
  static double hesaplaToplamHacimBonusu(List<String> kusanilanIdler) {
    double toplam = 0.0;
    for (final id in kusanilanIdler) {
      final item = katalog.cast<SupplementItem?>().firstWhere((s) => s?.id == id, orElse: () => null);
      if (item != null) {
        toplam += item.hacimEtkisiYuzde;
      }
    }
    return toplam;
  }

  /// Avcının antrenman profiline ve hedefine göre eksik kalan suplementleri önerir.
  static List<String> hesaplaOneriler({
    required double kilo,
    required int haftalikBoksDakikasi,
    required int haftalikAgirlikDakikasi,
    required String hedef,
    required List<String> kusanilanIdler,
  }) {
    List<String> tavsiyeler = [];

    // 1. Kural: Yüksek Boks / Dövüş Yoğunluğu
    if (haftalikBoksDakikasi >= 45 && !kusanilanIdler.contains('electrolyte_matrix')) {
      tavsiyeler.add(
        '[⚡ ELEKTROLİT UYARISI] Haftalık $haftalikBoksDakikasi dk dövüş/boks idmanı yüksek mineral kaybı yaratır. Kramp koruması ve raund dayanıklılığı için Elektrolit Matrisi kuşanılması önerilir.',
      );
    }

    // 2. Kural: Ağırlık İdmanı & Kuvvet Gelişimi
    if (haftalikAgirlikDakikasi >= 60 && !kusanilanIdler.contains('creatine_monohydrate')) {
      tavsiyeler.add(
        '[⚔️ KREATİN PROTOKOLÜ] Düzenli ağırlık idmanı yapıyorsun. ATP yenilenmesi ve setlerde +1 tekrar torku için Kreatin Monohidrat (5g) sisteme entegre edilmelidir.',
      );
    }

    // 3. Kural: Kilo Alma / Kas İnşası
    if (hedef.toLowerCase().contains('al') || hedef.toLowerCase().contains('kas')) {
      if (!kusanilanIdler.contains('whey_isolate_protein')) {
        tavsiyeler.add(
          '[🥩 PROTEİN ONARIMI] Kas hipertrofisi hedefinde protein sentezini maksimize etmek için Whey / EAA desteği önerilir.',
        );
      }
    }

    // 4. Kural: Yağ Yakımı / Definasyon
    if (hedef.toLowerCase().contains('ver') || hedef.toLowerCase().contains('yağ')) {
      if (!kusanilanIdler.contains('pre_workout_caffeine')) {
        tavsiyeler.add(
          '[🔥 METABOLİK BOOST] Kalori açığında enerji düşüşünü engellemek ve yağ oksidasyonunu hızlandırmak için Pre-Workout / Kafein desteği faydalıdır.',
        );
      }
    }

    if (tavsiyeler.isEmpty) {
      tavsiyeler.add('[🌟 SİSTEM ONAYI] Mevcut suplement donanımın hedeflerinle kusursuz uyum içerisinde.');
    }

    return tavsiyeler;
  }
}
