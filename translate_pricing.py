import os
import sys
import json
import time
import random
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

# New Polish source strings for the changed keys
pl_updates = {
    "p_f3_free": "30 dni śledzenia produktu",
    "p_f3_scan_title": "Częstotliwość skanowania",
    "p_f3_scan_free": "Skanowanie ceny 1 raz dziennie\n(co 24h)",
    "p_f3_scan_pro": "Skanowanie priorytetowe\n(wielokrotnie dziennie)",
}

dir_path = "assets/translations"
lang_map = {"pt": "pt", "zh": "zh-CN", "nb": "no"}
cache = {"pl": pl_updates}

def translate_value(g_lang, k, v):
    v_clean = v.replace('\n', ' [[NL]] ')
    retries = 3
    for attempt in range(retries):
        try:
            res = GoogleTranslator(source='pl', target=g_lang).translate(v_clean)
            if res:
                return k, res.replace(' [[NL]] ', '\n').replace('[[NL]]', '\n')
        except Exception as e:
            time.sleep(1 + random.random() * 2)
    return k, v

def translate_for_lang(g_lang):
    if g_lang in cache:
        return cache[g_lang]
    print(f"Fetching for {g_lang}...")
    sys.stdout.flush()
    translated = {}
    with ThreadPoolExecutor(max_workers=6) as ex:
        futures = [ex.submit(translate_value, g_lang, k, v) for k, v in pl_updates.items()]
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

    lang_code_full = file_name.split('.')[0]
    base_lang = lang_code_full.replace('_', '-').split('-')[0]
    g_lang = lang_map.get(base_lang, base_lang)

    updates = translate_for_lang(g_lang)

    landing = data["landing"]
    # Update existing p_f3_free key
    landing["p_f3_free"] = updates["p_f3_free"]
    # Insert new scan keys after p_f3_pro if not present
    # Rebuild landing dict preserving order and inserting after p_f3_pro
    new_landing = {}
    for k, v in landing.items():
        new_landing[k] = v
        if k == "p_f3_pro":
            new_landing["p_f3_scan_title"] = updates["p_f3_scan_title"]
            new_landing["p_f3_scan_free"] = updates["p_f3_scan_free"]
            new_landing["p_f3_scan_pro"] = updates["p_f3_scan_pro"]

    # In case p_f3_pro was already followed by these keys (idempotency)
    if "p_f3_scan_title" not in landing:
        data["landing"] = new_landing
    else:
        # Keys already present, just update values
        landing["p_f3_scan_title"] = updates["p_f3_scan_title"]
        landing["p_f3_scan_free"] = updates["p_f3_scan_free"]
        landing["p_f3_scan_pro"] = updates["p_f3_scan_pro"]
        data["landing"] = landing

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Done {file_name}")
    sys.stdout.flush()

print("Pricing update complete.")
