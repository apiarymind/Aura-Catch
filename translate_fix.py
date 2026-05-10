#!/usr/bin/env python3
"""
Fix untranslated keys found by translation_audit.py
"""
import os, sys, json, time, random
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

TRANSLATIONS_DIR = "assets/translations"
lang_map = {"pt": "pt", "zh": "zh-CN", "nb": "no"}

# Exact issues found by audit, grouped by key + Polish value
fixes = {
    # status_label — the "{status}" placeholder must be preserved
    "status_label": "Status: {status}",
    # landing keys
    "landing.p_f5_title": "Reklamy",
    "landing.social_proof_hundreds": "+ setki lokalnych sklepów",
    "landing.f_omnibus_title": "Historia Omnibus 180 Dni",
    # model (en_US / en-US only — "Model" is the same in English, skip those)
}

# Files where each key needs fixing
targets = {
    "status_label": [
        "da.json","de-AT.json","de-CH.json","de.json","de_AT.json","de_CH.json",
        "en-GB.json","en-IE.json","en-US.json","en.json","en_GB.json","en_IE.json","en_US.json",
        "hr.json","nb.json","nl-BE.json","nl.json","nl_BE.json","no.json",
        "ro.json","sl.json","sv.json"
    ],
    "landing.p_f5_title": ["cs.json","sk.json"],
    "landing.social_proof_hundreds": ["cs.json"],
    "landing.f_omnibus_title": ["es.json","fi.json","sv.json"],
}

# model in en_US — "Model" is actually correct in English, skip it.

def get_lang(fname):
    base = fname.split('.')[0].replace('_','-').split('-')[0]
    return lang_map.get(base, base)

def translate(text, g_lang, preserve_placeholder=False):
    """Translate text, restoring placeholders like {status}."""
    import re
    placeholders = re.findall(r'\{[^}]+\}', text)
    masked = text
    for i, ph in enumerate(placeholders):
        masked = masked.replace(ph, f"__PH{i}__")
    for _ in range(3):
        try:
            result = GoogleTranslator(source='pl', target=g_lang).translate(masked)
            if result:
                for i, ph in enumerate(placeholders):
                    result = result.replace(f"__PH{i}__", ph)
                    result = result.replace(f"__ PH{i}__", ph)
                    result = result.replace(f"__PH {i}__", ph)
                return result
        except Exception:
            time.sleep(1 + random.random()*2)
    return text

def set_nested(d, dotkey, value):
    keys = dotkey.split('.')
    for k in keys[:-1]:
        d = d.setdefault(k, {})
    d[keys[-1]] = value

def get_nested(d, dotkey):
    keys = dotkey.split('.')
    for k in keys:
        d = d.get(k, {})
    return d if isinstance(d, str) else None

# Build work list: (fname, dotkey, polish_value)
work = []
for dotkey, pl_val in fixes.items():
    for fname in targets.get(dotkey, []):
        work.append((fname, dotkey, pl_val))

print(f"Fixing {len(work)} entries across {len(set(f for f,_,_ in work))} files...\n")

for fname, dotkey, pl_val in work:
    fpath = os.path.join(TRANSLATIONS_DIR, fname)
    with open(fpath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    g_lang = get_lang(fname)
    translated = translate(pl_val, g_lang)
    set_nested(data, dotkey, translated)

    with open(fpath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    val_preview = translated[:50].replace('\n','|')
    print(f"  Fixed {fname:<22} [{dotkey}] => \"{val_preview}\"")
    sys.stdout.flush()

print("\nAll fixes applied.")
