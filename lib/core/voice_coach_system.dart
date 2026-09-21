// lib/core/voice_coach_system.dart
// ============================================================
// "SİSTEM" YAPAY ZEKA SESLİ KOÇU (VOICE GUIDANCE ENGINE)
// Kulaklık veya hoparlörle idman yapan avcıya set bitişi,
// dinlenme sayacı, son 3 saniye geri sayımı ve overload
// direktiflerini sesli ve işitsel olarak aktarır.
// ============================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'audio_system.dart';
import '../controllers/system_memory.dart';

class VoiceCoachSystem {
  static final ValueNotifier<String?> sonSesliMesaj = ValueNotifier(null);

  static bool get _isTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Sesli koçluk mesajı yayınlar ve ilgili işitsel frekansı tetikler
  static Future<void> seslendir(String mesaj, {bool zilCal = false, bool levelUpCal = false}) async {
    if (!SystemMemory.sesliKocAktif.value) return;

    sonSesliMesaj.value = mesaj;
    if (_isTest) return;

    if (levelUpCal) {
      await AudioSystem.playLevelUp();
    } else if (zilCal) {
      await AudioSystem.playBell();
    } else {
      await AudioSystem.playTransition();
    }
  }

  /// Dinlenme süresi başladığında çağrılır
  static Future<void> dinlenmeBasladi(int sureSaniye, {String? egzersizAdi}) async {
    if (!SystemMemory.sesliKocAktif.value) return;
    await seslendir(
      'Dinlenme sayacı başladı: $sureSaniye saniye toparlan.',
      zilCal: true,
    );
  }

  /// Dinlenme süresinin son 3 saniyesinde geri sayım bip'i verir
  static Future<void> dinlenmeGeriSayim(int kalanSaniye) async {
    if (!SystemMemory.sesliKocAktif.value) return;
    if (kalanSaniye <= 3 && kalanSaniye >= 1) {
      await AudioSystem.playTransition();
      sonSesliMesaj.value = 'Son $kalanSaniye...';
    }
  }

  /// Dinlenme süresi bittiğinde sıradaki seti bildirir
  static Future<void> dinlenmeBitti({String? egzersizAdi}) async {
    if (!SystemMemory.sesliKocAktif.value) return;
    final hareket = egzersizAdi ?? 'Sıradaki hareket';
    await seslendir(
      'Sistem: Dinlenme süren doldu Avcı! $hareket seni bekliyor.',
      zilCal: true,
    );
  }

  /// Progressive Overload ağırlık artışı bildirimi
  static Future<void> overloadBildir(double yeniKilo, {required String egzersizAdi}) async {
    if (!SystemMemory.sesliKocAktif.value) return;
    await seslendir(
      'Sistem Direktifi: Gücün uyandı Avcı! $egzersizAdi ağırlığı ${yeniKilo.toStringAsFixed(1)} kg seviyesine yükseltildi.',
      levelUpCal: true,
    );
  }
}
