import 'package:audioplayers/audioplayers.dart';

class AudioSystem {
  // Sesi çalacak olan oynatıcı motorumuz
  static final AudioPlayer _player = AudioPlayer();

  // 1. Görev Tamamlama / Başarılı Tıklama Sesi
  static Future<void> playSuccess() async {
    await _player.play(AssetSource('audio/success.mp3'));
  }

  // 2. Seviye Atlama (Level Up) Sesi
  static Future<void> playLevelUp() async {
    await _player.play(AssetSource('audio/level_up.mp3'));
  }

  // 3. Boks Zili Sesi
  static Future<void> playBell() async {
    await _player.play(AssetSource('audio/bell.mp3'));
  }
}