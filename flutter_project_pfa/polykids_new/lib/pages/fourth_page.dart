import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/inky_translate.dart';

class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  final ImagePicker picker = ImagePicker();
  final FlutterTts tts = FlutterTts();

  bool loading = false;
  String status = "👆 Appuie sur Inky pour commencer";
  String originalText = "";

  List<Map<String, String>> results = [];

  final Uri url = Uri.parse("http://127.0.0.1:8002/ocr");

  // -------------------------
  // 🔊 lecture vocale avec langue
  // -------------------------
  Future<void> speak(String text, String langCode) async {
    if (text.trim().isEmpty) return;

    await tts.stop();
    await Future.delayed(const Duration(milliseconds: 200));

    await tts.setLanguage(langCode);
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true);

    await tts.speak(text);
  }

  // -------------------------
  // 📸 ouvrir caméra
  // -------------------------
  Future<void> openCameraAndSend() async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (photo == null) return;

    await sendToBackend(File(photo.path));
  }

  // -------------------------
  // 📤 envoyer image au backend
  // -------------------------
  Future<void> sendToBackend(File file) async {
    setState(() {
      loading = true;
      status = "🔍 Analyse en cours...";
      results = [];
      originalText = "";
    });

    try {
      var request = http.MultipartRequest("POST", url);
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      var response = await request.send();
      var responseText = await response.stream.bytesToString();

      print("RAW RESPONSE: $responseText");

      var data = jsonDecode(responseText);

      if (data["error"] != null) {
        setState(() {
          loading = false;
          status = "❌ ${data["error"]}";
        });
        return;
      }

      List translations = data["translations"] ?? [];

      if (translations.isEmpty) {
        setState(() {
          loading = false;
          status = "❌ Aucun texte détecté";
        });
        return;
      }

      List<Map<String, String>> output = [];
      for (var t in translations) {
        output.add({
          "text": t["text"] ?? "",
          "lang_code": t["lang_code"] ?? "fr-FR",
          "lang_name": t["lang_name"] ?? "",
        });
      }

      setState(() {
        originalText = data["detected_lang_name"] ?? "Langue inconnue";
        results = output;
        loading = false;
        status = "✨ Résultat prêt — lecture en cours...";
      });

      // 🔊 lire TOUTES les traductions une par une
      for (var t in output) {
        await speak(t["text"]!, t["lang_code"]!);
        await Future.delayed(const Duration(milliseconds: 600));
      }

      setState(() {
        status = "✅ Lecture terminée";
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        loading = false;
        status = "❌ Erreur connexion API";
      });
    }
  }

  // -------------------------
  // 📌 popup confirmation
  // -------------------------
  void showTranslateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Inky 🌍"),
          content: const Text("Veux-tu traduire le texte ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Plus tard"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openCameraAndSend();
              },
              child: const Text("Oui"),
            ),
          ],
        );
      },
    );
  }

  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 165, 223),
      appBar: AppBar(title: const Text("Polykids IA")),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🐙 INKY — centré comme SecondPage
                GestureDetector(
                  onTap: showTranslateDialog,
                  child: Container(
                    height: 300,
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 220, 192, 240),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const InkyLanguages(size: 280),
                  ),
                ),

                const SizedBox(height: 20),

                // 📌 STATUS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ⏳ loading
                if (loading) const CircularProgressIndicator(),

                // 🌍 langue détectée
                if (originalText.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Text(
                    "📝 Langue détectée : $originalText",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                // 🌐 traductions
                if (results.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: results.map((t) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // texte + nom langue
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t["lang_name"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t["text"] ?? "",
                                        style: const TextStyle(fontSize: 18),
                                        textAlign: t["lang_code"] == "ar-SA"
                                            ? TextAlign.right
                                            : TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔊 bouton relire
                                IconButton(
                                  icon: const Icon(
                                    Icons.volume_up,
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed: () =>
                                      speak(t["text"]!, t["lang_code"]!),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
