import '../controllers/system_memory.dart';

class TranslationManager {
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      // Welcome Screen
      'welcome_init': '[ SYSTEM WELCOME ]',
      'welcome_message': 'Congratulations, Hunter.\nScan completed.\nYou now have full access to the System.\n[CONFIRM TO AWAKEN]',
      'welcome_start': 'START SYSTEM',
      
      // Guide / Instructions
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
      
      // Bottom Navigation
      'nav_dashboard': 'DASHBOARD',
      'nav_system': 'STATUS',
      'nav_quest_log': 'QUEST LOG',
      'nav_inventory': 'INVENTORY',
      'nav_profile': 'PROFILE',
      
      // Dashboard
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
      'dash_raid_at': 'Dungeon Raid at',
      'dash_duration': 'Duration',
      'dash_min': 'Min',
      'dash_quests_done': 'Quests Done',
      'dash_store_tooltip': 'System Shop',

      // Achievements
      'ach_iron_will': 'Iron Will',
      'ach_unbreakable': 'Unbreakable',
      'ach_awakening': 'Awakening',
      'ach_warrior': 'Warrior',
      'ach_shadow_step': 'Shadow Step',
      'ach_sage': 'Sage',
      'ach_merchant': 'Merchant',
      'ach_titan': 'Titan',
      'ach_fat_burner': 'Fat Burner',
      'ach_day_streak': 'Day Streak',
      'ach_quests_done': 'Quests Done',
      'ach_reach': 'Reach',
      'ach_kg_change': 'KG Change',

      // Ranks
      'rank_rookie': 'Rookie Hunter (E-Rank)',
      'rank_experienced': 'Experienced Hunter (C-Rank)',
      'rank_elite': 'Elite Hunter (B-Rank)',
      'rank_national': 'National Level Hunter (A-Rank)',
      'rank_shadow_monarch': 'Shadow Monarch (S-Rank)',
      'rank_unranked': 'Unranked',
      
      // Status Screen
      'status_title': 'S T A T U S',
      'status_sleep_title': 'Sleep Duration (Hrs)',
      'status_ap_available': 'AP AVAILABLE',
      'status_available_pts': 'Available Pts:',
      'status_upgradable': 'UPGRADE STATS',
      'status_requirements': 'REQUIREMENTS',
      'status_quests': 'QUESTS',
      'status_no_quests': 'No quests today.',
      'status_workout_lib_tooltip': 'Workout Library',
      'status_combat_sim_tooltip': 'Combat Simulation',
      
      // Profile Screen
      'profile_title': 'H U N T E R   P R O F I L E',
      'profile_awaken_avatar': 'AWAKEN AVATAR',
      'profile_reawaken_avatar': 'RE-AWAKEN AVATAR',
      'profile_rename_tooltip': 'Rename Hunter',
      'profile_physical_specs': 'PHYSICAL SPECS',
      'profile_height': 'HEIGHT',
      'profile_weight': 'WEIGHT',
      'profile_age': 'AGE',
      'profile_weight_log_tooltip': 'Weight Log',
      'profile_body_class': 'Body Class:',
      'profile_rank': 'Rank:',
      'profile_take_test': 'TAKE AWAKENING TEST',
      'profile_protocol': 'SYSTEM PROTOCOL',
      'profile_override_tooltip': 'Override Protocol',
      'profile_main_objective': 'Main Objective',
      'profile_difficulty': 'Dungeon Difficulty',
      'profile_daily_cal_limit': 'Daily Calorie Limit:',
      'profile_red_gate_cal_limit': 'Red Gate Calorie Limit:',
      'profile_stealth_mode': 'Stealth Mode (Real World Focus)',
      'profile_stealth_desc_active': 'System Dormant. Penalties suspended.',
      'profile_stealth_desc_red': 'LOCKED. Cannot hide in Red Gate.',
      'profile_allometric_strength': 'ALLOMETRIC STRENGTH (1RM)',
      'profile_stats_title': 'HUNTER STATS',
      'profile_calc_1rm': 'CALCULATE 1RM',
      'profile_data_vault': 'DATA VAULT / ARCHIVE',
      'profile_backup_export': 'EXPORT BACKUP',
      'profile_backup_import': 'RESTORE BACKUP',
      'profile_audio_title': 'SYSTEM AUDIO',
      'profile_audio_desc': 'Sound FX and ambient feedback',
      'profile_lang_title': 'SYSTEM LANGUAGE',
      'profile_lang_desc': 'Switch interface language',
      'profile_ai_core': 'AI CORE / GEMINI',
      'profile_reset_system': 'RETRACT / RESET SYSTEM',
      'profile_awakening_date': 'Awakening Date',
      'profile_streak': 'Day Streak',
      'profile_completed_quests': 'Quests Cleared',
      'profile_dungeon_time': 'Total Dungeon Time',
      'profile_bench': 'Bench Press',
      'profile_squat': 'Squat',
      'profile_deadlift': 'Deadlift',
      'profile_change_photo': 'Change Photo',
      'profile_red_gate_active': 'RED GATE ACTIVE',
      'profile_days_remaining': 'DAYS REMAINING',
      'profile_red_gate_desc': 'Survive this hell to claim the ultimate power.',
      'profile_flee_gate': 'FLEE GATE (GIVE UP)',
      'profile_open_red_gate': 'OPEN RED GATE (CUSTOM)',
      'profile_system_update': 'SYSTEM UPDATE',
      'profile_system_reset': 'SYSTEM RESET (WIPE DATA)',
      'profile_weight_records_empty': 'No records found.',
      'profile_weight_history_title': 'WEIGHT LOG',
      
      // Objectives
      'obj_lose_weight': 'Lose Weight (Fat Loss)',
      'obj_build_muscle': 'Build Muscle (Hypertrophy)',
      'obj_maintain': 'Maintain Current Weight',

      // Difficulties
      'diff_normal': 'Normal',
      'diff_high': 'Hard',
      'diff_hell': 'Hell',
      'diff_monster': 'Monster',

      // Diet / Nutrition
      'diet_title': 'I N V E N T O R Y',
      'diet_energy_gauge': 'ENERGY GAUGE',
      'diet_daily_limit': 'Daily Limit:',
      'diet_access_macro_lab': 'ACCESS NUTRITION & MACRO LAB',
      'diet_macro_lab_tooltip': 'Macro Lab',
      'diet_archive_tooltip': 'Diet Archive',
      'diet_todays_inventory': 'TODAY\'S INVENTORY',
      'diet_add_item_btn': 'ADD ITEM',
      'diet_inventory_empty': 'Inventory is empty. Fuel up, Hunter.',
      'diet_hydration_title': 'HYDRATION CORE',
      'diet_hydration_goal': 'Hydration Goal Achieved',
      'diet_water_reset': 'Reset Water',
      'diet_consumed_today': 'CONSUMED TODAY',
      'diet_no_meals': 'No rations recorded yet today.',
      
      // Diet Add Item Dialog
      'diet_dialog_title': 'ADD INVENTORY ITEM',
      'diet_ai_decoder': 'AI DECODER (GEMINI)',
      'diet_ai_hint': 'e.g. 2 eggs, 1 slice bread, 50g cheese (optional if photo is given)',
      'diet_attach_photo': 'ATTACH PHOTO',
      'diet_photo_attached': 'PHOTO ATTACHED',
      'diet_decode_ai': 'DECODE WITH AI',
      'diet_decoding': 'DECODING...',
      'diet_item_details': 'ITEM DETAILS',
      'diet_item_name': 'Item Name (Food)',
      'diet_protein': 'Protein',
      'diet_carb': 'Carb',
      'diet_fat': 'Fat',
      'diet_energy_kcal': 'Energy (Kcal)',
      'diet_archive_title': 'DIET ARCHIVE',
      'diet_archive_empty': 'No records found in the vault.',
      'diet_total_energy': 'Total Energy',
      'diet_no_specific_items': 'No specific items recorded.',
      'diet_warning_valid_item': 'SYSTEM WARNING: Enter valid item name and calorie amount!',

      // Shop
      'shop_title': 'S Y S T E M   S H O P',
      'shop_gold': 'GOLD',
      'shop_bag_title': 'HUNTER\'S BAG',
      'shop_empty_bag': 'Your bag is empty.\nPurchase equipment or passes from the Shop.',
      'shop_buy_btn': 'BUY',
      'shop_use_btn': 'USE',
      'shop_insufficient_gold': 'SYSTEM WARNING: Insufficient Gold.',
      'shop_stored_in_bag': 'stored in Hunter\'s Bag!',
      'shop_open_bag': 'OPEN BAG',
      'shop_items_count': 'Items',
      
      // Calendar / Quest Log
      'calendar_title': 'Q U E S T   L O G',
      'calendar_strip': 'Strip',
      'calendar_month': 'Month',
      'calendar_year': 'Year',
      'calendar_protocol': 'SYSTEM QUEST PROTOCOL',
      'calendar_dungeon_logs': 'DUNGEON LOGS',
      'calendar_rest_day': 'REST DAY.\nNo quests planned.',
      'calendar_no_raids': 'No dungeon raids recorded for this date.',
      'calendar_energy': 'ENERGY',
      'calendar_logged_energy': 'LOGGED ENERGY',
      'calendar_target': 'TARGET',
      'calendar_raid_at': 'Raid at',

      // Workout Planner
      'planner_title': 'Q U E S T   P L A N N E R',
      'planner_select_days': 'SELECT DAYS TO SYNC',
      'planner_category': 'Category',
      'planner_physical': 'PHYSICAL (STR/AGI)',
      'planner_mental': 'MENTAL (INT/PER)',
      'planner_target_area': 'TARGET AREA',
      'planner_exercise_hint': 'Quest Name (e.g. 50 Push-ups)...',
      'planner_add_btn': 'ADD QUEST TO PROTOCOL',
      'planner_library_btn': 'BROWSE EXERCISE LIBRARY',
      'planner_ai_btn': 'AI SMART TRAINER',
      'planner_templates': 'SYSTEM TEMPLATES',
      'planner_no_quests': 'No quests assigned.',

      // Macro Lab
      'macro_title': 'N U T R I T I O N   L A B',
      'macro_distribution': 'MACRO DISTRIBUTION',
      'macro_protein': 'Protein',
      'macro_carbs': 'Carbs',
      'macro_fats': 'Fats',
      'macro_fiber': 'Fiber',
      'macro_body_scan': 'BODY SCAN INPUT',
      'macro_burn_fat': 'BURN FAT',
      'macro_build_muscle': 'BUILD MUSCLE',
      'macro_analyze': 'ANALYZE MACROS',
      'macro_daily_target': 'DAILY ENERGY TARGET',
      'macro_meal_plan': 'MEAL PLAN',
      'macro_disclaimer': 'This plan provides estimates. Adjust portions according to your personal needs.',
      
      // Common
      'cancel': 'CANCEL',
      'ok': 'OK',
      'confirm': 'CONFIRM',
      'close': 'CLOSE',
      'save': 'SAVE',
      'edit': 'EDIT',
    },
    'tr': {
      // Welcome Screen
      'welcome_init': '[ SİSTEM KARŞILAMASI ]',
      'welcome_message': 'Tebrikler, Avcı.\nTarama tamamlandı.\nArtık Sisteme tam erişiminiz var.\n[UYANMAK İÇİN ONAYLA]',
      'welcome_start': 'SİSTEMİ BAŞLAT',
      
      // Guide / Instructions
      'instruction_title': '[ SİSTEM REHBERİ ]',
      'instruction_subtitle': 'Sistem entegrasyonu başarılı. Lütfen kuralları okuyun.',
      'instruction_r1_title': '1. GÜNLÜK HESAPLAŞMA',
      'instruction_r1_desc': 'Her günün sonunda Sistem otomatik gece yarısı hesaplaşması yapar. Tamamlanan görevler için ödüllendirilir (EXP/Stat), ihmal edilenler için cezalandırılırsın (HP Kaybı).',
      'instruction_r2_title': '2. SEVİYE & YETENEKLER',
      'instruction_r2_desc': 'Seviye atlamak için yeterli EXP topla. Seviye atlamak yorgunluğu siler, HP/MP yeniler ve AP (Yetenek Puanı) verir. Bunları STR, AGI veya INT artırmak için kullan.',
      'instruction_r3_title': '3. ENERJİ & DİYET',
      'instruction_r3_desc': 'Sistem hedefine uygun bir günlük kalori limiti belirledi. Bunu aşmak bedenini yavaşlatır, HP cezası alırsın. Tüketimini \'ENVANTER\' bölümüne kaydet.',
      'instruction_r4_title': '4. SONSUZ DÖNGÜ',
      'instruction_r4_desc': 'Planlayıcıya eklenen görevler, silinene kadar her hafta tekrarlanır. Geçmişini \'GÖREV KAYDI\' ve \'ENVANTER\' arşivlerinden takip edebilirsin.',
      'instruction_r5_title': '5. ÖLÜM TEHDİDİ',
      'instruction_r5_desc': 'Eğer HP (Can Puanı) sıfıra düşerse... Ne olacağını öğrenmek istemezsin. Hayatta kal ve güçlen.',
      'instruction_confirm': 'KURALLARI ANLADIM VE KABUL EDİYORUM',
      
      // Bottom Navigation
      'nav_dashboard': 'GÖSTERGE',
      'nav_system': 'DURUM',
      'nav_quest_log': 'GÖREV KAYDI',
      'nav_inventory': 'ENVANTER',
      'nav_profile': 'PROFİL',
      
      // Dashboard
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
      'dash_gate_dormant': 'GEÇİT UYKUDA',
      'dash_boss_sunday': 'Haftalık Boss Pazar günü ortaya çıkacak.',
      'dash_daily_quests': 'GÜNLÜK GÖREVLER',
      'dash_no_quests': 'Aktif görev yok.',
      'dash_phy': '[FİZ]',
      'dash_mnt': '[ZİH]',
      'dash_todays_dungeon': 'BUGÜNKÜ ZİNDAN KAYITLARI',
      'dash_no_raids': 'Bugün zindan akını yapılmadı.',
      'dash_enter_dungeon': 'ZİNDANA GİR (İDMANA BAŞLA)',
      'dash_raid_at': 'Zindan Akını: Saat',
      'dash_duration': 'Süre',
      'dash_min': 'Dk',
      'dash_quests_done': 'Biten Görev',
      'dash_store_tooltip': 'Sistem Marketi',

      // Achievements
      'ach_iron_will': 'Demir İrade',
      'ach_unbreakable': 'Kırılmaz',
      'ach_awakening': 'Uyanış',
      'ach_warrior': 'Savaşçı',
      'ach_shadow_step': 'Gölge Adımı',
      'ach_sage': 'Bilge',
      'ach_merchant': 'Tüccar',
      'ach_titan': 'Titan',
      'ach_fat_burner': 'Yağ Yakıcı',
      'ach_day_streak': 'Günlük Seri',
      'ach_quests_done': 'Görev Bitti',
      'ach_reach': 'Hedef:',
      'ach_kg_change': 'KG Değişim',

      // Ranks
      'rank_rookie': 'Çaylak Avcı (E-Seviye)',
      'rank_experienced': 'Kıdemli Avcı (C-Seviye)',
      'rank_elite': 'Seçkin Avcı (B-Seviye)',
      'rank_national': 'Ulusal Düzey Avcı (A-Seviye)',
      'rank_shadow_monarch': 'Gölge Hükümdarı (S-Seviye)',
      'rank_unranked': 'Derecesiz',
      
      // Status Screen
      'status_title': 'D U R U M',
      'status_sleep_title': 'Uyku Süresi (Saat)',
      'status_ap_available': 'KULLANILABİLİR AP',
      'status_available_pts': 'Kullanılabilir Puan:',
      'status_upgradable': 'STATÜ YÜKSELT',
      'status_requirements': 'GEREKSİNİMLER',
      'status_quests': 'GÖREVLER',
      'status_no_quests': 'Bugün için görev yok.',
      'status_workout_lib_tooltip': 'Antrenman Kütüphanesi',
      'status_combat_sim_tooltip': 'Dövüş Simülasyonu',
      
      // Profile Screen
      'profile_title': 'A V C I   P R O F İ L İ',
      'profile_awaken_avatar': 'AVATARI UYANDIR',
      'profile_reawaken_avatar': 'AVATARI YENİDEN UYANDIR',
      'profile_rename_tooltip': 'Avcıyı Yeniden Adlandır',
      'profile_physical_specs': 'FİZİKSEL VERİLER',
      'profile_height': 'BOY',
      'profile_weight': 'KİLO',
      'profile_age': 'YAŞ',
      'profile_weight_log_tooltip': 'Kilo Geçmişi',
      'profile_body_class': 'Vücut Tipi:',
      'profile_rank': 'Rütbe:',
      'profile_take_test': 'UYANIŞ TESTİNİ BAŞLAT',
      'profile_protocol': 'SİSTEM PROTOKOLÜ',
      'profile_override_tooltip': 'Protokolü Değiştir',
      'profile_main_objective': 'Ana Hedef',
      'profile_difficulty': 'Zindan Zorluğu',
      'profile_daily_cal_limit': 'Günlük Kalori Limiti:',
      'profile_red_gate_cal_limit': 'Kızıl Geçit Kalori Limiti:',
      'profile_stealth_mode': 'Gizlilik Modu (Gerçek Dünya Odaklı)',
      'profile_stealth_desc_active': 'Sistem Uykuda. Cezalar askıya alındı.',
      'profile_stealth_desc_red': 'KİLİTLİ. Kızıl Geçitte saklanamazsın.',
      'profile_allometric_strength': 'ALLOMETRİK GÜÇ (1RM)',
      'profile_stats_title': 'AVCI STATÜLERİ',
      'profile_calc_1rm': '1RM HESAPLA',
      'profile_data_vault': 'VERİ KASASI / ARŞİV',
      'profile_backup_export': 'YEDEK DIŞA AKTAR',
      'profile_backup_import': 'YEDEKTEN GERİ YÜKLE',
      'profile_audio_title': 'SİSTEM SESLERİ',
      'profile_audio_desc': 'Ses efektleri ve ortam geri bildirimi',
      'profile_lang_title': 'SİSTEM DİLİ',
      'profile_lang_desc': 'Arayüz dilini değiştir',
      'profile_ai_core': 'YAPAY ZEKA ÇEKİRDEĞİ (GEMINI)',
      'profile_reset_system': 'SİSTEMİ SIFIRLA / ÇEKİL',
      'profile_awakening_date': 'Uyanış Tarihi',
      'profile_streak': 'Günlük Seri',
      'profile_completed_quests': 'Biten Görev',
      'profile_dungeon_time': 'Toplam Zindan Süresi',
      'profile_bench': 'Bench Press',
      'profile_squat': 'Squat',
      'profile_deadlift': 'Deadlift',
      'profile_change_photo': 'Fotoğrafı Değiştir',
      'profile_red_gate_active': 'KIZIL GEÇİT AKTİF',
      'profile_days_remaining': 'GÜN KALDI',
      'profile_red_gate_desc': 'Mutlak güce ulaşmak için bu cehennemde hayatta kal.',
      'profile_flee_gate': 'GEÇİTTEN KAÇ (VAZGEÇ)',
      'profile_open_red_gate': 'KIZIL GEÇİT AÇ (ÖZEL)',
      'profile_system_update': 'SİSTEMİ GÜNCELLE',
      'profile_system_reset': 'SİSTEMİ SIFIRLA (VERİLERİ SİL)',
      'profile_weight_records_empty': 'Kayıt bulunamadı.',
      'profile_weight_history_title': 'KİLO GEÇMİŞİ',
      
      // Objectives
      'obj_lose_weight': 'Kilo Ver (Yağ Yak)',
      'obj_build_muscle': 'Kilo Al (Kas İnşa Et)',
      'obj_maintain': 'Mevcut Kilonu Koru',

      // Difficulties
      'diff_normal': 'Normal',
      'diff_high': 'Zor',
      'diff_hell': 'Cehennem',
      'diff_monster': 'Canavar',

      // Diet / Nutrition
      'diet_title': 'E N V A N T E R',
      'diet_energy_gauge': 'ENERJİ GÖSTERGESİ',
      'diet_daily_limit': 'Günlük Limit:',
      'diet_access_macro_lab': 'BESLENME & MAKRO LABORATUVARI',
      'diet_macro_lab_tooltip': 'Makro Laboratuvarı',
      'diet_archive_tooltip': 'Beslenme Arşivi',
      'diet_todays_inventory': 'BUGÜNKÜ ENVANTER',
      'diet_add_item_btn': 'BESİN EKLE',
      'diet_inventory_empty': 'Envanter boş. Güç topla, Avcı.',
      'diet_hydration_title': 'SU TAKİBİ ÇEKİRDEĞİ',
      'diet_hydration_goal': 'Su Hedefine Ulaşıldı',
      'diet_water_reset': 'Suyu Sıfırla',
      'diet_consumed_today': 'BUGÜN TÜKETİLENLER',
      'diet_no_meals': 'Bugün henüz besin kaydedilmedi.',
      
      // Diet Add Item Dialog
      'diet_dialog_title': 'YENİ ENVANTER KAYDI',
      'diet_ai_decoder': 'YAPAY ZEKA BESİN ÇÖZÜCÜ',
      'diet_ai_hint': 'örn: 2 yumurta, 1 dilim ekmek, 50g peynir (fotoğraf varsa isteğe bağlı)',
      'diet_attach_photo': 'FOTOĞRAF EKLE',
      'diet_photo_attached': 'FOTOĞRAF EKLENDİ',
      'diet_decode_ai': 'YAPAY ZEKA İLE ÇÖZÜMLE',
      'diet_decoding': 'ÇÖZÜMLENİYOR...',
      'diet_item_details': 'BESİN DETAYLARI',
      'diet_item_name': 'Besin Adı',
      'diet_protein': 'Protein',
      'diet_carb': 'Karb',
      'diet_fat': 'Yağ',
      'diet_energy_kcal': 'Enerji (Kcal)',
      'diet_archive_title': 'BESLENME ARŞİVİ',
      'diet_archive_empty': 'Kasada kayıt bulunamadı.',
      'diet_total_energy': 'Toplam Enerji',
      'diet_no_specific_items': 'Detaylı besin kaydedilmedi.',
      'diet_warning_valid_item': 'SİSTEM UYARISI: Geçerli bir besin adı ve kalori miktarı girin!',

      // Shop
      'shop_title': 'S İ S T E M   D Ü K K A N I',
      'shop_gold': 'ALTIN',
      'shop_bag_title': 'AVCI ÇANTASI',
      'shop_empty_bag': 'Çantanız boş.\nSistem Dükkanından teçhizat veya bilet alabilirsiniz.',
      'shop_buy_btn': 'SATIN AL',
      'shop_use_btn': 'KULLAN',
      'shop_insufficient_gold': 'SİSTEM UYARISI: Yetersiz Altın.',
      'shop_stored_in_bag': 'Avcı Çantasına eklendi!',
      'shop_open_bag': 'ÇANTAYI AÇ',
      'shop_items_count': 'Eşya',
      
      // Calendar / Quest Log
      'calendar_title': 'G Ö R E V   K A Y D I',
      'calendar_strip': 'Şerit',
      'calendar_month': 'Aylık',
      'calendar_year': 'Yıllık',
      'calendar_protocol': 'SİSTEM GÖREV PROTOKOLÜ',
      'calendar_dungeon_logs': 'ZİNDAN KAYITLARI',
      'calendar_rest_day': 'DİNLENME GÜNÜ.\nPlanlanmış görev yok.',
      'calendar_no_raids': 'Bu tarih için kayıtlı zindan akını yok.',
      'calendar_energy': 'ENERJİ',
      'calendar_logged_energy': 'KAYITLI ENERJİ',
      'calendar_target': 'HEDEF',
      'calendar_raid_at': 'Akın Saati:',

      // Workout Planner
      'planner_title': 'G Ö R E V   P L A N L A Y I C I',
      'planner_select_days': 'SENKRONİZE EDİLECEK GÜNLER',
      'planner_category': 'Kategori',
      'planner_physical': 'FİZİKSEL (GÜÇ/ÇEV)',
      'planner_mental': 'ZİHİNSEL (ZEKA/SEZ)',
      'planner_target_area': 'HEDEF BÖLGE',
      'planner_exercise_hint': 'Görev Adı (örn: 50 Şınav)...',
      'planner_add_btn': 'GÖREVİ PROTOKOLE EKLE',
      'planner_library_btn': 'ANTRENMAN KÜTÜPHANESİ',
      'planner_ai_btn': 'YAPAY ZEKA ANTRENÖRÜ',
      'planner_templates': 'SİSTEM ŞABLONLARI',
      'planner_no_quests': 'Atanmış görev yok.',

      // Macro Lab
      'macro_title': 'B E S L E N M E   L A B O R A T U V A R I',
      'macro_distribution': 'GÜNLÜK MAKRO DAĞILIMI',
      'macro_protein': 'Protein',
      'macro_carbs': 'Karbonhidrat',
      'macro_fats': 'Yağ',
      'macro_fiber': 'Lif',
      'macro_body_scan': 'VÜCUT TARAMA GİRDİSİ',
      'macro_burn_fat': 'YAĞ YAKMA',
      'macro_build_muscle': 'KAS İNŞA ET',
      'macro_analyze': 'MAKROLARI ANALİZ ET',
      'macro_daily_target': 'GÜNLÜK ENERJİ HEDEFİ',
      'macro_meal_plan': 'ÖĞÜN PLANI',
      'macro_disclaimer': 'Bu plan tahmini değerler sunar. Porsiyonları kişisel ihtiyaçlarınıza göre ayarlayın.',
      
      // Common
      'cancel': 'İPTAL',
      'ok': 'TAMAM',
      'confirm': 'ONAYLA',
      'close': 'KAPAT',
      'save': 'KAYDET',
      'edit': 'DÜZENLE',
    }
  };

  static String get(String key) {
    String currentLang = SystemMemory.appLanguage.value;
    if (!_localizedStrings.containsKey(currentLang)) {
      currentLang = 'en';
    }
    return _localizedStrings[currentLang]?[key] ?? key;
  }

  static String tr(String key) => get(key);

  static bool get isTurkish => SystemMemory.appLanguage.value == 'tr';

  static String rankTitle(int level, [String? hunterRank, bool? isCombat]) {
    final rank = hunterRank ?? SystemMemory.hunterRank;
    final combat = isCombat ?? SystemMemory.dovusSporuYapiyorMu;
    final rUpper = rank.toUpperCase();

    if (rank != "Unranked") {
      if (rUpper.startsWith('S')) {
        return combat 
            ? (isTurkish ? "Zirve Dövüş Hükümdarı (S-Rank)" : "Apex Combat Monarch (S-Rank)")
            : (isTurkish ? "Gölge Hükümdarı (S-Rank)" : "Shadow Monarch (S-Rank)");
      }
      if (rUpper.startsWith('A')) {
        return combat 
            ? (isTurkish ? "Usta Dövüşçü (A-Rank)" : "Master Striker (A-Rank)")
            : (isTurkish ? "Ulusal Düzey Avcı (A-Rank)" : "National Level Hunter (A-Rank)");
      }
      if (rUpper.startsWith('B')) {
        return combat 
            ? (isTurkish ? "Seçkin Boksör / Dövüşçü (B-Rank)" : "Elite Combatant (B-Rank)")
            : (isTurkish ? "Seçkin Avcı (B-Rank)" : "Elite Hunter (B-Rank)");
      }
      if (rUpper.startsWith('C')) {
        return combat 
            ? (isTurkish ? "Demir Yumruk Dövüşçü (C-Rank)" : "Iron Fist Striker (C-Rank)")
            : (isTurkish ? "Şövalye Avcı (C-Rank)" : "Knight Hunter (C-Rank)");
      }
      if (rUpper.startsWith('D')) {
        return combat 
            ? (isTurkish ? "Dövüşçü Avcı (D-Rank)" : "Combatant Hunter (D-Rank)")
            : (isTurkish ? "Avcı (D-Rank)" : "Hunter (D-Rank)");
      }
      if (rUpper.startsWith('E')) {
        return isTurkish ? "Çaylak Avcı (E-Rank)" : "Rookie Hunter (E-Rank)";
      }
    }

    if (isTurkish) {
      if (level < 5) return "Çaylak Avcı (E-Seviye)";
      if (level < 10) return "Kıdemli Avcı (C-Seviye)";
      if (level < 20) return "Seçkin Avcı (B-Seviye)";
      if (level < 50) return "Ulusal Düzey Avcı (A-Seviye)";
      return "Gölge Hükümdarı (S-Seviye)";
    } else {
      if (level < 5) return "Rookie Hunter (E-Rank)";
      if (level < 10) return "Experienced Hunter (C-Rank)";
      if (level < 20) return "Elite Hunter (B-Rank)";
      if (level < 50) return "National Level Hunter (A-Rank)";
      return "Shadow Monarch (S-Rank)";
    }
  }

  static String objectiveTitle(String raw) {
    if (isTurkish) {
      if (raw.contains('Kilo Ver') || raw.contains('Lose Weight')) return 'Kilo Ver (Yağ Yak)';
      if (raw.contains('Kilo Al') || raw.contains('Build Muscle')) return 'Kilo Al (Kas İnşa Et)';
      return 'Mevcut Kilonu Koru';
    } else {
      if (raw.contains('Kilo Ver') || raw.contains('Lose Weight')) return 'Lose Weight (Fat Loss)';
      if (raw.contains('Kilo Al') || raw.contains('Build Muscle')) return 'Build Muscle (Hypertrophy)';
      return 'Maintain Current Weight';
    }
  }

  static String difficultyTitle(String raw) {
    if (isTurkish) {
      if (raw == 'Hard' || raw == 'Yüksek') return 'Yüksek';
      if (raw == 'Hell' || raw == 'Cehennem') return 'Cehennem';
      if (raw == 'Monster' || raw == 'Canavar') return 'Canavar';
      return 'Normal';
    } else {
      if (raw == 'Hard' || raw == 'Yüksek') return 'Hard';
      if (raw == 'Hell' || raw == 'Cehennem') return 'Hell';
      if (raw == 'Monster' || raw == 'Canavar') return 'Monster';
      return 'Normal';
    }
  }
}

extension TranslationStringExt on String {
  String get tr => TranslationManager.get(this);
}
