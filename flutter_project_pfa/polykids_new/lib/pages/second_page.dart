import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/inky_pointing.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final ImagePicker picker = ImagePicker();

  // 🔊 TTS
  final FlutterTts tts = FlutterTts();

  String detectedObject = "";
  String score = "";
  String inkyMessage = "Je suis prêt à t'aider 😊";

  bool isLoading = false;

  // ⚠️ Mets TON IP ici
  final String apiUrl = "http://127.0.0.1:8001/predict";
  // -----------------------------
  // 🔊 SPEAK
  // -----------------------------
  Future<void> speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    await tts.speak(text);
  }

  // -----------------------------
  // 📡 ENVOI IMAGE FASTAPI
  // -----------------------------
  Future<void> sendImageToAPI(File imageFile) async {
    try {
      setState(() {
        isLoading = true;
        inkyMessage = "🔍 Je regarde l'image...";
      });

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send().timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();

        var data = jsonDecode(responseData);

        setState(() {
          detectedObject = data['object'] ?? "unknown";

          score = data['score']?.toString() ?? "0";

          inkyMessage = "J'ai trouvé : $detectedObject 🧸 (confiance: $score)";

          isLoading = false;
        });

        // 🔊 Lire le résultat
        if (detectedObject.isNotEmpty && detectedObject != "unknown") {
          await speak(detectedObject);
        }
      } else {
        setState(() {
          inkyMessage = "❌ Erreur serveur (${response.statusCode})";

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        inkyMessage = "❌ Erreur connexion API";
        isLoading = false;
      });

      print("Erreur: $e");
    }
  }

  // -----------------------------
  // 📷 CAMERA
  // -----------------------------
  Future<void> captureImage() async {
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        File imageFile = File(photo.path);

        await sendImageToAPI(imageFile);
      }
    } catch (e) {
      setState(() {
        inkyMessage = "❌ Problème caméra";
      });
    }
  }

  // -----------------------------
  // 💬 DIALOG
  // -----------------------------
  void _showCameraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Inky 📸"),

          content: const Text("Veux-tu que je regarde autour de moi ?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Plus tard"),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await captureImage();
              },
              child: const Text("Oui !"),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------
  // 🎨 UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 165, 223),

      appBar: AppBar(title: const Text("Polykids IA")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // 🧸 Mascotte
            Container(
              height: 300,
              width: 300,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 192, 240),

                borderRadius: BorderRadius.circular(20),
              ),

              child: GestureDetector(
                onTap: () => _showCameraDialog(context),

                child: const InkyPointing(size: 280),
              ),
            ),

            const SizedBox(height: 20),

            // 💬 MESSAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Text(
                inkyMessage,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔄 LOADING
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
