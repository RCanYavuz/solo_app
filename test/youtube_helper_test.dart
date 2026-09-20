import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_app/core/youtube_helper.dart';

void main() {
  group('YoutubeHelper Testleri', () {
    test('Dövüş sporu ve set bilgisi içeren görev adını temizler', () {
      final input = '[COMBAT] Boks: Patlayıcı İtiş & Plyo Şınav (4 Set x 8 Tekrar)';
      final output = YoutubeHelper.gorevAdiniTemizle(input);
      expect(output.contains('[COMBAT]'), isFalse);
      expect(output.contains('4 Set x 8 Tekrar'), isFalse);
      expect(output.contains('Boks Patlayıcı İtiş & Plyo Şınav'), isTrue);
      expect(output.endsWith('egzersizi nasıl yapılır form'), isTrue);
    });

    test('Tekrar sayısı ve hedef içeren görevleri temizler', () {
      final input = '[CHEST] 100 Push-ups';
      final output = YoutubeHelper.gorevAdiniTemizle(input);
      expect(output.contains('[CHEST]'), isFalse);
      expect(output.contains('Push-ups'), isTrue);
      expect(output.endsWith('egzersizi nasıl yapılır form'), isTrue);
    });

    test('Kas bölgesi bilgisi içeren push görevini temizler', () {
      final input = '[PHY] Push (Chest/Shoulders/Triceps)';
      final output = YoutubeHelper.gorevAdiniTemizle(input);
      expect(output.contains('[PHY]'), isFalse);
      expect(output.contains('Push Chest Shoulders Triceps'), isTrue);
      expect(output.endsWith('egzersizi nasıl yapılır form'), isTrue);
    });

    test('Plank süresi içeren görevleri temizler', () {
      final input = '[CORE / ABS] Plank (3 Min)';
      final output = YoutubeHelper.gorevAdiniTemizle(input);
      expect(output.contains('[CORE / ABS]'), isFalse);
      expect(output.contains('3 Min'), isFalse);
      expect(output.contains('Plank'), isTrue);
      expect(output.endsWith('egzersizi nasıl yapılır form'), isTrue);
    });
  });
}
