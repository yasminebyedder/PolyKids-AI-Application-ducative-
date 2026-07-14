import 'package:flutter/material.dart';
import '../widgets/inky_translate.dart';

class FourthPage extends StatelessWidget {
  const FourthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 165, 223),
      appBar: AppBar(
        title: const Text("Polykids IA"),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Retourne à la page précédente (FirstPage)
          },
          icon: const Icon(Icons.menu),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 220, 192, 240),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: const InkyLanguages(size: 280),
        ),
      ),
    );
  }
}
