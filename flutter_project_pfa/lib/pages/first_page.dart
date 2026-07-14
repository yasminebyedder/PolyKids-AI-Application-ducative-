import 'package:flutter/material.dart';
import '../widgets/inky.dart';
import 'second_page.dart';
import 'third_page.dart';
import 'fourth_page.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 165, 223),
      appBar: AppBar(
        title: const Text("Polykids IA"),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 199, 165, 223),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1er enfant : container Inky
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: InkyMascot(mood: InkyMood.bonjour, size: 240),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3 boutons
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  // Camera → SecondPage
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecondPage(),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: Color.fromARGB(255, 199, 165, 223),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Livre → ThirdPage
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThirdPage(),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 36,
                            color: Color.fromARGB(255, 199, 165, 223),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Doigt → FourthPage
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FourthPage(),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.translate,
                            size: 36,
                            color: Color.fromARGB(255, 199, 165, 223),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
