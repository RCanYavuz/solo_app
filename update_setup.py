import re

with open('lib/screens/setup_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add translation manager import
if "import '../core/translation_manager.dart';" not in content:
    content = content.replace("import 'welcome_screen.dart';", "import 'welcome_screen.dart';\nimport '../core/translation_manager.dart';")

replacements = {
    "'SYSTEM INITIALIZATION'": "TranslationManager.get('setup_title')",
    "'Age'": "TranslationManager.get('setup_age')",
    "'Height (cm)'": "TranslationManager.get('setup_height')",
    "'Weight (kg)'": "TranslationManager.get('setup_weight')",
    "'Gender'": "TranslationManager.get('setup_gender')",
    "'Male'": "TranslationManager.get('setup_male')",
    "'Female'": "TranslationManager.get('setup_female')",
    "'Objective'": "TranslationManager.get('setup_objective')",
    "'Lose Weight (Burn Fat)'": "TranslationManager.get('setup_lose_weight')",
    "'Maintain Weight'": "TranslationManager.get('setup_maintain')",
    "'Gain Weight (Build Muscle)'": "TranslationManager.get('setup_gain_weight')",
    "'Base Difficulty'": "TranslationManager.get('setup_difficulty')",
    "'Normal'": "TranslationManager.get('setup_diff_normal')",
    "'High'": "TranslationManager.get('setup_diff_high')",
    "'Hell'": "TranslationManager.get('setup_diff_hell')",
    "'Monster'": "TranslationManager.get('setup_diff_monster')",
    "'START INITIALIZATION'": "TranslationManager.get('setup_start_button')",
    "'HUNTER NAME (Optional)'": "TranslationManager.get('setup_player_name')",
    "'GEMINI API KEY (Optional - AI Coach)'": "TranslationManager.get('setup_api_key')",
}

for k, v in replacements.items():
    content = content.replace(k, v)
    content = content.replace(k.replace("'", '"'), v)

with open('lib/screens/setup_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
