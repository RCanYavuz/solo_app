// lib/core/dynamic_difficulty_engine.dart
import '../controllers/system_memory.dart';
import 'audio_system.dart';
import 'translation_manager.dart';

enum DdaAction {
  upgrade,
  deload,
  maintain,
}

class DifficultyEvaluation {
  final DdaAction action;
  final String mevcutZorluk;
  final String onerilenZorluk;
  final String baslik;
  final String aciklama;
  final double basariSkoru;
  final int streak;

  const DifficultyEvaluation({
    required this.action,
    required this.mevcutZorluk,
    required this.onerilenZorluk,
    required this.baslik,
    required this.aciklama,
    required this.basariSkoru,
    required this.streak,
  });
}

class DynamicDifficultyEngine {
  /// Avcının son performans verilerini analiz eder ve dinamik zorluk önerisi üretir.
  static DifficultyEvaluation analizEt() {
    final String mevcutZorluk = SystemMemory.aktifZorluk.isNotEmpty && SystemMemory.aktifZorluk != "Unknown"
        ? SystemMemory.aktifZorluk
        : "Normal";

    final int streak = SystemMemory.streakGunSayisi;
    final int fatigue = SystemMemory.fatigue.value;
    final int hp = SystemMemory.hp.value;
    final int toplamIdman = SystemMemory.idmanGecmisi.length;
    final bool tr = TranslationManager.isTurkish;

    // 1. Deload / Aktif Dinlenme Değerlendirmesi: Aşırı yorgunluk veya kritik HP kaybı
    if (fatigue >= 80 || (hp < 40 && streak == 0 && toplamIdman > 3)) {
      return DifficultyEvaluation(
        action: DdaAction.deload,
        mevcutZorluk: mevcutZorluk,
        onerilenZorluk: "Deload",
        baslik: tr
            ? "SİSTEM UYARISI: AŞIRI YIPRANMA (DELOAD ÖNERİSİ)"
            : "SYSTEM WARNING: SEVERE OVERREACHING (DELOAD ADVICE)",
        aciklama: tr
            ? "Avcı, yorgunluk seviyen kritik eşiği aştı ($fatigue/100). Kas yıkımı ve sakatlığı önlemek için aktif dinlenme (deload) protokolü öneriliyor."
            : "Hunter, your fatigue has crossed the critical threshold ($fatigue/100). Active recovery (deload) protocol recommended to prevent catabolism and injury.",
        basariSkoru: 0.35,
        streak: streak,
      );
    }

    // 2. Zorluk Artışı (Upgrade) Değerlendirmesi
    if (mevcutZorluk == "Normal" && streak >= 7 && fatigue < 60) {
      return DifficultyEvaluation(
        action: DdaAction.upgrade,
        mevcutZorluk: mevcutZorluk,
        onerilenZorluk: tr ? "Yüksek" : "High",
        baslik: tr
            ? "SİSTEM EVRİMİ: ZORLUK KADEMESİ YÜKSELİŞİ"
            : "SYSTEM EVOLUTION: DIFFICULTY TIER UPGRADE",
        aciklama: tr
            ? "Son $streak günlük kesintisiz disiplininiz sistem tarafından onaylandı. Adaptasyon sınırını aşmak için 'Yüksek' zorluk protokolüne geçiş öneriliyor."
            : "Your $streak-day unbroken streak is verified by the System. Transitioning to 'High' difficulty protocol recommended to break adaptation limits.",
        basariSkoru: 0.90,
        streak: streak,
      );
    }

    if (mevcutZorluk == "Yüksek" && streak >= 14 && fatigue < 55) {
      return DifficultyEvaluation(
        action: DdaAction.upgrade,
        mevcutZorluk: mevcutZorluk,
        onerilenZorluk: tr ? "Cehennem" : "Hell",
        baslik: tr
            ? "SİSTEM EVRİMİ: CEHENNEM PROTOKOLÜ ÇAĞRISI"
            : "SYSTEM EVOLUTION: CALL OF HELL PROTOCOL",
        aciklama: tr
            ? "Avcının fiziksel kapasitesi olağanüstü seviyeye ulaştı ($streak gün streak). Maksimum kas hipertrofisi için 'Cehennem' zorluk seviyesine yükseltme direktifi."
            : "Hunter's physical capacity reached an exceptional state ($streak-day streak). Directive: Upgrade to 'Hell' difficulty tier for maximum hypertrophy.",
        basariSkoru: 0.98,
        streak: streak,
      );
    }

    // 3. Mevcut Durumu Koru (Maintain)
    return DifficultyEvaluation(
      action: DdaAction.maintain,
      mevcutZorluk: mevcutZorluk,
      onerilenZorluk: mevcutZorluk,
      baslik: tr
          ? "SİSTEM STABİL: OPTİMAL ÇALIŞMA HACMİ"
          : "SYSTEM STABLE: OPTIMAL WORKLOAD VOLUME",
      aciklama: tr
          ? "Mevcut antrenman yoğunluğu ve toparlanma dengesi kararlı. Mevcut protokole devam edin."
          : "Current training intensity and recovery balance are stable. Continue current protocol.",
      basariSkoru: 0.75,
      streak: streak,
    );
  }

  /// Önerilen dinamik zorluk ayarını sisteme ve antrenman planına enjekte eder.
  static Future<void> zorluguUygula(DifficultyEvaluation evaluation) async {
    if (evaluation.action == DdaAction.upgrade) {
      SystemMemory.protokolGuncelle(SystemMemory.aktifHedef, evaluation.onerilenZorluk);
      AudioSystem.playLevelUp();
    } else if (evaluation.action == DdaAction.deload) {
      // Yorgunluğu sıfırla, HP toparlanması sağla
      SystemMemory.fatigue.value = 0;
      if (SystemMemory.hp.value < SystemMemory.maxHp) {
        SystemMemory.hp.value = (SystemMemory.hp.value + 30).clamp(0, SystemMemory.maxHp);
      }
      AudioSystem.playSuccess();
    }
    await SystemMemory.kaydet();
  }
}
