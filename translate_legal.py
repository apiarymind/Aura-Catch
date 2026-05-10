import os
import sys
import json
import time
import random
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

# New Polish strings to inject
pl_new = {
    # ToS section 1 addition
    "tos_ownership": "Właścicielem serwisu oraz aplikacji Aura Catch jest Dariusz Szweda.",
    # ToS new section 3
    "tos_s3_title": "3. Zasady Subskrypcji i Limity (Plan FREE)",
    "tos_s3_1": "3.1. Użytkownik planu FREE może śledzić produkt przez okres 30 dni od momentu jego dodania.",
    "tos_s3_2": "3.2. W planie FREE aktualizacja ceny odbywa się 1 raz na dobę (co 24 godziny), w okolicach godziny, w której produkt został dodany do bazy.",
    "tos_s3_3": "3.3. Po upływie 30 dni śledzenie zostaje zakończone, a dane historyczne produktu są archiwizowane zgodnie z Polityką Prywatności.",
    # PP section 8 replacement
    "pp_s8_title": "8. Retencja danych",
    "pp_s8_1": "8.1. Dla użytkowników planu FREE: Dane dotyczące śledzonych produktów są usuwane z bazy po 30 dniach od zakończenia okresu śledzenia.",
    "pp_s8_2": 'Dane konta są przechowywane do momentu skorzystania przez użytkownika z funkcji "Usuń konto i dane".',
}

dir_path = "assets/translations"
lang_map = {"pt": "pt", "zh": "zh-CN", "nb": "no"}
cache = {"pl": pl_new}

def translate_value(g_lang, k, v):
    for _ in range(3):
        try:
            res = GoogleTranslator(source='pl', target=g_lang).translate(v)
            if res:
                return k, res
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
        futures = [ex.submit(translate_value, g_lang, k, v) for k, v in pl_new.items()]
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
        continue

    # Skip if already done
    if "tos_ownership" in data["landing"]:
        print(f"Skipping {file_name}")
        continue

    lang_code_full = file_name.split('.')[0]
    base_lang = lang_code_full.replace('_', '-').split('-')[0]
    g_lang = lang_map.get(base_lang, base_lang)

    updates = translate_for_lang(g_lang)
    for k, v in updates.items():
        data["landing"][k] = v

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Done {file_name}")
    sys.stdout.flush()

print("Legal translations complete.")
