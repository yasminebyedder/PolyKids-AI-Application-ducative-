from fastapi import FastAPI, File, UploadFile
from PIL import Image
import io
import cv2
import easyocr
import numpy as np
from langdetect import detect

app = FastAPI()

# ✅ Deux readers séparés : arabe incompatible avec fr+en ensemble
reader_latin = easyocr.Reader(['fr', 'en'], gpu=False)
reader_arabic = easyocr.Reader(['ar', 'en'], gpu=False)

LANG_MAP = {
    "fr": "fr-FR",
    "en": "en-US",
    "ar": "ar-SA",
}

def contains_arabic(text: str) -> bool:
    return any('\u0600' <= c <= '\u06FF' for c in text)

@app.get("/")
def home():
    return {"message": "OCR API fonctionne"}

@app.post("/ocr")
async def ocr_scan(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        pil_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_np = np.array(pil_image)
        frame = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)

        # ① Essai avec reader latin d'abord
        result = reader_latin.readtext(frame, detail=0)
        detected_text = " ".join(result).strip()

        # ② Toujours essayer le reader arabe aussi
        result_arabic = reader_arabic.readtext(frame, detail=0)
        detected_text_arabic = " ".join(result_arabic).strip()

        # ③ Priorité à l'arabe s'il contient des caractères arabes
        if contains_arabic(detected_text_arabic):
            detected_text = detected_text_arabic
        elif not detected_text:
            detected_text = detected_text_arabic

        if not detected_text:
            return {"text": "Aucun texte détecté", "lang": "fr-FR"}

        # ④ Détection de langue
        try:
            detected_lang = detect(detected_text)
            lang_code = LANG_MAP.get(detected_lang, "fr-FR")
        except Exception:
            lang_code = "ar-SA" if contains_arabic(detected_text) else "fr-FR"

        return {"text": detected_text, "lang": lang_code}

    except Exception as e:
        return {"error": str(e), "text": "Erreur de traitement", "lang": "fr-FR"}