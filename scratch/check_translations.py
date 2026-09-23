import os
import re

turkish_chars = re.compile(r'[ğüşıöçĞÜŞİÖÇ]')
dart_files = []
for root, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart') and not f.endswith('translation_manager.dart'):
            dart_files.append(os.path.join(root, f))

findings = []
for fpath in dart_files:
    with open(fpath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        for idx, line in enumerate(lines, 1):
            sline = line.strip()
            if sline.startswith('//') or sline.startswith('/*') or sline.startswith('*'):
                continue
            
            # Check for hardcoded string literals with Turkish characters
            # Pattern matches single or double quoted strings
            matches = re.findall(r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"", line)
            for m in matches:
                # exclude font names, svg, assets, etc.
                if any(x in m for x in ['.png', '.jpg', '.mp3', '.wav', '.json', 'assets/']):
                    continue
                # If it's a TranslationManager dictionary or get, ignore
                if turkish_chars.search(m):
                    # Check if line contains isTurkish ternary (which is a valid bilingual pattern: isTurkish ? '...' : '...')
                    if 'isTurkish' in line or 'appLanguage' in line:
                        continue
                    findings.append((fpath, idx, line.strip(), m.strip()))

print(f"Total occurrences of potentially untranslated Turkish strings: {len(findings)}")
for fpath, idx, l, m in findings:
    print(f"{fpath}:{idx} -> {m}")
    print(f"   Line: {l}")
