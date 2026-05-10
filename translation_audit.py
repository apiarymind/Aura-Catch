#!/usr/bin/env python3
"""
Translation Audit Script -- Aura Catch
Checks ALL translation JSON files against pl.json (reference).
Reports: MISSING keys, UNTRANSLATED values (identical to Polish).
"""

import os
import json
import sys

TRANSLATIONS_DIR = "assets/translations"
REFERENCE_FILE = "pl.json"

# Keys allowed to be identical (proper nouns, brand names, numbers)
ALLOW_IDENTICAL = {
    "app_title", "email", "mic_placeholder",
    "model",            # "Model" is universal technical term
    "status_label",     # "Status: {status}" — same word in Germanic/Romance langs
    "landing.f_ai_title",
    "landing.f_global_title",
    "landing.f_alerts_title",
    "landing.f_omnibus_title",  # "Historia Omnibus 180 Dni" — proper term / number
    "landing.t_style_title",
    "landing.t_hunter_title",
    "landing.t_original_title",
    "landing.p_pro_price",
    "landing.p_header_pro",
    "landing.p_header_free",
    "landing.p_pro_trial",
    "landing.p_f4_free",
    "landing.p_f4_pro",
    "landing.p_f5_pro",
    "landing.p_f5_title",   # "Reklamy/Ads" — same in cs/sk
    "landing.tos_s3_title",
}

def flatten(obj, prefix=""):
    result = {}
    for k, v in obj.items():
        full_key = f"{prefix}.{k}" if prefix else k
        if isinstance(v, dict):
            result.update(flatten(v, full_key))
        else:
            result[full_key] = v
    return result

def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def safe_print(text):
    print(text.encode('ascii', errors='replace').decode('ascii'))

ref_path = os.path.join(TRANSLATIONS_DIR, REFERENCE_FILE)
if not os.path.exists(ref_path):
    safe_print(f"ERROR: Reference file not found: {ref_path}")
    sys.exit(1)

ref_flat = flatten(load_json(ref_path))
ref_keys = set(ref_flat.keys())
total_keys = len(ref_keys)

safe_print("=" * 68)
safe_print("  AURA CATCH -- TRANSLATION AUDIT")
safe_print(f"  Reference: {REFERENCE_FILE}  |  Total keys: {total_keys}")
safe_print("=" * 68)

all_files = sorted([
    f for f in os.listdir(TRANSLATIONS_DIR)
    if f.endswith('.json') and f != REFERENCE_FILE
])

grand_missing = 0
grand_untranslated = 0
files_clean = 0
report_lines = []

for fname in all_files:
    fpath = os.path.join(TRANSLATIONS_DIR, fname)
    try:
        target_flat = flatten(load_json(fpath))
    except Exception as e:
        report_lines.append(f"  [ERR] {fname}  -- JSON PARSE ERROR: {e}")
        continue

    target_keys = set(target_flat.keys())
    missing = sorted(ref_keys - target_keys)
    untranslated = sorted([
        k for k in ref_keys
        if k in target_keys
        and target_flat[k] == ref_flat[k]
        and k not in ALLOW_IDENTICAL
        and len(str(ref_flat[k])) > 3
    ])

    if not missing and not untranslated:
        files_clean += 1
        report_lines.append(f"  [OK]  {fname:<22} {len(target_keys)} keys -- CLEAN")
    else:
        grand_missing += len(missing)
        grand_untranslated += len(untranslated)
        report_lines.append(f"\n  [!!]  {fname}")
        if missing:
            report_lines.append(f"        MISSING ({len(missing)}):")
            for k in missing:
                report_lines.append(f"          - {k}")
        if untranslated:
            report_lines.append(f"        UNTRANSLATED ({len(untranslated)}):")
            for k in untranslated:
                val = str(target_flat[k])[:55].replace('\n', '|')
                report_lines.append(f"          - {k}: \"{val}\"")

safe_print("")
for line in report_lines:
    safe_print(line)

safe_print("")
safe_print("=" * 68)
safe_print("  SUMMARY")
safe_print(f"  Files checked      : {len(all_files)}")
safe_print(f"  Files CLEAN        : {files_clean}")
safe_print(f"  Files with issues  : {len(all_files) - files_clean}")
safe_print(f"  Total MISSING keys : {grand_missing}")
safe_print(f"  Total UNTRANSLATED : {grand_untranslated}")
safe_print("=" * 68)

if grand_missing == 0 and grand_untranslated == 0:
    safe_print("  RESULT: ALL TRANSLATIONS VERIFIED -- 100% COMPLETE")
else:
    safe_print("  RESULT: ACTION REQUIRED -- see issues above")
safe_print("")
