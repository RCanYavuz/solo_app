// lib/core/audio_system.dart
import 'package:audioplayers/audioplayers.dart';

class AudioSystem {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _transitionPlayer = AudioPlayer(); 

  static Future<void> playSuccess() async {
    await _player.stop();
    await _player.play(AssetSource('audio/success.mp3'));
  }

  static Future<void> playLevelUp() async {
    await _player.stop();
    await _player.play(AssetSource('audio/level_up.mp3'));
  }

  static Future<void> playBell() async {
    await _player.stop();
    await _player.play(AssetSource('audio/bell.mp3'));
  }

  // ===================================================
  // KUSURSUZ SAYFA VE MENÜ GEÇİŞ SESİ
  // ===================================================
  static Future<void> playTransition() async {
    // Sesi anında durdurur ve süreyi (00:00) konumuna zorla geri sarar.
    // Böylece alt menüde art arda 10 kere bile bassan her seferinde net çalar!
    await _transitionPlayer.stop();
    await _transitionPlayer.play(AssetSource('audio/transition.mp3'));
  }

  static Future<void> playStartup() async {
    final AudioPlayer startupPlayer = AudioPlayer();
    await startupPlayer.play(AssetSource('audio/startup.mp3'));
    startupPlayer.onPlayerComplete.listen((event) {
      startupPlayer.dispose();
    });
  }
}