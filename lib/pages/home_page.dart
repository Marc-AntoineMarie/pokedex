import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon.dart';
import '../widgets/poke_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pokemon> allPokemon = [];
  List<Pokemon> filteredPokemon = [];
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
        // On transforme chaque élément du JSON en objet Pokemon
        allPokemon = (decodedJson['pokemon'] as List)
            .map((p) => Pokemon.fromJson(p))
            .toList();
        filteredPokemon = allPokemon;
        isLoading = false;
      });
    }
  }

  void _filterPokemon(String query) {
    setState(() {
      filteredPokemon = allPokemon
          .where((poke) =>
              poke.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showDetails(BuildContext context, Pokemon poke) {
    String imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${poke.id}.png";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imgUrl, height: 150),
            Text(poke.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const Divider(),
            Text("Type: ${poke.type.join(', ')}"),
            Text("Taille: ${poke.height}"),
            Text("Poids: ${poke.weight}"),
            const SizedBox(height: 10),
            const Text("Faiblesses:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(poke.weaknesses.join(', ')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PokeDex"), backgroundColor: Colors.cyan),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterPokemon,
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
                    itemBuilder: (context, index) => PokeCard(
                      pokemon: filteredPokemon[index],
                      onTap: () => _showDetails(context, filteredPokemon[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}