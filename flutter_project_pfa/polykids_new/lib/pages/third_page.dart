import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/inky_reading.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  File? image;
  final picker = ImagePicker();
  final FlutterTts tts = FlutterTts();

  String text = "";
  String lang = "";
  bool loading = false;

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  // 📌 Popup confirmation caméra
  Future<void> showCameraDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scanner un texte"),
        content: const Text("Voulez-vous ouvrir la caméra ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openCamera();
            },
            child: const Text("Oui"),
          ),
        ],
      ),
    );
  }

  // 📸 Ouvrir caméra
  Future<void> openCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => image = File(picked.path));
      await sendToBackend(File(picked.path));
    }
  }

  // 📤 Envoi vers FastAPI
  Future<void> sendToBackend(File img) async {
    setState(() => loading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://localhost:8003/ocr"),
      );
      request.files.add(await http.MultipartFile.fromPath("file", img.path));

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      final receivedText = data["text"] ?? "Aucun texte détecté";
      final receivedLang = data["lang"] ?? "fr-FR";

      setState(() {
        text = receivedText;
        lang = receivedLang;
        loading = false;
      });

      // 🔊 Lecture avec la langue détectée par le backend
      await speak(receivedText, receivedLang);
    } catch (e) {
      setState(() {
        text = "Erreur de connexion API";
        lang = "";
        loading = false;
      });
    }
  }

  // 🔊 TTS avec langue reçue du backend
  Future<void> speak(String t, String l) async {
    await tts.setLanguage(l);
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.speak(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 165, 223),
      appBar: AppBar(
        title: const Text("Polykids IA"),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.menu),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 192, 240),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: showCameraDialog,
                child: const InkyReading(size: 280),
              ),
            ),

            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),

            if (lang.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Langue détectée : $lang",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),

            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
