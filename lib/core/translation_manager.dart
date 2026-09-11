import 'package:flutter/material.dart';
import '../controllers/system_memory.dart';

class TranslationManager {
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'welcome_init': '[ SYSTEM WELCOME ]',
      'welcome_message': 'Congratulations, Hunter.\nScan completed.\nYou now have full access to the System.\n[CONFIRM TO AWAKEN]',
      'welcome_start': 'START SYSTEM',
      
      'instruction_title': '[ SYSTEM GUIDE ]',
      'instruction_subtitle': 'System integration successful. Please read the rules.',
      'instruction_r1_title': '1. DAILY RECKONING',
      'instruction_r1_desc': 'At the end of each day, the System performs an automated midnight reckoning. You will be rewarded (EXP/Stats) for completed quests and penalized (HP Loss) for neglected ones.',
      'instruction_r2_title': '2. LEVEL & ABILITIES',
      'instruction_r2_desc': 'Accumulate enough EXP to Level Up. Leveling up clears fatigue, restores HP/MP, and grants AP (Ability Points). Use these to upgrade your stats like STR, AGI, or INT.',
      'instruction_r3_title': '3. ENERGY & DIET',
      'instruction_r3_desc': 'The System has set a daily calorie limit based on your goal. Exceeding it will make your body sluggish, resulting in HP penalties. Log your intake in the \'INVENTORY\'.',
      'instruction_r4_title': '4. ENDLESS CYCLE',
      'instruction_r4_desc': 'Quests added to the Planner will repeat weekly on their assigned days until deleted. Track your history in the \'QUEST LOG\' and \'INVENTORY\' archives.',
      'instruction_r5_title': '5. THREAT OF DEATH',
      'instruction_r5_desc': 'If your HP (Health Points) drops to zero... You don\'t want to find out what happens. Survive and grow stronger.',
      'instruction_confirm': 'I UNDERSTAND AND ACCEPT THE RULES',
      
      'dash_status': 'S T A T U S',
      'dash_level': 'LEVEL',
      'dash_title': 'TITLE',
      'dash_energy': 'ENERGY',
      'dash_max': 'MAX',
      'dash_physical': 'PHYSICAL',
      'dash_achievements': 'ACHIEVEMENTS',
      'dash_dungeon_gate': 'DUNGEON GATE',
      'dash_boss_defeated': 'BOSS DEFEATED',
      'dash_boss_active': 'WARNING: BOSS ACTIVE',
      'dash_weakness_phy': 'Weakness: Physical Quests',
      'dash_weakness_men': 'Weakness: Mental Quests',
      'dash_gate_dormant': 'GATE IS DORMANT',
      'dash_boss_sunday': 'The Weekly Boss will appear on Sunday.',
      'dash_daily_quests': 'DAILY QUESTS',
      'dash_no_quests': 'No active quests.',
      'dash_phy': '[PHY]',
      'dash_mnt': '[MNT]',
      'dash_todays_dungeon': 'TODAY\'S DUNGEON LOGS',
      'dash_no_raids': 'No raids completed today.',
      'dash_enter_dungeon': 'ENTER DUNGEON (START WORKOUT)',
      
      'setup_age': 'Age',
      'setup_height': 'Height (cm)',
      'setup_weight': 'Weight (kg)',
      'setup_gender': 'Gender',
      'setup_male': 'Male',
      'setup_female': 'Female',
      'setup_objective': 'Objective',
      'setup_lose_weight': 'Lose Weight (Burn Fat)',
      'setup_maintain': 'Maintain Weight',
      'setup_gain_weight': 'Gain Weight (Build Muscle)',
      'setup_difficulty': 'Base Difficulty',
      'setup_diff_normal': 'Normal',
      'setup_diff_high': 'High',
      'setup_diff_hell': 'Hell',
      'setup_diff_monster': 'Monster',
      'setup_player_name': 'HUNTER NAME (Optional)',
      'setup_api_key': 'GEMINI API KEY (Optional - AI Coach)',
      'setup_start_button': 'START INITIALIZATION',
      'setup_dialog_title': 'SYSTEM',
      'setup_dialog_content': 'Please enter a valid age, height and weight!',
      
      // Additional general UI strings will be added here
      'cancel': 'CANCEL',
      'ok': 'OK',
    },
    'tr': {
      // Welcome Screen
      'welcome_init': '[ SİSTEM KARŞILAMASI ]',
      'welcome_message': 'Tebrikler, Avcı.\nTarama tamamlandı.\nArtık Sisteme tam erişiminiz var.\n[UYANMAK İÇİN ONAYLA]',
      'welcome_start': 'SİSTEMİ BAŞLAT',
      
      'instruction_title': '[ SİSTEM REHBERİ ]',
      'instruction_subtitle': 'Sistem entegrasyonu başarılı. Lütfen kuralları okuyun.',
      'instruction_r1_title': '1. GÜNLÜK HESAPLAŞMA',
      'instruction_r1_desc': 'Her günün sonunda Sistem otomatik gece yarısı hesaplaşması yapar. Tamamlanan görevler için ödüllendirilir (EXP/Stat), iptal edilenler için cezalandırılırsın (HP Kaybı).',
      'instruction_r2_title': '2. SEVİYE & YETENEKLER',
      'instruction_r2_desc': 'Seviye atlamak için yeterli EXP topla. Seviye atlamak yorgunluğu siler, HP/MP yeniler ve AP (Yetenek Puanı) verir. Bunları STR, AGI, veya INT artırmak için kullan.',
      'instruction_r3_title': '3. ENERJİ & DİYET',
      'instruction_r3_desc': 'Sistem hedefine uygun bir günlük kalori limiti belirledi. Bunu aşmak bedenini yavaşlatır, HP cezası alırsın. Tüketimini \'ENVANTER\' bölümüne kaydet.',
      'instruction_r4_title': '4. SONSUZ DÖNGÜ',
      'instruction_r4_desc': 'Planlayıcıya eklenen görevler, silinene kadar her hafta tekrarlanır. Geçmişini \'GÖREV KAYDI\' ve \'ENVANTER\' arşivlerinden takip edebilirsin.',
      'instruction_r5_title': '5. ÖLÜM TEHDİDİ',
      'instruction_r5_desc': 'Eğer HP (Can Puanı) sıfıra düşerse... Ne olacağını öğrenmek istemezsin. Hayatta kal ve güçlen.',
      'instruction_confirm': 'KURALLARI ANLADIM VE KABUL EDİYORUM',
      
      'dash_status': 'D U R U M',
      'dash_level': 'SEVİYE',
      'dash_title': 'ÜNVAN',
      'dash_energy': 'ENERJİ',
      'dash_max': 'MAKS',
      'dash_physical': 'FİZİKSEL',
      'dash_achievements': 'BAŞARIMLAR',
      'dash_dungeon_gate': 'ZİNDAN GEÇİDİ',
      'dash_boss_defeated': 'BOSS MAĞLUP EDİLDİ',
      'dash_boss_active': 'UYARI: BOSS AKTİF',
      'dash_weakness_phy': 'Zayıflık: Fiziksel Görevler',
      'dash_weakness_men': 'Zayıflık: Zihinsel Görevler',
      'dash_gate_dormant': 'GEÇİT UYKUTDA',
      'dash_boss_sunday': 'Haftalık Boss Pazar günü ortaya çıkacak.',
      'dash_daily_quests': 'GÜNLÜK GÖREVLER',
      'dash_no_quests': 'Aktif görev yok.',
      'dash_phy': '[FİZ]',
      'dash_mnt': '[ZİH]',
      'dash_todays_dungeon': 'BUGÜNKÜ ZİNDAN KAYITLARI',
      'dash_no_raids': 'Bugün zindan akını yapılmadı.',
      'dash_enter_dungeon': 'ZİNDANA GİR (İDMANA BAŞLA)',
      
      // Setup Screen
      'setup_title': 'S İ S T E M   B A Ş L A T I L I Y O R',
      'setup_age': 'Yaş',
      'setup_height': 'Boy (cm)',
      'setup_weight': 'Kilo (kg)',
      'setup_gender': 'Cinsiyet',
      'setup_male': 'Erkek',
      'setup_female': 'Kadın',
      'setup_objective': 'Hedef',
      'setup_lose_weight': 'Kilo Ver (Yağ Yak)',
      'setup_maintain': 'Kilo Koru (Dengede Kal)',
      'setup_gain_weight': 'Kilo Al (Kas İnşa Et)',
      'setup_difficulty': 'Temel Zorluk',
      'setup_diff_normal': 'Normal',
      'setup_diff_high': 'Yüksek',
      'setup_diff_hell': 'Cehennem',
      'setup_diff_monster': 'Canavar',
      'setup_player_name': 'AVCI ADI (İsteğe Bağlı)',
      'setup_api_key': 'GEMINI API KEY (İsteğe Bağlı - Yapay Zeka Koçu)',
      'setup_start_button': 'BAŞLAT',
      'setup_dialog_title': 'SİSTEM',
      'setup_dialog_content': 'Lütfen geçerli bir yaş, boy ve kilo girin!',
      
      'cancel': 'İPTAL',
      'ok': 'TAMAM',
    }
  };

  static String get(String key) {
    String currentLang = SystemMemory.appLanguage.value;
    if (!_localizedStrings.containsKey(currentLang)) {
      currentLang = 'en';
    }
    return _localizedStrings[currentLang]?[key] ?? key;
  }
}
