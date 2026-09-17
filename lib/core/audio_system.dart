// lib/core/audio_system.dart
import 'package:audioplayers/audioplayers.dart';

class AudioSystem {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _transitionPlayer = AudioPlayer(); 

  // ===================================================
  // YENİ VERSİYON: ARKA PLAN MÜZİĞİNİ KESMEME AYARI
  // ===================================================
  static Future<void> init() async {
    // Yeni audioplayers paketinde doğrudan Config kullanılır.
    // mixWithOthers: iOS'ta diğer müziklerle karıştırır, Android'de "AudioFocus" (odak) almaz.
    final audioContext = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    
    await AudioPlayer.global.setAudioContext(audioContext);
  }

  static Future<void> playSuccess() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/success.mp3'));
    } catch (_) {}
  }

  static Future<void> playLevelUp() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/level_up.mp3'));
    } catch (_) {}
  }

  static Future<void> playBell() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/bell.mp3'));
    } catch (_) {}
  }

  // ===================================================
  // KUSURSUZ SAYFA VE MENÜ GEÇİŞ SESİ
  // ===================================================
  static Future<void> playTransition() async {
    try {
      // Sesi anında durdurur ve süreyi (00:00) konumuna zorla geri sarar.
      await _transitionPlayer.stop();
      await _transitionPlayer.play(AssetSource('audio/transition.mp3'));
    } catch (_) {}
  }

  static Future<void> playStartup() async {
    try {
      final AudioPlayer startupPlayer = AudioPlayer();
      await startupPlayer.play(AssetSource('audio/startup.mp3'));
      startupPlayer.onPlayerComplete.listen((event) {
        startupPlayer.dispose();
      });
    } catch (_) {}
  }
}