// lib/core/progressive_overload_engine.dart
// ============================================================
// PROGRESİF AŞIRI YÜKLEME & RIR GERİ BİLDİRİM MOTORU
// Avcının set/egzersiz sonu tükeniş (RIR/RPE) geri bildirimini
// değerlendirir, çift progresyon (Double Progression) kuralıyla
// sonraki seans ağırlık/tekrar hedeflerini belirler.
// ============================================================

import 'exercise_coach.dart';

class OverloadKaydi {
  final String egzersizAdi;
  final double sonKilo;
  final int sonTekrar;
  final int sonRir; // 0, 1, 2, 3, 4+
  final DateTime sonTarih;
  final double onerilenKilo;
  final int onerilenTekrar;
  final String sistemMesaji;
  final bool agriBildirildiMi;
  final String? onerilenAlternatif;

  OverloadKaydi({
    required this.egzersizAdi,
    required this.sonKilo,
    required this.sonTekrar,
    required this.sonRir,
    required this.sonTarih,
    required this.onerilenKilo,
    required this.onerilenTekrar,
    required this.sistemMesaji,
    this.agriBildirildiMi = false,
    this.onerilenAlternatif,
  });

  Map<String, dynamic> toJson() => {
    'egzersizAdi': egzersizAdi,
    'sonKilo': sonKilo,
    'sonTekrar': sonTekrar,
    'sonRir': sonRir,
    'sonTarih': sonTarih.toIso8601String(),
    'onerilenKilo': onerilenKilo,
    'onerilenTekrar': onerilenTekrar,
    'sistemMesaji': sistemMesaji,
    'agriBildirildiMi': agriBildirildiMi,
    if (onerilenAlternatif != null) 'onerilenAlternatif': onerilenAlternatif,
  };

  factory OverloadKaydi.fromJson(Map<String, dynamic> json) => OverloadKaydi(
    egzersizAdi: json['egzersizAdi'] ?? '',
    sonKilo: (json['sonKilo'] as num?)?.toDouble() ?? 0.0,
    sonTekrar: json['sonTekrar'] ?? 0,
    sonRir: json['sonRir'] ?? 2,
    sonTarih: json['sonTarih'] != null 
        ? DateTime.tryParse(json['sonTarih']) ?? DateTime.now() 
        : DateTime.now(),
    onerilenKilo: (json['onerilenKilo'] as num?)?.toDouble() ?? 0.0,
    onerilenTekrar: json['onerilenTekrar'] ?? 0,
    sistemMesaji: json['sistemMesaji'] ?? '',
    agriBildirildiMi: json['agriBildirildiMi'] ?? false,
    onerilenAlternatif: json['onerilenAlternatif'],
  );
}

class ProgressiveOverloadEngine {
  /// Bir egzersizin bacak/kalça gibi büyük kas grubu olup olmadığını tespit eder.
  static bool bacakHareketiMi(String egzersizAdi) {
    final lower = egzersizAdi.toLowerCase();
    return lower.contains('squat') ||
        lower.contains('deadlift') ||
        lower.contains('leg press') ||
        lower.contains('lunge') ||
        lower.contains('calf') ||
        lower.contains('hamstring') ||
        lower.contains('quad');
  }

  /// Bir egzersizin üst gövde bileşik (compound) hareketi olup olmadığını tespit eder.
  static bool ustGovdeCompoundMu(String egzersizAdi) {
    final lower = egzersizAdi.toLowerCase();
    return lower.contains('bench') ||
        lower.contains('overhead') ||
        lower.contains('shoulder press') ||
        lower.contains('row') ||
        lower.contains('pull up') ||
        lower.contains('chin up') ||
        lower.contains('dips') ||
        lower.contains('push up');
  }

  /// Eklem ağrısı bildirildiğinde ExerciseCoach veya kural tablosundan alternatif bulur.
  static String? ikameEgzersizBul(String egzersizAdi) {
    final taktik = ExerciseCoach.getTactics(egzersizAdi);
    if (taktik.alternatifler.isNotEmpty) {
      return taktik.alternatifler.first;
    }

    final lower = egzersizAdi.toLowerCase();
    if (lower.contains('bench') || lower.contains('push')) {
      return 'Dumbbell Floor Press (Omuz Dostu)';
    } else if (lower.contains('squat')) {
      return 'Goblet Squat (Diz Dostu)';
    } else if (lower.contains('deadlift')) {
      return 'Trap Bar Deadlift (Bel Dostu)';
    } else if (lower.contains('shoulder') || lower.contains('overhead')) {
      return 'Landmine Press (Eklem Dostu Açılı İtiş)';
    }
    return null;
  }

  /// Avcının seans sonu RIR/RPE ve ağırlık geri bildirimine göre
  /// bir sonraki seansın hedeflerini (Double Progression) hesaplar.
  static OverloadKaydi hesaplaGelecekSeans({
    required String egzersizAdi,
    required double sonKilo,
    required int sonTekrar,
    required int rir, // 0..4
    bool agriVarMi = false,
    DateTime? tarih,
  }) {
    final suAnkiTarih = tarih ?? DateTime.now();

    // 1. DURUM: EKLEM AĞRISI / RAHATSIZLIK BİLDİRİLDİ
    if (agriVarMi) {
      final alternatif = ikameEgzersizBul(egzersizAdi);
      return OverloadKaydi(
        egzersizAdi: egzersizAdi,
        sonKilo: sonKilo,
        sonTekrar: sonTekrar,
        sonRir: rir,
        sonTarih: suAnkiTarih,
        onerilenKilo: sonKilo > 0 ? (sonKilo * 0.85) : 0.0,
        onerilenTekrar: sonTekrar,
        sistemMesaji: '[⚠️ SİSTEM ALARMI: EKLEM KORUMA PROTOKOLÜ] '
            'Ağrı riski tespit edildi! Sakatlığı önlemek için güvenli ikame: '
            '${alternatif ?? "Düşük ağırlıkla kontrollü tempo"}.',
        agriBildirildiMi: true,
        onerilenAlternatif: alternatif,
      );
    }

    // Ağırlık artış basamağı
    final double artisKg = bacakHareketiMi(egzersizAdi)
        ? 5.0
        : (ustGovdeCompoundMu(egzersizAdi) ? 2.5 : 1.25);

    // 2. DURUM: RIR 4+ (Çok Kolay / Hafif Yük)
    if (rir >= 4) {
      if (sonKilo > 0) {
        final double yeniKilo = sonKilo + artisKg;
        // Eğer önceki tekrar 12 veya üstüyse, ağırlık artınca tekrar 8-10'a dengelenir
        final int yeniTekrar = sonTekrar >= 12 ? 8 : sonTekrar;
        return OverloadKaydi(
          egzersizAdi: egzersizAdi,
          sonKilo: sonKilo,
          sonTekrar: sonTekrar,
          sonRir: rir,
          sonTarih: suAnkiTarih,
          onerilenKilo: yeniKilo,
          onerilenTekrar: yeniTekrar,
          sistemMesaji: '[⚡ SİSTEM DİREKTİFİ: GÜÇ SIÇRAMASI] '
              'Mevcut yük hafif kaldı (RIR $rir). Gücün uyandı Avcı! '
              'Bir sonraki seans ağırlık +${artisKg.toStringAsFixed(artisKg % 1 == 0 ? 0 : 1)} kg '
              'artırıldı: ${yeniKilo.toStringAsFixed(1)} kg x $yeniTekrar.',
        );
      } else {
        // Vücut ağırlığı hareketi
        final int yeniTekrar = sonTekrar + 2;
        return OverloadKaydi(
          egzersizAdi: egzersizAdi,
          sonKilo: 0.0,
          sonTekrar: sonTekrar,
          sonRir: rir,
          sonTarih: suAnkiTarih,
          onerilenKilo: 0.0,
          onerilenTekrar: yeniTekrar,
          sistemMesaji: '[⚡ SİSTEM DİREKTİFİ: HACİM ARTIŞI] '
              'Vücut ağırlığı direnci kolay aşıldı. '
              'Bir sonraki seans hedefi +2 tekrar artırıldı: $yeniTekrar tekrar!',
        );
      }
    }

    // 3. DURUM: RIR 2-3 (Optimum Hipertrofi Aralığı - Double Progression)
    if (rir == 2 || rir == 3) {
      if (sonTekrar < 12) {
        // Tekrarı artırma evresi (Örn: 8 -> 9 -> 10 -> 11 -> 12)
        final int yeniTekrar = sonTekrar + 1;
        return OverloadKaydi(
          egzersizAdi: egzersizAdi,
          sonKilo: sonKilo,
          sonTekrar: sonTekrar,
          sonRir: rir,
          sonTarih: suAnkiTarih,
          onerilenKilo: sonKilo,
          onerilenTekrar: yeniTekrar,
          sistemMesaji: '[⚔️ SİSTEM DİREKTİFİ: OPTİMUM HİPERTROFİ] '
              'Kas lifleri tam hedef bölgede uyarıldı (RIR $rir). '
              'Ağırlık sabit tutuldu, sonraki seans hedefi: +1 tekrar ($yeniTekrar tekrar).',
        );
      } else {
        // 12 tekrara ulaşıldı! Artık ağırlığı artırıp tekrarı 8'e çekme zamanı!
        final double yeniKilo = sonKilo > 0 ? (sonKilo + artisKg) : artisKg;
        return OverloadKaydi(
          egzersizAdi: egzersizAdi,
          sonKilo: sonKilo,
          sonTekrar: sonTekrar,
          sonRir: rir,
          sonTarih: suAnkiTarih,
          onerilenKilo: yeniKilo,
          onerilenTekrar: 8,
          sistemMesaji: '[🌟 SİSTEM DİREKTİFİ: ÇİFT PROGRESYON ZİRVESİ] '
              '12 tekrar barajı aşıldı! Ağırlık +${artisKg.toStringAsFixed(artisKg % 1 == 0 ? 0 : 1)} kg '
              'artırıldı (${yeniKilo.toStringAsFixed(1)} kg) ve tekrar 8\'e sıfırlandı.',
        );
      }
    }

    // 4. DURUM: RIR 0-1 (Tükeniş / Aşırı Zorlanma)
    return OverloadKaydi(
      egzersizAdi: egzersizAdi,
      sonKilo: sonKilo,
      sonTekrar: sonTekrar,
      sonRir: rir,
      sonTarih: suAnkiTarih,
      onerilenKilo: sonKilo,
      onerilenTekrar: sonTekrar,
      sistemMesaji: '[🛡️ SİSTEM UYARISI: LİMİT SEVİYESİ] '
          'Tükeniş sınırında çalışıldı (RIR $rir). Ağırlık ve tekrar korundu. '
          'Toparlanma, uyku ve protein desteğine öncelik ver.',
    );
  }
}
