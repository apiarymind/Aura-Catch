import os
import sys
import json
import time
from deep_translator import GoogleTranslator

pl_landing = {
    "hero_title": "Aura Catch – Przestań tracić czas na szukanie promocji",
    "desc_p1": "Ile godzin tracisz na ręczne przeszukiwanie sklepów, by znaleźć idealny prezent lub sprzęt do domu w założonym budżecie?\n",
    "desc_bold1": "Z Aura Catch to już nie problem.\n\n",
    "desc_p2": "Ustalasz cenę, a nasze ",
    "desc_bold2": "AI na bieżąco monitoruje 31 rynków",
    "desc_p3": " za Ciebie.\n",
    "desc_bold3": "Ty oszczędzasz czas, my polujemy na spadki cen.",
    "btn_open_app": "Otwórz Aplikację",
    "btn_login": "Zaloguj się",
    "social_proof_title": "Śledzimy ceny z globalnych sieci i sklepów",
    "social_proof_hundreds": "+ setki lokalnych sklepów",
    "markets_title": "Obsługujemy 31 rynków na całym świecie:",
    "features_title": "Dlaczego Aura Catch?",
    "f_ai_title": "AI Recognition",
    "f_ai_desc": "Wyszukiwanie i rozpoznawanie produktów wspierane przez inteligentne modele AI.",
    "f_global_title": "Global Markets",
    "f_global_desc": "Monitoring ofert i cen na 31 rynkach, byś zawsze widział pełny obraz.",
    "f_alerts_title": "Real-time Alerts",
    "f_alerts_desc": "Natychmiastowe powiadomienia o spadkach cen i nowych okazjach.",
    "f_omnibus_title": "Historia Omnibus 180 Dni",
    "f_omnibus_desc": "Weryfikujemy fałszywe promocje, pokazując najniższą cenę z ostatnich 6 miesięcy.",
    "f_filters_title": "Precyzyjne Filtry",
    "f_filters_desc": "Śledź tylko to, co Cię interesuje: sprzęt Nowy, Używany lub z Outletu.",
    "f_customs_title": "Koszty Dostawy i Cło",
    "f_customs_desc": "Aplikacja śledzi czystą cenę samego produktu. Pamiętaj, że system nie uwzględnia i nie pokazuje ukrytych kosztów dostawy ani ewentualnego cła przy zakupach globalnych.",
    "themes_title": "Wybierz swój styl - 3 unikalne motywy",
    "t_style_title": "STYLE (Beauty)",
    "t_style_desc": "Subtelna i elegancka estetyka w odcieniach różowego złota.",
    "t_hunter_title": "ŁOWCA (Hunter)",
    "t_hunter_desc": "Taktyczny, ciemny interfejs z neonowymi akcentami dla łowców okazji.",
    "t_original_title": "Original Aura Catch",
    "t_original_desc": "Klasyczny, uniwersalny design w odcieniach głębokiego granatu.",
    "faq_title": "Często zadawane pytania",
    "faq_q1": "Czy aplikacja uwzględnia koszty dostawy?",
    "faq_a1": "Nie, nasz radar skupia się wyłącznie na twardej cenie bazowej produktu, ignorując zmienne koszty wysyłki.",
    "faq_q2": "Co jeśli produkt zostanie wyprzedany?",
    "faq_a2": "System weryfikuje dostępność (In-Stock). Jeśli towaru nie ma, ignorujemy cenę i nie wysyłamy fałszywych alarmów.",
    "faq_q3": "Czy korzystanie z aplikacji jest darmowe?",
    "faq_a3": "Tak! Plan FREE pozwala na darmowe śledzenie 3 produktów w cyklu 30-dniowym.",
    "soon_title": "Już wkrótce na Twoim telefonie!",
    "soon_google": "Pobierz z Google Play",
    "soon_apple": "Pobierz z App Store",
    "soon_badge": "Wkrótce",
    "pricing_title": "Cennik",
    "pricing_subtitle": "Zacznij za darmo. Przejdź na PRO kiedy chcesz.",
    "p_header_func": "Funkcjonalność / Limit",
    "p_header_free": "Plan FREE\n0 PLN / zawsze",
    "p_header_pro": "Plan PRO",
    "p_pro_price": "5.99 PLN/mc lub 49.99 PLN/rok",
    "p_pro_trial": "30 dni probnych gratis",
    "p_f1_title": "Limit produktów",
    "p_f1_free": "Maks. 3 produkty\nw cyklu 30-dniowym",
    "p_f1_pro": "Maks. 10 aktywnych\nslotów na produkty",
    "p_f2_title": "Zarządzanie slotami",
    "p_f2_free": "Nowy slot dostępny\npo 30 dniach od dodania",
    "p_f2_pro": "Pełna elastyczność:\nusuwaj i dodawaj w każdej chwili",
    "p_f3_title": "Czas śledzenia",
    "p_f3_free": "Wygasa po 7 dniach\nna produkt",
    "p_f3_pro": "Nielimitowany\n(brak wygasania)",
    "p_f4_title": "Rynki docelowe",
    "p_f4_free": "31 rynków globalnych",
    "p_f4_pro": "31 rynków globalnych",
    "p_f5_title": "Reklamy",
    "p_f5_free": "Zawiera reklamy",
    "p_f5_pro": "100% Bez reklam\n(Ad-Free)",
    "p_f6_title": "Powiadomienia",
    "p_f6_free": "Standardowe",
    "p_f6_pro": "Priorytetowe, natychmiastowe\npowiadomienia o spadkach",
    "p_recommended": "Polecany"
}

dir_path = "assets/translations"

lang_map = {
    "pt": "pt",
    "zh": "zh-CN",
    "nb": "no",
}

def process_all():
    file_names = sorted(os.listdir(dir_path))
    for file_name in file_names:
        if not file_name.endswith('.json'):
            continue
            
        lang_code_full = file_name.split('.')[0]
        base_lang = lang_code_full.replace('_', '-').split('-')[0]
        g_lang = lang_map.get(base_lang, base_lang)
        
        file_path = os.path.join(dir_path, file_name)
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        if "landing" in data and len(data["landing"]) == len(pl_landing):
            print(f"Skipping {file_name}, already translated.")
            sys.stdout.flush()
            continue
            
        print(f"Translating for {file_name} (base: {g_lang})...")
        sys.stdout.flush()
        
        translated_landing = {}
        if base_lang == 'pl':
            translated_landing = pl_landing
        else:
            try:
                translator = GoogleTranslator(source='pl', target=g_lang)
                keys = list(pl_landing.keys())
                values_to_translate = []
                
                for k in keys:
                    v = pl_landing[k]
                    if k.startswith('t_') and k.endswith('title') and k != 'themes_title':
                        pass
                    else:
                        v_clean = v.replace('\n', ' [[NL]] ')
                        values_to_translate.append(v_clean)
                        
                res_list = translator.translate_batch(values_to_translate)
                
                idx = 0
                for k in keys:
                    if k.startswith('t_') and k.endswith('title') and k != 'themes_title':
                        translated_landing[k] = pl_landing[k]
                    else:
                        res = res_list[idx]
                        if res:
                            res = res.replace(' [[NL]] ', '\n').replace('[[NL]]', '\n')
                            translated_landing[k] = res
                        else:
                            translated_landing[k] = pl_landing[k]
                        idx += 1
                        
            except Exception as e:
                print(f"Error for {g_lang}: {e}")
                sys.stdout.flush()
                translated_landing = pl_landing
                
        data["landing"] = translated_landing
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            
        print(f"Done {file_name}")
        sys.stdout.flush()

process_all()
print("Translation script complete.")
