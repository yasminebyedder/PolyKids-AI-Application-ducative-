from fastapi import FastAPI, File, UploadFile
from PIL import Image
import io
import cv2
import easyocr
import pyttsx3
import numpy as np
import tempfile
import os

app = FastAPI()

# -----------------------------
# OCR model chargé une seule fois
# -----------------------------
reader = easyocr.Reader(['en'], gpu=False)


# -----------------------------
# Fonction voix
# -----------------------------
def speak_text(text):
    engine = pyttsx3.init()
    engine.setProperty('rate', 150)
    engine.setProperty('volume', 1)

    temp_audio = tempfile.NamedTemporaryFile(delete=False, suffix=".mp3")
    audio_path = temp_audio.name
    temp_audio.close()

    engine.save_to_file(text, audio_path)
    engine.runAndWait()
    engine.stop()

    return audio_path


# -----------------------------
# Route accueil
# -----------------------------
@app.get("/")
def home():
    return {"message": "OCR API fonctionne"}


# -----------------------------
# OCR + Text-to-Speech API
# -----------------------------
@app.post("/ocr")
async def ocr_scan(file: UploadFile = File(...)):
    try:
        # Lire image envoyée
        image_bytes = await file.read()

        # Convertir en image OpenCV
        pil_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_np = np.array(pil_image)
        frame = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)

        # OCR
        result = reader.readtext(frame, detail=0)
        detected_text = " ".join(result)

        # Si aucun texte
        if detected_text.strip() == "":
            detected_text = "No text detected"

        # Génération audio
        audio_path = speak_text(detected_text)

        return {
            "detected_text": detected_text,
            "audio_file": audio_path
        }

    except Exception as e:
        return {
            "error": str(e)
        }