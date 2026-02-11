import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PokeDex',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Changement : On initialise avec une liste vide pour éviter les erreurs de "null"
  List pokeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final url = Uri.parse(
        "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json");

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pokeList = data['pokemon'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PokeDex"),
        backgroundColor: Colors.green,
      ),
      // Si isLoading est vrai, on montre un cercle de chargement, sinon la liste
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pokeList.length,
              itemBuilder: (context, index) {
                final pokemon = pokeList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card( // Utilisation d'une Card pour un plus beau rendu
                    color: Colors.green.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          pokemon['name'] ?? "Inconnu",
                          style: const TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white),
                        ),
                        // Correction : Flutter peut bloquer les images HTTP non sécurisées sur certaines plateformes
                        Image.network(
                          pokemon['img'].replaceFirst("http://", "https://"), // Hack pour forcer le HTTPS
                          height: 150,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.error, color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Candy: ${pokemon['candy']}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}