import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/database_service.dart';
import '../widgets/poke_card.dart';

class TeamPage extends StatelessWidget {
  final List<Pokemon> allPokemon;

  const TeamPage({super.key, required this.allPokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VOTRE ÉQUIPE D'ÉLITE"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.redAccent.withOpacity(0.1), Colors.white],
          ),
        ),
        child: StreamBuilder<List<int>>(
          // On écoute à la fois les favoris et l'équipe pour que PokeCard ait tout
          stream: DatabaseService().teamStream,
          builder: (context, teamSnapshot) {
            return StreamBuilder<List<int>>(
              stream: DatabaseService().favoritesStream,
              builder: (context, favSnapshot) {
                List<int> teamIds = teamSnapshot.data ?? [];
                List<int> favIds = favSnapshot.data ?? [];
                
                List<Pokemon> teamMembers = allPokemon.where((p) => teamIds.contains(p.id)).toList();

                if (teamMembers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.catching_pokemon, size: 80, color: Colors.grey),
                        Text("Aucun membre dans l'équipe...", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // Analyse stratégique
                Map<String, int> typeCounts = {};
                for (var p in teamMembers) {
                  for (var t in p.type) {
                    typeCounts[t] = (typeCounts[t] ?? 0) + 1;
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.analytics, color: Colors.redAccent),
                                  SizedBox(width: 10),
                                  Text("ANALYSE DU PROFESSEUR", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(),
                              Text("Votre équipe est composée de ${teamMembers.length}/6 Pokémon."),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 8,
                                children: typeCounts.keys.map((t) => Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.cyan.withOpacity(0.2),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: teamMembers.length,
                        itemBuilder: (context, index) {
                          final pokemon = teamMembers[index];
                          // --- CORRECTION ICI ---
                          return PokeCard(
                            pokemon: pokemon,
                            isFavorite: favIds.contains(pokemon.id),
                            isInTeam: true, // Forcément vrai puisqu'on est sur TeamPage
                            onTap: () {}, 
                            onFavoriteTap: () => DatabaseService().toggleFavorite(pokemon.id),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }
}