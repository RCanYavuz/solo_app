import os
import re
import subprocess

# Get files modified in the last few commits + unstaged
git_cmd = 'git diff --name-only HEAD~7'
res = subprocess.run(git_cmd, shell=True, capture_output=True, text=True)
files = [f.strip() for f in res.stdout.splitlines() if f.strip().endswith('.dart') and 'lib/' in f]

# Add any other screens and widgets
for root, dirs, fnames in os.walk('lib'):
    for fname in fnames:
        if fname.endswith('.dart'):
            rel = os.path.relpath(os.path.join(root, fname)).replace('\\', '/')
            if rel not in files:
                files.append(rel)

print(f"Analyzing {len(files)} files...")

out_report = []

for fpath in files:
    if 'translation_manager' in fpath:
        continue
    if not os.path.exists(fpath):
        continue
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.splitlines()

    for idx, line in enumerate(lines, 1):
        sline = line.strip()
        if sline.startswith('//') or sline.startswith('/*') or sline.startswith('*'):
            continue
        
        # Check for Text('...') or Text("...")
        # where content doesn't use TranslationManager and doesn't use isTurkish
        text_matches = re.findall(r"Text\(\s*(['\"][^'\"]+['\"])", line)
        for tm in text_matches:
            # tm is a string literal inside Text(...)
            # Skip if it is purely numeric or punctuation or single symbol like "+", "-", "x", "kg", "kcal"
            clean = tm.strip("'\"")
            if re.match(r"^[\d\s\+\-\:\.\,\%\/\(\)\*\#\@\!\>\<\=\|\_]+$", clean):
                continue
            if clean in ['kg', 'g', 'kcal', 'L', 'h', 'm', 's', 'RIR', 'SET', 'EXP', 'HP', 'MP', 'STR', 'AGI', 'INT', 'VIT', 'PER', 'LUK', 'CRIT']:
                continue
            # If line doesn't have isTurkish or TranslationManager
            if 'TranslationManager' not in line and 'isTurkish' not in line:
                out_report.append(f"{fpath}:{idx} -> {tm} (Line: {sline})")

with open('scratch/hardcoded_text_report.txt', 'w', encoding='utf-8') as f:
    f.write(f"Total Hardcoded Text() found: {len(out_report)}\n\n")
    for item in out_report:
        f.write(item + "\n")

print(f"Report written with {len(out_report)} entries.")
