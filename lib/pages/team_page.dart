import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/database_service.dart';
import '../widgets/poke_card.dart';

class TeamPage extends StatelessWidget {
  final List<Pokemon> allPokemon; // On passe la liste complète pour retrouver les objets par ID

  const TeamPage({super.key, required this.allPokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Équipe de Combat"), backgroundColor: Colors.redAccent),
      body: StreamBuilder<List<int>>(
        stream: DatabaseService().teamStream,
        builder: (context, snapshot) {
          List<int> teamIds = snapshot.data ?? [];
          List<Pokemon> teamMembers = allPokemon.where((p) => teamIds.contains(p.id)).toList();

          if (teamMembers.isEmpty) {
            return const Center(child: Text("Ton équipe est vide. Ajoute des Pokémon !"));
          }

          // Analyse simplifiée des types
          Set<String> teamTypes = {};
          for (var p in teamMembers) { teamTypes.addAll(p.type); }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.blueGrey[50],
                  child: ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.blue),
                    title: const Text("Analyse de couverture"),
                    subtitle: Text("Types couverts : ${teamTypes.join(', ')}"),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: teamMembers.length,
                  itemBuilder: (context, index) {
                    final pokemon = teamMembers[index];
                    return PokeCard(
                      pokemon: pokemon,
                      isFavorite: true, // On peut simplifier ici
                      onTap: () {}, 
                      onFavoriteTap: () => DatabaseService().toggleTeam(pokemon.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}