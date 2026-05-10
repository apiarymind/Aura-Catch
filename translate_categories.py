import os
import sys
import json
import time
import random
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

pl_categories = {
    "cat_title": "Co możesz wyszukać?",
    "cat_subtitle": "Aura Catch najlepiej radzi sobie z produktami posiadającymi konkretne modele i parametry techniczne.",
    "cat_1_title": "Elektronika i Gadżety",
    "cat_1_desc": "Smartfony, laptopy, konsole, aparaty",
    "cat_2_title": "Dom i AGD",
    "cat_2_desc": "Ekspresy do kawy, roboty kuchenne, odkurzacze",
    "cat_3_title": "Moda i Beauty",
    "cat_3_desc": "Markowe buty, zegarki, perfumy, kosmetyki",
    "cat_4_title": "Hobby i Sport",
    "cat_4_desc": "Sprzęt wędkarski, rowery, akcesoria gamingowe",
}

dir_path = "assets/translations"
lang_map = {"pt": "pt", "zh": "zh-CN", "nb": "no"}
cache = {"pl": pl_categories}

def translate_value(g_lang, k, v):
    v_clean = v.replace('\n', ' [[NL]] ')
    for _ in range(3):
        try:
            res = GoogleTranslator(source='pl', target=g_lang).translate(v_clean)
            if res:
                return k, res.replace(' [[NL]] ', '\n').replace('[[NL]]', '\n')
        except Exception:
            time.sleep(1 + random.random() * 2)
    return k, v

def translate_for_lang(g_lang):
    if g_lang in cache:
        return cache[g_lang]
    print(f"Translating for {g_lang}...")
    sys.stdout.flush()
    translated = {}
    with ThreadPoolExecutor(max_workers=8) as ex:
        futures = [ex.submit(translate_value, g_lang, k, v) for k, v in pl_categories.items()]
        for future in as_completed(futures):
            k, v = future.result()
            translated[k] = v
    cache[g_lang] = translated
    return translated

file_names = sorted(os.listdir(dir_path))
for file_name in file_names:
    if not file_name.endswith('.json'):
        continue

    file_path = os.path.join(dir_path, file_name)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if "landing" not in data:
        print(f"Skipping {file_name} — no landing section")
        continue

    # Skip if already done
    if "cat_title" in data["landing"]:
        print(f"Skipping {file_name} — already has categories")
        continue

    lang_code_full = file_name.split('.')[0]
    base_lang = lang_code_full.replace('_', '-').split('-')[0]
    g_lang = lang_map.get(base_lang, base_lang)

    updates = translate_for_lang(g_lang)

    # Insert category keys at the beginning of the landing object (after existing keys)
    landing = data["landing"]
    # Merge categories into landing object
    for k, v in updates.items():
        landing[k] = v
    data["landing"] = landing

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Done {file_name}")
    sys.stdout.flush()

print("Categories translation complete.")
