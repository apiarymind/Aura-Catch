import json
from pathlib import Path

root = Path(r"e:/Aura_Catch/aura_catch")
trans = root / "assets" / "translations"

core = {
    "en": {
        "edit_details": "Confirm & Edit Details",
        "brand": "Brand",
        "model": "Model",
        "target_price": "Target Price",
        "condition": "Condition",
        "cancel": "Cancel",
        "confirm": "Confirm",
    },
    "pl": {
        "edit_details": "Potwierdz i edytuj szczegoly",
        "brand": "Marka",
        "model": "Model",
        "target_price": "Cena docelowa",
        "condition": "Stan",
        "cancel": "Anuluj",
        "confirm": "Potwierdz",
    },
    "de": {"edit_details":"Bestatigen und Details bearbeiten","brand":"Marke","model":"Modell","target_price":"Zielpreis","condition":"Zustand","cancel":"Abbrechen","confirm":"Bestatigen"},
    "fr": {"edit_details":"Confirmer et modifier les details","brand":"Marque","model":"Modele","target_price":"Prix cible","condition":"Etat","cancel":"Annuler","confirm":"Confirmer"},
    "it": {"edit_details":"Conferma e modifica dettagli","brand":"Marca","model":"Modello","target_price":"Prezzo obiettivo","condition":"Condizione","cancel":"Annulla","confirm":"Conferma"},
    "es": {"edit_details":"Confirmar y editar detalles","brand":"Marca","model":"Modelo","target_price":"Precio objetivo","condition":"Condicion","cancel":"Cancelar","confirm":"Confirmar"},
    "pt": {"edit_details":"Confirmar e editar detalhes","brand":"Marca","model":"Modelo","target_price":"Preco alvo","condition":"Condicao","cancel":"Cancelar","confirm":"Confirmar"},
    "nl": {"edit_details":"Bevestig en bewerk details","brand":"Merk","model":"Model","target_price":"Doelprijs","condition":"Conditie","cancel":"Annuleren","confirm":"Bevestigen"},
    "no": {"edit_details":"Bekreft og rediger detaljer","brand":"Merke","model":"Modell","target_price":"Malpris","condition":"Tilstand","cancel":"Avbryt","confirm":"Bekreft"},
    "nb": {"edit_details":"Bekreft og rediger detaljer","brand":"Merke","model":"Modell","target_price":"Malpris","condition":"Tilstand","cancel":"Avbryt","confirm":"Bekreft"},
    "sv": {"edit_details":"Bekrafta och redigera detaljer","brand":"Marke","model":"Modell","target_price":"Malpris","condition":"Skick","cancel":"Avbryt","confirm":"Bekrafta"},
    "da": {"edit_details":"Bekraeft og rediger detaljer","brand":"Maerke","model":"Model","target_price":"Malpris","condition":"Stand","cancel":"Annuller","confirm":"Bekraeft"},
    "fi": {"edit_details":"Vahvista ja muokkaa tietoja","brand":"Merkki","model":"Malli","target_price":"Tavoitehinta","condition":"Kunto","cancel":"Peruuta","confirm":"Vahvista"},
    "cs": {"edit_details":"Potvrdit a upravit detaily","brand":"Znacka","model":"Model","target_price":"Cilova cena","condition":"Stav","cancel":"Zrusit","confirm":"Potvrdit"},
    "sk": {"edit_details":"Potvrdit a upravit detaily","brand":"Znacka","model":"Model","target_price":"Cielova cena","condition":"Stav","cancel":"Zrusit","confirm":"Potvrdit"},
    "sl": {"edit_details":"Potrdi in uredi podrobnosti","brand":"Znamka","model":"Model","target_price":"Ciljna cena","condition":"Stanje","cancel":"Preklici","confirm":"Potrdi"},
    "hr": {"edit_details":"Potvrdi i uredi detalje","brand":"Marka","model":"Model","target_price":"Ciljana cijena","condition":"Stanje","cancel":"Odustani","confirm":"Potvrdi"},
    "ro": {"edit_details":"Confirma si editeaza detalii","brand":"Marca","model":"Model","target_price":"Pret tinta","condition":"Stare","cancel":"Anuleaza","confirm":"Confirma"},
    "hu": {"edit_details":"Megerosites es adatok szerkesztese","brand":"Marka","model":"Modell","target_price":"Celar","condition":"Allapot","cancel":"Megse","confirm":"Megerosites"},
    "bg": {"edit_details":"Потвърди и редактирай детайли","brand":"Марка","model":"Модел","target_price":"Целева цена","condition":"Състояние","cancel":"Отказ","confirm":"Потвърди"},
    "uk": {"edit_details":"Підтвердити і змінити деталі","brand":"Бренд","model":"Модель","target_price":"Цільова ціна","condition":"Стан","cancel":"Скасувати","confirm":"Підтвердити"},
    "el": {"edit_details":"Επιβεβαιωση και επεξεργασια στοιχειων","brand":"Μαρκα","model":"Μοντελο","target_price":"Τιμη στοχος","condition":"Κατασταση","cancel":"Ακυρωση","confirm":"Επιβεβαιωση"},
    "et": {"edit_details":"Kinnita ja muuda andmeid","brand":"Bränd","model":"Mudel","target_price":"Siht hind","condition":"Seisukord","cancel":"Loobu","confirm":"Kinnita"},
    "lt": {"edit_details":"Patvirtinkite ir redaguokite detales","brand":"Prekes zenklas","model":"Modelis","target_price":"Tiksline kaina","condition":"Bukle","cancel":"Atsaukti","confirm":"Patvirtinti"},
    "lv": {"edit_details":"Apstiprini un redigē detaļas","brand":"Zimols","model":"Modelis","target_price":"Merkа cena","condition":"Stavoklis","cancel":"Atcelt","confirm":"Apstiprinat"},
    "is": {"edit_details":"Stadfesta og breyta upplysingum","brand":"Voruheiti","model":"Modell","target_price":"Markverd","condition":"Astаnd","cancel":"Haetta vid","confirm":"Stadfesta"},
}

def base_lang(name: str) -> str:
    return name[:2].lower()

for f in trans.glob('*.json'):
    data = json.loads(f.read_text(encoding='utf-8-sig'))
    lang = base_lang(f.name)
    pack = core.get(lang, core['en'])
    for k, v in pack.items():
        data[k] = v
    f.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')

print('Core form translation keys updated in all locale files.')
