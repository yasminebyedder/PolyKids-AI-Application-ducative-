from fastapi import FastAPI, File, UploadFile
from PIL import Image
import io
import cv2
import easyocr
import numpy as np
from langdetect import detect
from deep_translator import GoogleTranslator

app = FastAPI()

reader_latin = easyocr.Reader(['fr', 'en'], gpu=False)
reader_arabic = easyocr.Reader(['ar', 'en'], gpu=False)

ALL_LANGS = ["fr", "en", "ar"]

LANG_MAP = {
    "fr": "fr-FR",
    "en": "en-US",
    "ar": "ar-SA",
}

LANG_NAMES = {
    "fr": "Français",
    "en": "Anglais",
    "ar": "Arabe",
}

TRANSLATOR_CODES = {
    "fr": "fr",
    "en": "en",
    "ar": "ar",
}

def contains_arabic(text: str) -> bool:
    return any('\u0600' <= c <= '\u06FF' for c in text)

def translate_text(text: str, source_lang: str, target_lang: str) -> str:
    try:
        src = TRANSLATOR_CODES.get(source_lang, "auto")
        tgt = TRANSLATOR_CODES.get(target_lang, "en")
        return GoogleTranslator(source=src, target=tgt).translate(text)
    except Exception as e:
        return f"[Erreur traduction vers {target_lang}: {str(e)}]"

@app.get("/")
def home():
    return {"message": "OCR + Traduction API fonctionne"}

@app.post("/ocr")
async def ocr_scan(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        pil_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_np = np.array(pil_image)
        frame = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)

        result = reader_latin.readtext(frame, detail=0)
        detected_text = " ".join(result).strip()

        result_arabic = reader_arabic.readtext(frame, detail=0)
        detected_text_arabic = " ".join(result_arabic).strip()

        if contains_arabic(detected_text_arabic):
            detected_text = detected_text_arabic
        elif not detected_text:
            detected_text = detected_text_arabic

        if not detected_text:
            return {
                "translations": [],
                "error": "Aucun texte détecté"
            }

        try:
            detected_lang = detect(detected_text)
            if detected_lang not in ALL_LANGS:
                detected_lang = "ar" if contains_arabic(detected_text) else "fr"
        except Exception:
            detected_lang = "ar" if contains_arabic(detected_text) else "fr"

        target_langs = [lang for lang in ALL_LANGS if lang != detected_lang]

        translations = []
        for target_lang in target_langs:
            translated = translate_text(detected_text, detected_lang, target_lang)
            translations.append({
                "lang_code": LANG_MAP.get(target_lang, "en-US"),
                "lang": target_lang,
                "lang_name": LANG_NAMES.get(target_lang, target_lang),
                "text": translated
            })

        return {
            "source_lang": LANG_MAP.get(detected_lang, "fr-FR"),
            "detected_lang_name": LANG_NAMES.get(detected_lang, detected_lang),
            "translations": translations
        }

    except Exception as e:
        return {
            "error": str(e),
            "translations": [],
        }