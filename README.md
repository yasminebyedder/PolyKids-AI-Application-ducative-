# 🐙 PolyKids AI

**Application mobile éducative intelligente pour enfants de 3 à 10 ans**

Une application qui transforme l'environnement réel de l'enfant en contenu éducatif interactif, grâce à la reconnaissance d'objets par IA, l'extraction de texte (OCR) et la traduction automatique avec synthèse vocale.

## 📖 À propos du projet

Ce projet est un **rapport de fin d'année (PFA1)** réalisé à l'**École Nationale des Sciences et Technologies Avancées à Borj Cédria (ENSTAB)**, Université de Carthage.

Les méthodes d'apprentissage traditionnelles montrent parfois leurs limites en matière d'interaction avec l'environnement réel. PolyKids AI propose une approche différente : l'enfant utilise simplement la caméra de son smartphone pour explorer le monde qui l'entoure — un objet, un mot, une affiche — et l'application transforme cette observation en expérience d'apprentissage vivante.

### 👩‍💻 Réalisé par
- **Ben Yedder Yasmine**(moi)
- **Abbes Nour**

**Année universitaire :** 2025-2026

---

## ✨ Fonctionnalités principales

L'application repose sur trois modules indépendants, accessibles via une mascotte interactive nommée **Inky** :

### 🎥 1. Reconnaissance d'objets
L'enfant photographie un objet de son quotidien via la caméra. Le système l'identifie, affiche son nom **en anglais** et le prononce à voix haute — une manière ludique d'introduire une langue étrangère dès le plus jeune âge.

### 📖 2. Lecture de texte (OCR)
L'enfant capture une image contenant du texte (livre, panneau, étiquette...). L'application extrait automatiquement le texte et le lit à voix haute.

### 🌍 3. Traduction multilingue
Le texte extrait peut être traduit automatiquement en **français**, **anglais** et **arabe**, puis lu dans la langue choisie — favorisant l'acquisition de vocabulaire multilingue.

---

## 🛠️ Technologies utilisées

| Catégorie | Technologie | Rôle |
|---|---|---|
| **Frontend mobile** | Flutter / Dart | Interface utilisateur multiplateforme (Android/iOS) |
| **Backend / API** | FastAPI (Python) | Traitement des requêtes et orchestration des modules IA |
| **Vision par ordinateur** | DINOv2 (Meta AI) | Reconnaissance et classification d'objets |
| **OCR** | Tesseract OCR / EasyOCR | Extraction de texte à partir d'images |
| **Traduction** | Deep Translator / Google Translate | Traduction automatique FR / EN / AR |
| **Synthèse vocale** | Edge TTS | Lecture vocale des résultats |

### Architecture globale

```
Caméra du smartphone (Flutter)
          │
          ▼
   Requête HTTP → API Backend (FastAPI)
          │
          ▼
 ┌────────────────────────────┐
 │  Modules IA                │
 │  • Reconnaissance d'objet  │  → DINOv2
 │  • OCR                     │  → Tesseract / EasyOCR
 │  • Traduction              │  → Deep Translator
 │  • Synthèse vocale         │  → Edge TTS
 └────────────────────────────┘
          │
          ▼
Réponse JSON → Affichage + lecture vocale
```

L'architecture **client-serveur** sépare clairement l'interface utilisateur (Flutter) des traitements intelligents (FastAPI + modules IA), garantissant modularité et facilité de maintenance.

---

## 📂 Structure du dépôt

```
├── flutter_project_pfa/    # Application mobile Flutter (frontend)
├── PFA IA/                 # Modèle de reconnaissance d'objets (DINOv2) + dataset
├── PFA liaison/             # Script de liaison entre le backend et Flutter
├── lecture/                 # Module de lecture vocale (TTS multilingue)
└── traduction/               # Module de traduction automatique + audios générés
```

---

## 🧠 Choix méthodologiques (résumé)

- **DINOv2** a été préféré à YOLO en raison du manque de datasets annotés disponibles pour certaines classes d'objets, et à TensorFlow jugé trop lourd pour le prototype.
- **EasyOCR/Tesseract** ont été retenus après comparaison, offrant un bon compromis robustesse/simplicité d'intégration face aux conditions réelles (éclairage, angles variés).
- **Deep Translator** a été choisi pour sa simplicité d'intégration face à LibreTranslate (moins fiable) et l'API Google Translate (coûts après un certain seuil).
- **Edge TTS** a été privilégié à Google Cloud TTS pour éviter les coûts liés au volume de caractères traités.
- Un **dataset personnalisé** a été constitué (objets du quotidien classés par catégories : animaux, vêtements, électronique, mobilier, fruits, jouets, ustensiles de cuisine, etc.), DINOv2 étant capable de fonctionner efficacement avec un volume de données limité.

---

## ✅ Résultats

Les tests menés ont montré que l'application :
- reconnaît correctement la majorité des objets du quotidien testés dans de bonnes conditions d'éclairage ;
- extrait fidèlement les textes imprimés courts et bien visibles ;
- produit des traductions compréhensibles en français, anglais et arabe pour des mots et phrases simples ;
- lit les résultats à voix haute de façon claire et naturelle dans les trois langues.

### Limites identifiées
- Sensibilité de l'OCR à la qualité de l'image (flou, éclairage, inclinaison du texte)
- Difficultés de détection pour les objets complexes ou partiellement visibles
- Dépendance à la qualité de connexion réseau entre l'application et l'API
- Nécessité d'un accompagnement parental pour les plus jeunes utilisateurs

### Pistes d'amélioration futures
- Amélioration de la précision des modèles d'IA
- Ajout de nouvelles langues
- Optimisation des performances
- Fonctionnement hors ligne
- Ajout d'activités éducatives interactives supplémentaires

---

## 🎯 Public cible

Application conçue pour les enfants de **3 à 10 ans** :
- **3-5 ans** : phase d'exploration de l'environnement et des objets
- **6-10 ans** : phase d'apprentissage de la lecture et de la prononciation

*Un encadrement parental ou éducatif est recommandé, notamment pour les enfants de moins de 6 ans.*

---

## 📄 Licence

Projet académique réalisé dans le cadre du cursus d'ingénierie à l'ENSTAB, Université de Carthage.
