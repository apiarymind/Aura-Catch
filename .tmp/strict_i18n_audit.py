import json
import re
from pathlib import Path

root = Path(r"e:/Aura_Catch/aura_catch")
lib = root / "lib"
trans = root / "assets" / "translations"

used = set()
pat = re.compile(r"\btr\(\s*'([^']+)'")
for f in lib.rglob("*.dart"):
    txt = f.read_text(encoding="utf-8", errors="ignore")
    used.update(pat.findall(txt))

en = json.loads((trans / "en.json").read_text(encoding="utf-8-sig"))

ignore_same = {"app_title"}

total_missing = 0
total_same = 0
for jf in sorted(trans.glob("*.json")):
    n = jf.name
    if n.startswith("en"):
        continue
    d = json.loads(jf.read_text(encoding="utf-8-sig"))
    miss = sorted([k for k in used if k not in d])
    same = sorted([k for k in used if k in d and k in en and str(d[k]) == str(en[k]) and k not in ignore_same])
    if miss or same:
        print(f"{n}: missing={len(miss)} same_as_en={len(same)} same_sample={same[:8]}")
    total_missing += len(miss)
    total_same += len(same)

print("TOTAL_MISSING", total_missing)
print("TOTAL_SAME_AS_EN", total_same)
