import cv2
import easyocr
import asyncio
import edge_tts
import os
import time

# OCR
reader = easyocr.Reader(['fr', 'en'], gpu=False)

# 🔊 French voice (Edge TTS)
def speak_french(text):
    async def run():
        voice = "fr-FR-DeniseNeural"
        communicate = edge_tts.Communicate(text, voice)
        await communicate.save("voice.mp3")
        os.system("start voice.mp3")

    asyncio.run(run())


cap = cv2.VideoCapture(0)

print("📷 French OCR - Press S to scan, Q to quit")

while True:
    ret, frame = cap.read()
    cv2.imshow("French OCR", frame)

    key = cv2.waitKey(1)

    if key == ord('s'):
        result = reader.readtext(frame, detail=0)
        text = " ".join(result)

        print("📄", text)

        if text.strip() == "":
            speak_french("Aucun texte détecté")
        else:
            speak_french(text)

        time.sleep(0.5)

    if key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
