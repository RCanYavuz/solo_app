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
      
      // Dashboard Extras
      'dash_filter_all': 'ALL',
      'dash_filter_physical': '⚔️ PHYSICAL',
      'dash_filter_mental': '🧠 MENTAL',
      'dash_physical_protocol': '// PHYSICAL WORKOUT PROTOCOL',
      'dash_recovery_protocol': 'RECOVERY PROTOCOL (RECOVERY DAY)',
      'dash_recovery_desc': 'Today, physical muscle fibers enter the supercompensation (growth) phase. Grow your mind while muscles repair on rest days.',
      'dash_enter_mental_dungeon': 'ENTER MENTAL DUNGEON (DEEP WORK)',
      'dash_rec_hydration': '💧 3-4L Hydration',
      'dash_rec_stretch': '🧘 15 Min Stretching',
      'dash_rec_reading': '📖 Book & Mind',
      'dash_mental_protocol': '// COGNITIVE GROWTH & STUDY PROTOCOL',
      'dash_mental_no_protocol': 'MENTAL DUNGEON: NO ACTIVE PROTOCOL',
      'dash_mental_no_protocol_desc': 'Growth is not limited to lifting weights. Generate a daily protocol tailored to your specialty or reading goal with AI.',
      'dash_create_study_protocol': 'CREATE AI STUDY PROTOCOL',
      'dash_physical_dungeon': 'PHYSICAL DUNGEON',
      'dash_cognitive_dungeon': 'COGNITIVE DUNGEON',
      'dash_promotion_trial_ready': '[ ⚔️ RANK PROMOTION TRIAL READY ]',
      'dash_promotion_trial_desc': 'Training quota fulfilled. Enter trial to ascend rank!',
      'dash_enter_promotion_trial': 'ENTER PROMOTION TRIAL NOW',
      'dash_complete': 'Complete',
      'dash_completed': 'Completed',
      'dash_pages_read': 'Pages Read',
      'dash_min_focus': 'Min Focus',
      'dash_scholar': 'Scholar',
      'dash_deep_focus': 'Deep Focus',
      'dash_ai_study': 'AI STUDY',
      'dash_start_deep_work': 'Start Deep Work',
      'dash_start_deload': 'START DELOAD PROTOCOL',
      'dash_switch_difficulty': 'SWITCH TO {0} DIFFICULTY',
      'dash_difficulty_activated': 'SYSTEM: {0} protocol activated!',

      // Profile Extras
      'profile_visual_awakening': 'VISUAL AWAKENING',
      'profile_forging_avatar': 'FORGING AVATAR',
      'profile_analyzing_features': 'Analyzing facial features...',
      'profile_generating_prompt': 'Generating hyper-realistic prompt...',
      'profile_connecting_pollinations': 'Connecting to Pollinations AI...',
      'profile_forging_identity': 'Forging new identity...',
      'profile_override_dialog_title': 'OVERRIDE PROTOCOL',
      'profile_change_objective': 'Change your Main Objective:',
      'profile_change_difficulty': 'Change Dungeon Difficulty:',
      'profile_override_btn': 'OVERRIDE',
      'profile_protocol_overridden': 'SYSTEM: Protocol Overridden! Calories Recalculated.',
      'profile_update_desc': 'The System will analyze your current physical specs and apply rewards or penalties.',
      'profile_height_cm': 'HEIGHT (cm)',
      'profile_current_weight_kg': 'CURRENT WEIGHT (kg)',
      'profile_target_weight_kg': 'TARGET WEIGHT (kg)',
      'profile_warning': 'WARNING',
      'profile_achievement': 'ACHIEVEMENT',
      'profile_supplement_btn': '💊 SUPPLEMENT LOADOUT & SYNERGY',
      'profile_view_gallery_desc': 'Physical transformation timeline and Before & After comparison visor.',
      'profile_view_gallery_btn': 'VIEW GALLERY & TRANSFORMATION',
      'profile_notif_desc': 'Manage dungeon calls, hydration replenishment, and penalty notifications.',
      'profile_hydration_title': 'Hydration Protocol (Water)',
      'profile_hydration_sub': 'Alert every {0} hours (+1 MP)',
      'profile_dungeon_call_title': 'Dungeon Call (Workout)',
      'profile_dungeon_call_sub': 'Daily training time: {0}',
      'profile_change_time': 'Change Time',
      'profile_midnight_alert_title': 'Midnight Reckoning Alert',
      'profile_midnight_alert_sub': 'Last warning before penalty protocol at 22:30',
      'profile_test_notif_btn': 'TRIGGER TEST NOTIFICATION',
      'profile_test_notif_sent': 'SYSTEM: Test notification sent!',
      'profile_red_gate_setup': 'RED GATE SETUP',
      'profile_red_gate_setup_desc': 'Set your own limits and select a combat protocol.',
      'profile_survival_duration': 'Survival Duration: {0} Days',
      'profile_hell_training_protocol': "Hell's Training Protocol:",
      'profile_hell_calorie_limit': "Hell's Calorie Limit:",
      'profile_red_gate_info': 'INFO: Your normal plan is backed up. The System will forcefully assign you the chosen Training Protocol every single day of this hell.',
      'profile_expected_clear_reward': 'EXPECTED CLEAR REWARD',
      'profile_open_gate_btn': 'OPEN GATE',
      'profile_red_gate_welcome': 'SYSTEM: Welcome to Hell. Check your Daily Quests!',
      'profile_use_escape_crystal': 'USE ESCAPE CRYSTAL?',
      'profile_escape_crystal_desc': 'Are you sure you want to flee the Red Gate? You will return to the normal world, but you will forfeit all accumulated survival rewards. Cowards get nothing.',
      'profile_stay_and_fight': 'STAY & FIGHT',
      'profile_fled_red_gate': 'SYSTEM: You fled the Red Gate. Normal protocol restored.',
      'profile_gemini_core_title': 'GEMINI CORE PROTOCOL',
      'profile_gemini_core_desc': 'Enter your Google Gemini API Key to enable AI Meal Decoding and System Voice synthesis.',
      'profile_active_model': 'Active Model:',
      'profile_save_key': 'SAVE KEY',
      'profile_diagnostic': 'DIAGNOSTIC',
      'profile_configured': 'CONFIGURED',
      'profile_no_key': 'NO KEY',
      'profile_set_key': 'SET KEY',
      'profile_gemini_key_label': 'API KEY (AIzaSy...)',
      'profile_gemini_updated': 'Gemini API Key updated successfully!',
      'profile_system_purge': 'SYSTEM PURGE',
      'profile_system_purge_desc': 'All data (level, gold, history, API key) will be permanently deleted. Are you sure?',
      'profile_wipe_data': 'WIPE DATA',
      'profile_core_online': 'CORE ONLINE',
      'profile_core_failed': 'CORE DIAGNOSTIC FAILED',
      'profile_verified_model': 'VERIFIED MODEL: {0}',
      'profile_acknowledge': 'ACKNOWLEDGE',
      'profile_archive_export': 'SYSTEM ARCHIVE EXPORT',
      'profile_archive_export_desc': 'Copy your complete Hunter encrypted archive to clipboard. You can restore your stats, level, inventory, and history on any device.',
      'profile_copy_clipboard': 'COPY TO CLIPBOARD',
      'profile_archive_copied': '[SYSTEM] Hunter archive copied to clipboard!',
      'profile_restore_archive': 'RESTORE ARCHIVE',
      'profile_restore_archive_desc': 'Paste your raw backup JSON archive below to overwrite and restore all Hunter data.',
      'profile_restore_btn': 'RESTORE DATA',
      'profile_active_engine': 'Active Engine',
      'profile_equipment_mode': 'Equipment Mode:',
      'profile_trial_progress': 'Next Rank Trial Progress:',
      'profile_trial_ready': '⚔️ PROMOTION TRIAL READY',
      'profile_enter_trial': '⚔️ ENTER PROMOTION TRIAL',

      // Diet Extras
      'diet_target_weight': 'TARGET WEIGHT:',
      'diet_system_workout_defense': '⚖️ SYSTEM WORKOUT & MUSCLE DEFENSE',
      'diet_catabolism': 'CATABOLISM:',
      'diet_catabolism_high': 'HIGH',
      'diet_workout_expenditure': "Today's heavy training expenditure: ~{0} kcal.\nDynamic boost added to system to prevent muscle loss and restore glycogen:",
      'diet_dietitian_prescription_preserved': '📋 Dietitian base prescription preserved; training effort compensated dynamically.',
      'diet_dietitian_btn_on': 'DIETITIAN [ON]',
      'diet_dietitian_btn': 'DIETITIAN',
      'diet_dietitian_tooltip': 'Dietitian Menu / Scanner',
      'diet_gallery': 'GALLERY',
      'diet_photo_loaded': 'PHOTO LOADED',

      // Active Workout Extras
      'workout_active_raid': 'ACTIVE RAID',
      'workout_timer_running': 'Dungeon Timer Running...',
      'workout_active_quests': 'ACTIVE QUESTS',
      'workout_rest': 'REST',
      'workout_templates': 'TEMPLATES',
      'workout_add_exercise': '+ INJECT EXTRA EXERCISE',
      'workout_exit_dungeon': 'EXIT DUNGEON',
      'workout_dungeon_cleared': '[ DUNGEON CLEARED ]',
      'workout_no_quests': 'No quests assigned. Load a template or return to planner.',
      'workout_set_overload_log': 'SET & OVERLOAD LOG',
      'workout_add_set': 'ADD SET',
      'workout_no_sets_hint': 'No sets added yet. Tap "ADD SET" to log your weights.',
      'workout_tactics_substitute': '• Tap: Tactics / Alternatives',

      // Notification Section
      'profile_system_directives': 'SYSTEM DIRECTIVES',
      'profile_alerts_badge': 'ALERTS',

      // Macro Dashboard Extras
      'macro_target_weight_label': 'TARGET WEIGHT',
      'macro_waist_label': 'WAIST CIRCUMFERENCE',
      'macro_vision_label': 'HUNTER NUTRITION VISION & NOTE',
      'macro_vision_hint': 'e.g.: Aim for 0.5 kg loss per week, save carbs for post-workout...',
      'macro_blend_ai': 'BLEND WITH AI',
      'macro_processing': 'PROCESSING...',
      'macro_protocol_integration': 'SYSTEM PROTOCOL INTEGRATION',
      'macro_protocol_desc': 'Integrate the target weight and calorie limit calculated in this lab into the active Hunter system with a single tap.',
      'macro_integrate_btn': '⚡ INTEGRATE TARGETS INTO SYSTEM',
      'macro_target_metabolic_proj': '🎯 TARGET WEIGHT & METABOLIC PROJECTION',
      'macro_recommended_pace': 'RECOMMENDED PACE',
      'macro_estimated_time': 'ESTIMATED TIME',
      'macro_daily_cal_balance': 'DAILY CALORIE BALANCE',
      'macro_body_fat': 'BODY FAT',

      // Calendar Extras
      'cal_duration': 'Duration:',
      'cal_min': 'MIN',
      'cal_quests_cleared': 'Quests Cleared:',
      'cal_earned_exp': 'Earned EXP:',
      'cal_est_cal': 'Est. Calories:',
      'cal_system_archived': 'System: "Hunter\'s dungeon discipline and raid successfully archived."',

      // Rest Timer Extras
      'rest_mp_recovery_complete': 'MP RECOVERY COMPLETE!',
      'rest_mp_recovery_title': 'MP RECOVERY (REST TIMER)',
      'rest_ready': 'READY!',
      'rest_recovery': 'RECOVERY',
      'rest_plus_15s': '+15 SEC',
      'rest_next_set': 'NEXT SET',
      'rest_ready_btn': 'READY',

      // Sleep Tracker Extras
      'sleep_no_data': 'No sleep data logged yet.',
      'sleep_insufficient': '⚠️ INSUFFICIENT: Fatigue gain & MP loss!',
      'sleep_minimal': '⚖️ MINIMAL: Basal recovery achieved.',
      'sleep_optimal': '✨ OPTIMAL: +2 MP & Full Fatigue Cleared.',
      'sleep_deep': '🛡️ DEEP HIBERNATION: Maximum cellular repair.',
      'sleep_quick_select': 'Quick Select:',
      'sleep_hours_unit': 'HRS',

      // Deep Work Timer Extras
      'deep_protocol_complete': 'FOCUS PROTOCOL COMPLETE',
      'deep_protocol_complete_desc': 'Hunter maintained mental concentration and cleared the cognitive dungeon.',
      'deep_earned_exp': 'EARNED EXPERIENCE',
      'deep_int_gain': 'INTELLIGENCE (INT) INCREASE',
      'deep_per_gain': 'PERCEPTION (PER) INCREASE',
      'deep_cognitive_dungeon': 'COGNITIVE DUNGEON // DEEP WORK',
      'deep_active_focus': 'ACTIVE PROTOCOL: FOCUS',
      'deep_active_rest': 'ACTIVE PROTOCOL: REST',
      'deep_subject_label': 'SUBJECT OR BOOK',
      'deep_cognitive_focus': 'COGNITIVE FOCUS',
      'deep_recovery_mode': 'RECOVERY MODE',
      'deep_start': 'START',
      'deep_finish': 'FINISH',
      'deep_completed_sessions': 'COMPLETED SESSIONS',
      'deep_total_focus': 'TOTAL FOCUS',

      // Dietitian Scanner Extras
      'diet_scan_title': 'DIETITIAN MENU INTEGRATION',
      'diet_scan_desc': 'Scan or upload the meal plan provided by your dietitian as a document, photo or text. The System bases its limits on your dietitian while dynamically compensating for heavy workout days.',
      'diet_scan_plan_active': 'DIETITIAN PLAN: [ACTIVE]',
      'diet_scan_plan_disabled': 'DIETITIAN PLAN: [DISABLED]',
      'diet_scan_system_active': 'Currently System AI prescription is active.',
      'diet_scan_cancel_btn': 'CANCEL',
      'diet_scan_upload_sec': 'UPLOAD LIST & SYSTEM DECODING',
      'diet_scan_select_doc': '📄 SELECT PDF / WORD DOCUMENT (.pdf, .docx, .doc)',
      'diet_scan_gallery_photo': 'GALLERY / PHOTO',
      'diet_scan_camera': 'CAMERA',
      'diet_scan_doc_added': 'Dietitian document / photo attached.',
      'diet_scan_hint': 'Paste dietitian meals or add notes (e.g. 2000 kcal, 140g protein...)',
      'diet_scan_decoding_btn': 'SYSTEM DECODING...',
      'diet_scan_start_btn': 'START SYSTEM METABOLIC SCANNER',
      'diet_scan_confirm_title': 'CONFIRM DIETITIAN TARGETS',
      'diet_scan_apply_btn': 'PRESCRIBE DIETITIAN LIST TO SYSTEM',
      'diet_scan_cal': 'CALORIES (kcal)',
      'diet_scan_pro': 'PROTEIN (g)',
      'diet_scan_carb': 'CARBS (g)',
      'diet_scan_fat': 'FAT (g)',
      'diet_scan_breakdown': 'SCANNED MEAL BREAKDOWN ({0} MEALS)',
      'diet_scan_meal_default': 'Meal',
      'diet_scan_doc_label': 'Document',
      
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
      
      // Dashboard Extras
      'dash_filter_all': 'TÜMÜ',
      'dash_filter_physical': '⚔️ FİZİKSEL',
      'dash_filter_mental': '🧠 ZİHİNSEL',
      'dash_physical_protocol': '// FİZİKSEL ANTRENMAN PROTOKOLÜ',
      'dash_recovery_protocol': 'DİNLENME PROTOKOLÜ (RECOVERY DAY)',
      'dash_recovery_desc': 'Bugün fiziksel kas liflerinin süperkompansasyon (büyüme) fazı devrededir. Dinlenme günlerinde kaslar onarılırken zihninizi geliştirin.',
      'dash_enter_mental_dungeon': 'ZİHİNSEL ZİNDANA GİR (DEEP WORK)',
      'dash_rec_hydration': '💧 3-4L Hidrasyon',
      'dash_rec_stretch': '🧘 15 Dk Esneme',
      'dash_rec_reading': '📖 Kitap & Zihin',
      'dash_mental_protocol': '// BİLİŞSEL GELİŞİM & ÇALIŞMA PROTOKOLÜ',
      'dash_mental_no_protocol': 'ZİHİNSEL ZİNDAN: AKTİF PROTOKOL YOK',
      'dash_mental_no_protocol_desc': 'Gelişim sadece ağırlık kaldırmakla sınırlı değildir. Yapay zeka ile uzmanlık alanınıza veya okuma hedefinize özel günlük görev protokolü üretin.',
      'dash_create_study_protocol': 'AI ÇALIŞMA PROTOKOLÜ OLUŞTUR',
      'dash_physical_dungeon': 'FİZİKSEL ZİNDAN',
      'dash_cognitive_dungeon': 'BİLİŞSEL ZİNDAN',
      'dash_promotion_trial_ready': '[ ⚔️ RÜTBE YÜKSELME SINAVI HAZIR ]',
      'dash_promotion_trial_desc': 'İdman kotası dolduruldu. Rütbeni yükseltmek için sınava gir!',
      'dash_enter_promotion_trial': 'ŞİMDİ RÜTBE SINAVINA GİR',
      'dash_complete': 'Tamamla',
      'dash_completed': 'Tamamlandı',
      'dash_pages_read': 'Sayfa Kitap',
      'dash_min_focus': 'Dk Odak',
      'dash_scholar': 'Alim',
      'dash_deep_focus': 'Derin Odak',
      'dash_ai_study': 'AI ÇALIŞMA',
      'dash_start_deep_work': 'Deep Work Başlat',
      'dash_start_deload': 'DELOAD PROTOKOLÜNÜ BAŞLAT',
      'dash_switch_difficulty': '{0} ZORLUĞA GEÇ',
      'dash_difficulty_activated': 'SİSTEM: {0} protokolü devreye alındı!',

      // Profile Extras
      'profile_visual_awakening': 'GÖRSEL UYANIŞ',
      'profile_forging_avatar': 'AVATAR ŞEKİLLENDİRİLİYOR',
      'profile_analyzing_features': 'Yüz hatları analiz ediliyor...',
      'profile_generating_prompt': 'Hiper-gerçekçi komut oluşturuluyor...',
      'profile_connecting_pollinations': 'Pollinations AI sistemine bağlanılıyor...',
      'profile_forging_identity': 'Yeni kimlik işleniyor...',
      'profile_override_dialog_title': 'PROTOKOLÜ DEĞİŞTİR',
      'profile_change_objective': 'Ana Hedefinizi Değiştirin:',
      'profile_change_difficulty': 'Zindan Zorluğunu Değiştirin:',
      'profile_override_btn': 'DEĞİŞTİR',
      'profile_protocol_overridden': 'SİSTEM: Protokol güncellendi! Kalori yeniden hesaplandı.',
      'profile_update_desc': 'Sistem mevcut fiziksel verilerinizi analiz edecek ve ödül/ceza uygulayacaktır.',
      'profile_height_cm': 'BOY (cm)',
      'profile_current_weight_kg': 'MEVCUT KİLO (kg)',
      'profile_target_weight_kg': 'HEDEF KİLO (kg)',
      'profile_warning': 'UYARI',
      'profile_achievement': 'BAŞARIM',
      'profile_supplement_btn': '💊 SUPLEMENT KUŞANMA & SİNERJİ',
      'profile_view_gallery_desc': 'Fiziksel değişim zaman çizelgesi ve Önce / Sonra (Before & After) karşılaştırma vizörü.',
      'profile_view_gallery_btn': 'GALERİYİ & DÖNÜŞÜMÜ GÖRÜNTÜLE',
      'profile_notif_desc': 'Zindan çağrıları, hidrasyon takviyesi ve ceza protokolü bildirimlerini yönetin.',
      'profile_hydration_title': 'Hidrasyon Protokolü (Su)',
      'profile_hydration_sub': 'Her {0} saatte bir uyarı (+1 MP)',
      'profile_dungeon_call_title': 'Zindan Çağrısı (İdman)',
      'profile_dungeon_call_sub': 'Günlük antrenman saati: {0}',
      'profile_change_time': 'Saati Değiştir',
      'profile_midnight_alert_title': 'Gece Hesaplaşması Uyarısı',
      'profile_midnight_alert_sub': "Saat 22:30'da ceza protokolü öncesi son uyarı",
      'profile_test_notif_btn': 'TEST BİLDİRİMİ TETİKLE',
      'profile_test_notif_sent': 'SYSTEM: Test bildirimi gönderildi!',
      'profile_red_gate_setup': 'KIZIL GEÇİT KURULUMU',
      'profile_red_gate_setup_desc': 'Kendi sınırlarınızı belirleyin ve bir savaş protokolü seçin.',
      'profile_survival_duration': 'Hayatta Kalma Süresi: {0} Gün',
      'profile_hell_training_protocol': 'Cehennem Antrenman Protokolü:',
      'profile_hell_calorie_limit': 'Cehennem Kalori Limiti:',
      'profile_red_gate_info': 'BİLGİ: Normal planınız yedeklendi. Sistem bu cehennemin her gününde seçilen Antrenman Protokolünü zorla atayacaktır.',
      'profile_expected_clear_reward': 'BEKLENEN TAMAMLAMA ÖDÜLÜ',
      'profile_open_gate_btn': 'GEÇİDİ AÇ',
      'profile_red_gate_welcome': 'SİSTEM: Cehenneme hoş geldin. Günlük Görevlerini kontrol et!',
      'profile_use_escape_crystal': 'KAÇIŞ KRİSTALİ KULLANILSIN MI?',
      'profile_escape_crystal_desc': 'Kızıl Geçitten kaçmak istediğinizden emin misiniz? Normal dünyaya döneceksiniz ancak biriken tüm hayatta kalma ödüllerini kaybedeceksiniz. Korkaklar hiçbir şey alamaz.',
      'profile_stay_and_fight': 'KAL VE SAVAŞ',
      'profile_fled_red_gate': 'SİSTEM: Kızıl Geçitten kaçtınız. Normal protokol geri yüklendi.',
      'profile_gemini_core_title': 'GEMINI ÇEKİRDEK PROTOKOLÜ',
      'profile_gemini_core_desc': 'Yapay Zeka Besin Çözücü ve Sistem Ses Sentezini etkinleştirmek için Google Gemini API Anahtarınızı girin.',
      'profile_active_model': 'Aktif Model:',
      'profile_save_key': 'ANAHTARI KAYDET',
      'profile_diagnostic': 'DİYAGNOSTİK',
      'profile_configured': 'YAPILANDIRILDI',
      'profile_no_key': 'ANAHTAR YOK',
      'profile_set_key': 'ANAHTARI AYARLA',
      'profile_gemini_key_label': 'API ANAHTARI (AIzaSy...)',
      'profile_gemini_updated': 'Gemini API Anahtarı başarıyla güncellendi!',
      'profile_system_purge': 'SİSTEMİ SIFIRLAMA',
      'profile_system_purge_desc': 'Tüm veriler (seviye, altın, geçmiş, API anahtarı) kalıcı olarak silinecek. Emin misiniz?',
      'profile_wipe_data': 'VERİLERİ SİL',
      'profile_core_online': 'ÇEKİRDEK ÇEVRİMİÇİ',
      'profile_core_failed': 'ÇEKİRDEK DİYAGNOSTİĞİ BAŞARISIZ',
      'profile_verified_model': 'DOĞRULANMIŞ MODEL: {0}',
      'profile_acknowledge': 'ANLAŞILDI',
      'profile_archive_export': 'SİSTEM ARŞİVİ DIŞA AKTAR',
      'profile_archive_export_desc': 'Tüm Avcı şifreli arşivinizi panoya kopyalayın. Statülerinizi, seviyenizi, envanterinizi ve geçmişinizi herhangi bir cihazda geri yükleyebilirsiniz.',
      'profile_copy_clipboard': 'PANOYA KOPYALA',
      'profile_archive_copied': '[SİSTEM] Avcı arşivi panoya kopyalandı!',
      'profile_restore_archive': 'ARŞİVİ GERİ YÜKLE',
      'profile_restore_archive_desc': 'Tüm Avcı verilerini üzerine yazmak ve geri yüklemek için ham yedek JSON arşivinizi aşağıya yapıştırın.',
      'profile_restore_btn': 'VERİYİ GERİ YÜKLE',
      'profile_active_engine': 'Aktif Motor',
      'profile_equipment_mode': 'Ekipman Modu:',
      'profile_trial_progress': 'Sonraki Kademe Sınavı İlerlemesi:',
      'profile_trial_ready': '⚔️ KADEME TERFİ SINAVI HAZIR',
      'profile_enter_trial': '⚔️ TERFİ SINAVINA GİR',

      // Diet Extras
      'diet_target_weight': 'HEDEF KİLO:',
      'diet_system_workout_defense': '⚖️ SİSTEM İDMAN VE KAS KORUMA',
      'diet_catabolism': 'KATABOLİZMA:',
      'diet_catabolism_high': 'YÜKSEK',
      'diet_workout_expenditure': "Bugünkü ağır idman harcamanız: ~{0} kcal.\nKas yıkımını önlemek ve glikojeni yenilemek için sisteme eklenen dinamik takviye:",
      'diet_dietitian_prescription_preserved': '📋 Diyetisyen taban reçetesi korunmaktadır; idman eforu dinamik olarak telafi edilmiştir.',
      'diet_dietitian_btn_on': 'DİYETİSYEN [ON]',
      'diet_dietitian_btn': 'DİYETİSYEN',
      'diet_dietitian_tooltip': 'Diyetisyen Menüsü / Taraması',
      'diet_gallery': 'GALERİ',
      'diet_photo_loaded': 'FOTO YÜKLENDİ',

      // Active Workout Extras
      'workout_active_raid': 'AKTİF AKIN',
      'workout_timer_running': 'Zindan Sayacı Çalışıyor...',
      'workout_active_quests': 'AKTİF GÖREVLER',
      'workout_rest': 'DİNLENME',
      'workout_templates': 'ŞABLONLAR',
      'workout_add_exercise': '+ EK HAREKET ENJEKTE ET',
      'workout_exit_dungeon': 'ZİNDANDAN ÇIK',
      'workout_dungeon_cleared': '[ ZİNDAN TEMİZLENDİ ]',
      'workout_no_quests': 'Atanmış görev yok. Bir şablon yükleyin veya planlayıcıya dönün.',
      'workout_set_overload_log': 'SET & OVERLOAD KAYDI',
      'workout_add_set': 'SET EKLE',
      'workout_no_sets_hint': 'Henüz set eklenmedi. "SET EKLE" butonuna basarak ağırlık kaydedin.',
      'workout_tactics_substitute': '• Dokun: Taktik / Alternatif',

      // Notification Section
      'profile_system_directives': 'SİSTEM DİREKTİFLERİ',
      'profile_alerts_badge': 'UYARILAR',

      // Macro Dashboard Extras
      'macro_target_weight_label': 'HEDEF KİLO',
      'macro_waist_label': 'BEL ÇEVRESİ',
      'macro_vision_label': 'AVCININ BESLENME VİZYONU & NOTU',
      'macro_vision_hint': 'Örn: Haftada 0.5 kg vereyim, karbonhidratı idman sonrasına saklayalım...',
      'macro_blend_ai': 'AI İLE HARMANLA',
      'macro_processing': 'İŞLENİYOR...',
      'macro_protocol_integration': 'SİSTEM PROTOKOLÜ ENTEGRASYONU',
      'macro_protocol_desc': 'Bu laboratuvarda hesaplanan hedef kilo ve kalori limitini tek tıkla aktif avcı sistemine bağlayın.',
      'macro_integrate_btn': '⚡ BU HEDEFLERİ SİSTEME ENTEGRE ET',
      'macro_target_metabolic_proj': '🎯 HEDEF KİLO & METABOLİK PROJEKSİYON',
      'macro_recommended_pace': 'ÖNERİLEN TEMPO',
      'macro_estimated_time': 'TAHMİNİ SÜRE',
      'macro_daily_cal_balance': 'GÜNLÜK KALORİ DENGESİ',
      'macro_body_fat': 'YAĞ ORANI',

      // Calendar Extras
      'cal_duration': 'Süre:',
      'cal_min': 'DK',
      'cal_quests_cleared': 'Tamamlanan Görev:',
      'cal_earned_exp': 'Kazanılan EXP:',
      'cal_est_cal': 'Tahmini Kalori:',
      'cal_system_archived': 'Sistem: "Avcının zindan disiplini ve akını başarıyla arşivlendi."',

      // Rest Timer Extras
      'rest_mp_recovery_complete': 'MP YENİLENMESİ TAMAMLANDI!',
      'rest_mp_recovery_title': 'MP YENİLENMESİ (DİNLENME SAYACI)',
      'rest_ready': 'HAZIR!',
      'rest_recovery': 'DİNLENME',
      'rest_plus_15s': '+15 SN',
      'rest_next_set': 'SIRADAKİ SET',
      'rest_ready_btn': 'HAZIRIM',

      // Sleep Tracker Extras
      'sleep_no_data': 'Henüz uyku verisi girilmedi.',
      'sleep_insufficient': '⚠️ YETERSİZ: Yorgunluk artışı & MP kaybı!',
      'sleep_minimal': '⚖️ MİNİMAL: Bazal toparlanma sağlandı.',
      'sleep_optimal': '✨ OPTİMAL: +2 MP & Tam Yorgunluk Arınması.',
      'sleep_deep': '🛡️ DERİN HİBERNASYON: Maksimum hücre onarımı.',
      'sleep_quick_select': 'Hızlı Seçim:',
      'sleep_hours_unit': 'SAAT',

      // Deep Work Timer Extras
      'deep_protocol_complete': 'ODAKLANMA PROTOKOLÜ TAMAMLANDI',
      'deep_protocol_complete_desc': 'Avcı zihinsel konsantrasyonunu korudu ve zihinsel zindanı temizledi.',
      'deep_earned_exp': 'KAZANILAN TECRÜBE',
      'deep_int_gain': 'ZEKA (INT) ARTIŞI',
      'deep_per_gain': 'SEZGİ (PER) ARTIŞI',
      'deep_cognitive_dungeon': 'BİLİŞSEL ZİNDAN // DEEP WORK',
      'deep_active_focus': 'AKTİF PROTOKOL: ODAKLANMA',
      'deep_active_rest': 'AKTİF PROTOKOL: DİNLENME',
      'deep_subject_label': 'ÇALIŞILAN KONU VEYA KİTAP',
      'deep_cognitive_focus': 'BİLİŞSEL ODAK',
      'deep_recovery_mode': 'YENİLENME MODU',
      'deep_start': 'BAŞLAT',
      'deep_finish': 'BİTİR',
      'deep_completed_sessions': 'BİTİRİLEN SEANS',
      'deep_total_focus': 'GENEL SİSTEM',

      // Dietitian Scanner Extras
      'diet_scan_title': 'DİYETİSYEN MENÜ ENTEGRASYONU',
      'diet_scan_desc': 'Kendi diyetisyeninizin verdiği beslenme listesini fotoğraf, belge veya metin olarak tarayın. Sistem diyetisyen hedeflerinizi temel alır, ağır idman günlerinde dinamik telafi ekler.',
      'diet_scan_plan_active': 'DİYETİSYEN PLANI: [AKTİF]',
      'diet_scan_plan_disabled': 'DİYETİSYEN PLANI: [DEVRE DIŞI]',
      'diet_scan_system_active': 'Şu an Sistem Yapay Zeka reçetesi devrede.',
      'diet_scan_cancel_btn': 'İPTAL ET',
      'diet_scan_upload_sec': 'LİSTE YÜKLEME VE SİSTEM ÇÖZÜMLEME',
      'diet_scan_select_doc': '📄 PDF / WORD BELGESİ SEÇ (.pdf, .docx, .doc)',
      'diet_scan_gallery_photo': 'GALERİ / FOTO',
      'diet_scan_camera': 'KAMERA',
      'diet_scan_doc_added': 'Diyetisyen belgesi / fotoğrafı eklendi.',
      'diet_scan_hint': 'Diyetisyenin verdiği öğünleri yapıştırın veya not ekleyin (Örn: 2000 kcal, 140g protein...)',
      'diet_scan_decoding_btn': 'SİSTEM ÇÖZÜMLÜYOR...',
      'diet_scan_start_btn': 'SİSTEM METABOLİK TARAYICIYI BAŞLAT',
      'diet_scan_confirm_title': 'DİYETİSYEN HEDEFLERİNİ ONAYLA',
      'diet_scan_apply_btn': 'DİYETİSYEN LİSTESİNİ SİSTEME REÇETE ET',
      'diet_scan_cal': 'KALORİ (kcal)',
      'diet_scan_pro': 'PROTEİN (g)',
      'diet_scan_carb': 'KARB (g)',
      'diet_scan_fat': 'YAĞ (g)',
      'diet_scan_breakdown': 'TARANAN ÖĞÜN DÖKÜMÜ ({0} ÖĞÜN)',
      'diet_scan_meal_default': 'Öğün',
      'diet_scan_doc_label': 'Belgesi',
      
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
