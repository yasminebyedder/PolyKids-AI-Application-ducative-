from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import torch
from transformers import AutoImageProcessor, AutoModel
import os

app = FastAPI()

# ------------------------
# ✅ CORS (Flutter access)
# ------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------------
# ✅ Model loading
# ------------------------
print("Chargement modèle DINOv2...")
processor = AutoImageProcessor.from_pretrained("facebook/dinov2-base")
model = AutoModel.from_pretrained("facebook/dinov2-base")
model.eval()

# ------------------------
# ✅ Feature extraction
# ------------------------
def extract_feature(image):
    inputs = processor(images=image, return_tensors="pt")

    with torch.no_grad():
        outputs = model(**inputs)

    feat = outputs.last_hidden_state.mean(dim=1)
  #  feat = feat / feat.norm(dim=1, keepdim=True)

    return feat

# ------------------------
# 📁 Dataset path FIXED (IMPORTANT)
# ------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
dataset_path = os.path.join(BASE_DIR, "dataset")
print("Dataset path:", dataset_path)

database = {}

print("Chargement dataset...")

# 🔴 check dataset
if not os.path.exists(dataset_path):
    raise Exception(f"❌ Dataset introuvable : {dataset_path}")

# ------------------------
# 📦 Load dataset
# ------------------------
database = {}

for category in os.listdir(dataset_path):
    category_path = os.path.join(dataset_path, category)

    if not os.path.isdir(category_path):
        continue

    for label in os.listdir(category_path):
        label_path = os.path.join(category_path, label)

        if not os.path.isdir(label_path):
            continue

        print("Classe :", label)

        features_list = []

        for img_name in os.listdir(label_path):
            img_path = os.path.join(label_path, img_name)

            try:
                img = Image.open(img_path).convert("RGB")
                feat = extract_feature(img)
                features_list.append(feat)
            except Exception as e:
                print("Erreur image :", img_path, e)

        if len(features_list) > 0:
            database[label] = torch.mean(
                torch.cat(features_list),
                dim=0,
                keepdim=True
            )

print("✅ Dataset chargé :", len(database), "classes")
# ------------------------
# 🎯 API PREDICTION
# ------------------------
THRESHOLD = 0.75

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        return {"error": f"Image invalide: {str(e)}"}

    test_feat = extract_feature(image)

    best_score = -1
    best_label = "unknown"

    for label, feat in database.items():
        score = torch.nn.functional.cosine_similarity(test_feat, feat).item()

        if score > best_score:
            best_score = score
            best_label = label

    if best_score < THRESHOLD:
        return {
            "object": "unknown",
            "score": round(best_score, 2)
        }

    return {
        "object": best_label,
        "score": round(best_score, 2)
    }

