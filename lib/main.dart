import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List allPokemon = [];
  List filteredPokemon = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    final response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json"));
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body);
      setState(() {
        allPokemon = decodedJson['pokemon'];
        filteredPokemon = allPokemon;
        isLoading = false;
      });
    }
  }

  void _filterPokemon(String query) {
    setState(() {
      filteredPokemon = allPokemon
          .where((poke) =>
              poke['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- FONCTION POUR AFFICHER LA POP-UP ---
  void _showDetails(BuildContext context, dynamic poke) {
    String imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${poke['id']}.png";
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min, // S'adapte au contenu
            children: [
              Image.network(imgUrl, height: 150),
              Text(
                poke['name'],
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Text("Type: ${poke['type'].join(', ')}"),
              Text("Taille: ${poke['height']}"),
              Text("Poids: ${poke['weight']}"),
              const SizedBox(height: 10),
              const Text("Faiblesses:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(poke['weaknesses'].join(', ')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PokeDex"),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => _filterPokemon(value),
              decoration: InputDecoration(
                labelText: 'Rechercher un Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredPokemon.length,
                    itemBuilder: (context, index) {
                      return PokeCard(
                        poke: filteredPokemon[index],
                        onTap: () => _showDetails(context, filteredPokemon[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- NOUVEAU WIDGET POUR LA CARTE ANIMÉE ---
class PokeCard extends StatefulWidget {
  final dynamic poke;
  final VoidCallback onTap;

  const PokeCard({super.key, required this.poke, required this.onTap});

  @override
  State<PokeCard> createState() => _PokeCardState();
}

class _PokeCardState extends State<PokeCard> {
  bool isHovered = false; // État pour savoir si la souris est dessus

  @override
  Widget build(BuildContext context) {
    String imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.poke['id']}.png";

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: isHovered 
              ? (Matrix4.identity()..scale(1.05)) // Zoom de 5%
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: isHovered 
                ? [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)]
                : [],
          ),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: isHovered ? 0 : 2, // L'ombre est gérée par le container si survol
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(imgUrl, fit: BoxFit.contain),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.poke['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}