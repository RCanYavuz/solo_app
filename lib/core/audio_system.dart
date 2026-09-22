import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioSystem {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _transitionPlayer = AudioPlayer(); 

  static bool get _isTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  // ===================================================
  // YENİ VERSİYON: ARKA PLAN MÜZİĞİNİ KESMEME AYARI
  // ===================================================
  static Future<void> init() async {
    if (_isTest) return;
    try {
      final audioContext = AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
      ).build();
      await AudioPlayer.global.setAudioContext(audioContext);
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    if (_isTest) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/success.mp3'));
    } catch (_) {}
  }

  static Future<void> playLevelUp() async {
    if (_isTest) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/level_up.mp3'));
    } catch (_) {}
  }

  static Future<void> playBell() async {
    if (_isTest) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/bell.mp3'));
    } catch (_) {}
  }

  static Future<void> playTransition() async {
    if (_isTest) return;
    try {
      await _transitionPlayer.stop();
      await _transitionPlayer.play(AssetSource('audio/transition.mp3'));
    } catch (_) {}
  }

  static Future<void> playButtonClick() async => playBell();
  static Future<void> playQuestComplete() async => playSuccess();
  static Future<void> playDungeonStart() async => playTransition();

  static Future<void> playStartup() async {
    if (_isTest) return;
    try {
      final AudioPlayer startupPlayer = AudioPlayer();
      await startupPlayer.play(AssetSource('audio/startup.mp3'));
      startupPlayer.onPlayerComplete.listen((event) {
        startupPlayer.dispose();
      });
    } catch (_) {}
  }
}