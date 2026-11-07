"""Çevrimdışı EN->TR sözlüğü üretir (assets/dictionary/en_tr.sqlite.gz).

Kaynak: Wiktionary (CC BY-SA 4.0), wiktextract dökümleri:
  https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl.gz  (~530 MB)
  https://kaikki.org/dictionary/Turkish/kaikki.org-dictionary-Turkish.jsonl.gz  (~40 MB)
Kullanım: python3 -I tool/dictionary/build_en_tr.py <en.jsonl.gz> <tr.jsonl.gz> assets/dictionary/en_tr.sqlite
          gzip -9 -n assets/dictionary/en_tr.sqlite
Çıktıyı değiştirirsen lib/services/offline_dictionary.dart içindeki dataVersion'ı artır.
source: 't' = İngilizce Wiktionary çeviri tablosu, 'r' = Türkçe girdinin İngilizce tanımından ters çevrildi.
"""
import gzip
import json
import re
import sqlite3
import sys
from collections import defaultdict

en_src, tr_src, out = sys.argv[1:4]
BAD_TAGS = {"obsolete", "archaic", "dated", "rare", "Ottoman-Turkish", "historical", "slang", "vulgar", "offensive"}
SKIP_POS = {"character", "name", "suffix", "prefix", "symbol", "infix", "interfix", "abbrev", "punct", "proverb", "romanization"}


def tr_items(obj):
    for t in obj.get("translations") or []:
        code = t.get("lang_code") or t.get("code")
        if code == "tr" and t.get("word") and not (set(t.get("tags") or []) & BAD_TAGS):
            yield t


NUM = re.compile(r"^\s*\d+[.)]\s*")


def clean_sense(text):
    return NUM.sub("", text).strip()


direct = defaultdict(lambda: defaultdict(list))  # (word,pos) -> sense -> [tr]
forms = {}  # inflected -> lemma
with gzip.open(en_src, "rt", encoding="utf-8") as f:
    for line in f:
        e = json.loads(line)
        if e.get("lang_code") != "en" or not e.get("word"):
            continue
        word, pos = e["word"].lower(), e.get("pos") or ""
        for s in e.get("senses") or []:
            for fo in s.get("form_of") or []:
                lemma = (fo.get("word") or "").lower()
                if lemma and lemma != word and word not in forms:
                    forms[word] = lemma
        found = [(clean_sense(t.get("sense") or ""), t["word"]) for t in tr_items(e)]
        for s in e.get("senses") or []:
            gloss = (s.get("glosses") or [""])[0]
            found += [(clean_sense(t.get("sense") or gloss), t["word"]) for t in tr_items(s)]
        for sense, w in found:
            lst = direct[(word, pos)][sense]
            if w not in lst:
                lst.append(w)

reverse = defaultdict(lambda: defaultdict(list))  # (en,pos) -> gloss -> [tr]
PAREN = re.compile(r"\([^)]*\)")
with gzip.open(tr_src, "rt", encoding="utf-8") as f:
    for line in f:
        e = json.loads(line)
        if e.get("lang_code") != "tr" or (e.get("pos") or "") in SKIP_POS:
            continue
        trw, pos = e.get("word"), e.get("pos") or ""
        if not trw:
            continue
        for s in e.get("senses") or []:
            if s.get("form_of") or set(s.get("tags") or []) & (BAD_TAGS | {"form-of", "alt-of"}):
                continue
            for gloss in s.get("glosses") or []:
                clean = PAREN.sub("", gloss)
                for piece in re.split(r"[;,]", clean):
                    p = piece.strip().lower().rstrip(".")
                    if pos == "verb" and p.startswith("to "):
                        p = p[3:]
                    if not p or len(p.split()) > 4 or not re.fullmatch(r"[a-z][a-z' -]*", p):
                        continue
                    lst = reverse[(p, pos)][gloss.strip()]
                    if trw not in lst:
                        lst.append(trw)

db = sqlite3.connect(out)
db.executescript("""
DROP TABLE IF EXISTS entry; DROP TABLE IF EXISTS form;
CREATE TABLE entry (word TEXT NOT NULL, pos TEXT NOT NULL, sense TEXT NOT NULL, tr TEXT NOT NULL, source TEXT NOT NULL);
CREATE TABLE form (word TEXT PRIMARY KEY, lemma TEXT NOT NULL) WITHOUT ROWID;
""")
rows = []
direct_words = {w for w, _ in direct}
for (w, pos), senses in direct.items():
    rows += [(w, pos, s, ", ".join(t), "t") for s, t in senses.items()]
rev_words = set()
for (w, pos), senses in reverse.items():
    if w in direct_words:
        continue  # çeviri tablosu varsa ters veriyi ekleme
    rev_words.add(w)
    for gloss, trs in list(senses.items())[:6]:
        rows.append((w, pos, gloss, ", ".join(trs[:6]), "r"))
db.executemany("INSERT INTO entry VALUES (?,?,?,?,?)", rows)
all_words = direct_words | rev_words
form_rows = [(k, v) for k, v in forms.items() if v in all_words and k not in direct_words]
db.executemany("INSERT INTO form VALUES (?,?)", form_rows)
db.execute("CREATE INDEX entry_word ON entry(word)")
db.commit()
db.execute("VACUUM")
db.close()
print(f"direct_words={len(direct_words)} reverse_only_words={len(rev_words)} rows={len(rows)} forms={len(form_rows)}")
