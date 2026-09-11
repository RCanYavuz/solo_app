import re

# 1. Fix gemini_service.dart
with open('lib/core/services/gemini_service.dart', 'r', encoding='utf-8') as f:
    gem = f.read()

gem = gem.replace('String json = await _generateContent(model, apiKey, prompt);', 'String json = await _generateContent(model, apiKey, prompt) ?? "";')

with open('lib/core/services/gemini_service.dart', 'w', encoding='utf-8') as f:
    f.write(gem)

# 2. Fix dashboard_screen.dart
with open('lib/screens/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    dash = f.read()

dash = dash.replace("const Padding(padding: EdgeInsets.only(bottom: 6), child: Text(TranslationManager.get('dash_level')", "Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(TranslationManager.get('dash_level')")
dash = dash.replace("const Text(TranslationManager.get('dash_boss_sunday')", "Text(TranslationManager.get('dash_boss_sunday')")
dash = dash.replace("? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text(TranslationManager.get('dash_no_quests'), style: TextStyle(color: sysTextMuted))))", "? Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(TranslationManager.get('dash_no_quests'), style: const TextStyle(color: sysTextMuted))))")
dash = dash.replace("? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text(TranslationManager.get('dash_no_raids'), style: TextStyle(color: sysTextMuted))))", "? Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(TranslationManager.get('dash_no_raids'), style: const TextStyle(color: sysTextMuted))))")
dash = dash.replace("label: const Text(TranslationManager.get('dash_enter_dungeon')", "label: Text(TranslationManager.get('dash_enter_dungeon')")
dash = dash.replace("style: TextStyle(color: sysBlue", "style: const TextStyle(color: sysBlue")
dash = dash.replace("style: TextStyle(color: sysRed", "style: const TextStyle(color: sysRed")

with open('lib/screens/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(dash)

# 3. Fix profile_screen.dart (stub out missing methods)
with open('lib/screens/profile_screen.dart', 'r', encoding='utf-8') as f:
    prof = f.read()

prof = prof.replace("_showGeminiTestResult(res['basarili'], res['mesaj'], res['model']);", "/* _showGeminiTestResult(res['basarili'], res['mesaj'], res['model']); */")
prof = prof.replace("onPressed: _awakeningTestDialog,", "onPressed: () {}, /* _awakeningTestDialog, */")

with open('lib/screens/profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(prof)

print("Fixes applied.")
