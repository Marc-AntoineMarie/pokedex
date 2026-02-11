import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pokemon.dart';
import '../widgets/poke_card.dart';
import '../services/database_service.dart';
import 'team_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    
    // Étape A : On essaie de lire le cache
    final String? cachedData = prefs.getString('pokedex_cache');
    if (cachedData != null) {
      var decodedJson = jsonDecode(cachedData);
      _updateUI(decodedJson);
      print("Chargé depuis le cache local 💾");
    }

    // Étape B : On lance l'appel réseau en arrière-plan
    try {
      final response = await http.get(Uri.parse(
          "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json"));
      
      if (response.statusCode == 200) {
        // On met à jour le cache avec les nouvelles données
        await prefs.setString('pokedex_cache', response.body);
        
        var decodedJson = jsonDecode(response.body);
        _updateUI(decodedJson);
        print("Chargé depuis le réseau et cache mis à jour 🌐");
      }
    } catch (e) {
      print("Erreur réseau (normal si hors-ligne) : $e");
      // Si on n'a ni cache ni réseau, on arrête le chargement
      if (cachedData == null) {
        setState(() => isLoading = false);
      }
    }
  }

  // Petite fonction helper pour éviter la répétition
  void _updateUI(dynamic json) {
    setState(() {
      allPokemon = (json['pokemon'] as List)
          .map((p) => Pokemon.fromJson(p))
          .toList();
      filteredPokemon = allPokemon;
      isLoading = false;
    });
  }

  void _filterPokemon(String query) {
    setState(() {
      filteredPokemon = allPokemon
          .where((poke) =>
              poke.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showDetails(BuildContext context, Pokemon poke, bool alreadyInTeam) {
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
            const SizedBox(height: 20),
            
            // BOUTON RECRUTER / RETIRER
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: alreadyInTeam ? Colors.blueGrey : Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                String? error = await DatabaseService().toggleTeam(poke.id);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.orange),
                  );
                } else if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: Icon(alreadyInTeam ? Icons.remove_circle : Icons.add_moderator),
              label: Text(alreadyInTeam ? "Retirer de l'équipe" : "Recruter dans l'équipe"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PokeDex Pro"),
        backgroundColor: Colors.cyan,
        actions: [
          // 1. Bouton Équipe
          IconButton(
            icon: const Icon(Icons.groups, size: 28),
            tooltip: "Mon Équipe",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamPage(allPokemon: allPokemon)),
              );
            },
          ),
          
          // 2. Menu Profil et Déconnexion (Celui qui avait disparu)
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 30),
            onSelected: (value) {
              if (value == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  FirebaseAuth.instance.currentUser?.email ?? "Dresseur",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Déconnexion"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ... (Ton TextField reste identique)
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
                : StreamBuilder<List<int>>(
                    stream: DatabaseService().favoritesStream,
                    builder: (context, favSnapshot) {
                      return StreamBuilder<List<int>>(
                        stream: DatabaseService().teamStream, // <--- 2ème Stream pour l'équipe
                        builder: (context, teamSnapshot) {
                          List<int> favIds = favSnapshot.data ?? [];
                          List<int> teamIds = teamSnapshot.data ?? [];

                          List<Pokemon> displayList = List.from(filteredPokemon);
                          displayList.sort((a, b) {
                            bool aIsFav = favIds.contains(a.id);
                            bool bIsFav = favIds.contains(b.id);
                            if (aIsFav && !bIsFav) return -1;
                            if (!aIsFav && bIsFav) return 1;
                            return 0;
                          });

                          return GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final pokemon = displayList[index];
                              return PokeCard(
                                pokemon: pokemon,
                                isFavorite: favIds.contains(pokemon.id),
                                isInTeam: teamIds.contains(pokemon.id), // <--- Info passée au widget
                                onTap: () => _showDetails(context, pokemon, teamIds.contains(pokemon.id)),
                                onFavoriteTap: () => DatabaseService().toggleFavorite(pokemon.id),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}