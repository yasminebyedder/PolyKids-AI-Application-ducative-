import cv2
import easyocr
import asyncio
import edge_tts
import os
import time

# OCR (Arabic + English for stability)
reader = easyocr.Reader(['en', 'ar'], gpu=False)

# 🔄 fix Arabic word order
def fix_arabic(text):
    words = text.split()
    return " ".join(words[::-1])

# 🔊 Arabic voice (Edge TTS)
def speak_arabic(text):
    async def run():
        voice = "ar-SA-HamedNeural"
        communicate = edge_tts.Communicate(text, voice)
        await communicate.save("voice.mp3")
        os.system("start voice.mp3")

    asyncio.run(run())


cap = cv2.VideoCapture(0)

print("📷 Arabic OCR - Press S to scan, Q to quit")

while True:
    ret, frame = cap.read()
    cv2.imshow("Arabic OCR", frame)

    key = cv2.waitKey(1)

    if key == ord('s'):
        result = reader.readtext(frame, detail=0)
        text = " ".join(result)

        print("RAW:", text)

        if text.strip() == "":
            speak_arabic("لم يتم اكتشاف نص")
        else:
            text = fix_arabic(text)   # 🔥 FIX ORDER
            print("FIXED:", text)
            speak_arabic(text)

        time.sleep(0.5)

    if key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()