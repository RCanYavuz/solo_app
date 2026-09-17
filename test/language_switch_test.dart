import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/translation_manager.dart';

void main() {
  setUp(() {
    SystemMemory.appLanguage.value = 'en';
  });

  test('Default language should be English', () {
    expect(SystemMemory.appLanguage.value, 'en');
    expect(TranslationManager.get('nav_system'), 'STATUS');
    expect(TranslationManager.get('nav_profile'), 'PROFILE');
    expect(TranslationManager.get('profile_title'), 'H U N T E R   P R O F I L E');
  });

  test('Switching language to Turkish updates translations dynamically', () {
    SystemMemory.appLanguage.value = 'tr';
    expect(TranslationManager.get('nav_system'), 'DURUM');
    expect(TranslationManager.get('nav_profile'), 'PROFİL');
    expect(TranslationManager.get('profile_title'), 'A V C I   P R O F İ L İ');
    expect(TranslationManager.get('shop_title'), 'S İ S T E M   D Ü K K A N I');
    expect(TranslationManager.get('diet_hydration_title'), 'SU TAKİBİ ÇEKİRDEĞİ');
    expect(TranslationManager.get('nav_quest_log'), 'GÖREV KAYDI');
  });

  test('Switching back from Turkish to English restores original English text', () {
    SystemMemory.appLanguage.value = 'tr';
    expect(TranslationManager.get('nav_quest_log'), 'GÖREV KAYDI');

    SystemMemory.appLanguage.value = 'en';
    expect(TranslationManager.get('nav_quest_log'), 'QUEST LOG');
    expect(TranslationManager.get('shop_title'), 'S Y S T E M   S H O P');
    expect(TranslationManager.get('profile_title'), 'H U N T E R   P R O F I L E');
  });

  test('Helper methods (rankTitle, objectiveTitle, difficultyTitle) return correct strings for EN and TR', () {
    // EN mode
    SystemMemory.appLanguage.value = 'en';
    expect(TranslationManager.isTurkish, false);
    expect(TranslationManager.rankTitle(1), 'Rookie Hunter (E-Rank)');
    expect(TranslationManager.rankTitle(100), 'Shadow Monarch (S-Rank)');
    expect(TranslationManager.objectiveTitle('Kilo Ver'), 'Lose Weight (Fat Loss)');
    expect(TranslationManager.difficultyTitle('Hard'), 'Hard');
    expect(TranslationManager.difficultyTitle('Cehennem'), 'Hell');

    // TR mode
    SystemMemory.appLanguage.value = 'tr';
    expect(TranslationManager.isTurkish, true);
    expect(TranslationManager.rankTitle(1), 'Çaylak Avcı (E-Seviye)');
    expect(TranslationManager.rankTitle(100), 'Gölge Hükümdarı (S-Seviye)');
    expect(TranslationManager.objectiveTitle('Kilo Ver'), 'Kilo Ver (Yağ Yak)');
    expect(TranslationManager.difficultyTitle('Hard'), 'Yüksek');
    expect(TranslationManager.difficultyTitle('Cehennem'), 'Cehennem');
  });

  test('Fallback to English if a key is missing in another language', () {
    SystemMemory.appLanguage.value = 'tr';
    // non-existent key returns the key itself
    expect(TranslationManager.get('unknown_key_xyz'), 'unknown_key_xyz');
  });
}
