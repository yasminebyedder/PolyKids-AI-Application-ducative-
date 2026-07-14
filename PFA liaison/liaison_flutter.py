from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io, torch
from transformers import AutoImageProcessor, AutoModelForImageClassification
from deep_translator import GoogleTranslator

app = FastAPI()

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# Charge ton modèle DINOv2 fine-tuné une seule fois au démarrage
processor = AutoImageProcessor.from_pretrained("./mon_modele_dinov2")
model = AutoModelForImageClassification.from_pretrained("./mon_modele_dinov2")
model.eval()

@app.post("/detect")
async def detect_object(file: UploadFile = File(...)):
    img_bytes = await file.read()
    image = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    
    # Inférence DINOv2
    inputs = processor(images=image, return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
    predicted_id = outputs.logits.argmax(-1).item()
    label_en = model.config.id2label[predicted_id]
    confidence = torch.softmax(outputs.logits, dim=-1).max().item()
    
    # Traduction
    label_fr = GoogleTranslator(source='en', target='fr').translate(label_en)
    label_ar = GoogleTranslator(source='en', target='ar').translate(label_en)
    
    return {
        "label_en": label_en,
        "label_fr": label_fr,
        "label_ar": label_ar,
        "confidence": round(confidence, 3)
    }