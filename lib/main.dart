import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const PokeApp());
}

class PokeApp extends StatelessWidget {
  const PokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeDex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        useMaterial3: true, // Pour un look plus moderne
      ),
      home: const HomePage(),
    );
  }
}