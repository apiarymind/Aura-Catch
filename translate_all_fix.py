import os, sys, json, time, random
from deep_translator import GoogleTranslator
import glob

# The directories containing translations
DIRS = ["e:/Aura_Catch/aura_catch/assets/translations", "e:/Aura_Catch/tłumaczenia/translations"]

lang_map = {"pt": "pt", "zh": "zh-CN", "nb": "no"}

def get_lang(fname):
    base = os.path.basename(fname).split('.')[0].replace('_','-').split('-')[0]
    return lang_map.get(base, base)

def translate(text, g_lang, preserve_placeholder=False):
    import re
    placeholders = re.findall(r'\{[^}]+\}', text)
    masked = text
    for i, ph in enumerate(placeholders):
        masked = masked.replace(ph, f"__PH{i}__")
    
    # Don't translate if it's english
    if g_lang == 'en': return text

    for _ in range(3):
        try:
            result = GoogleTranslator(source='en', target=g_lang).translate(masked)
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

# The English texts we want to use as a source
fixes = {
    "landing.f_omnibus_title": "180-Day Price History",
    "landing.t_hunter_title": "HUNTER",
    "landing.f_filters_desc": "Track only what interests you: New, Used or Outlet items.",
    "landing.p_header_free": "FREE plan\n{currency} 0 / always",
    "landing.p_pro_price": "{currency} 5.99 / month",
    "landing.p_f6_pro": "Priority, instant notifications about price drops"
}

for d in DIRS:
    files = glob.glob(os.path.join(d, "*.json"))
    for fpath in files:
        fname = os.path.basename(fpath)
        g_lang = get_lang(fname)
        
        # Skip Spanish and Greek as user already provided exact manual translations for them
        if g_lang in ['es', 'el', 'pl']: # Also skip PL since it's already polish
            continue
            
        with open(fpath, 'r', encoding='utf-8-sig') as f:
            data = json.load(f)

        changed = False
        for dotkey, en_text in fixes.items():
            translated = translate(en_text, g_lang)
            set_nested(data, dotkey, translated)
            changed = True
            
        if changed:
            with open(fpath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
            print(f"Updated {fpath} for language {g_lang}")

print("All done!")
