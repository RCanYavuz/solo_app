import re

with open('lib/screens/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if "import '../core/translation_manager.dart';" not in content:
    content = content.replace("import '../controllers/system_memory.dart';", "import '../controllers/system_memory.dart';\nimport '../core/translation_manager.dart';")

replacements = {
    "'S T A T U S'": "TranslationManager.get('dash_status')",
    "'LEVEL'": "TranslationManager.get('dash_level')",
    "'TITLE: '": "TranslationManager.get('dash_title') + ': '",
    "'ENERGY'": "TranslationManager.get('dash_energy')",
    "' MAX'": "' ' + TranslationManager.get('dash_max')",
    "'PHYSICAL'": "TranslationManager.get('dash_physical')",
    "'ACHIEVEMENTS'": "TranslationManager.get('dash_achievements')",
    "'DUNGEON GATE'": "TranslationManager.get('dash_dungeon_gate')",
    "'BOSS DEFEATED'": "TranslationManager.get('dash_boss_defeated')",
    "'WARNING: BOSS ACTIVE'": "TranslationManager.get('dash_boss_active')",
    '"Fiziksel" ? "Physical" : "Mental"': '"Fiziksel" ? TranslationManager.get("dash_weakness_phy") : TranslationManager.get("dash_weakness_men")',
    "'GATE IS DORMANT'": "TranslationManager.get('dash_gate_dormant')",
    "'The Weekly Boss will appear on Sunday.'": "TranslationManager.get('dash_boss_sunday')",
    "'DAILY QUESTS'": "TranslationManager.get('dash_daily_quests')",
    '"No active quests."': "TranslationManager.get('dash_no_quests')",
    "'[PHY]'": "TranslationManager.get('dash_phy')",
    "'[MNT]'": "TranslationManager.get('dash_mnt')",
    "'TODAY\\'S DUNGEON LOGS'": "TranslationManager.get('dash_todays_dungeon')",
    '"No raids completed today."': "TranslationManager.get('dash_no_raids')",
    "'ENTER DUNGEON (START WORKOUT)'": "TranslationManager.get('dash_enter_dungeon')",
}

for k, v in replacements.items():
    content = content.replace(k, v)

with open('lib/screens/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
