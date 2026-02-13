import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class PokedexPage extends StatelessWidget {
  final List<Pokemon> allPokemon;

  const PokedexPage({super.key, required this.allPokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Encyclopédie Pokémon"),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.separated(
        itemCount: allPokemon.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = allPokemon[index];
          return ListTile(
            leading: Image.network(
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${p.id}.png",
              width: 50,
            ),
            title: Text("#${p.id.toString().padLeft(3, '0')} ${p.name}"),
            subtitle: Text("Types: ${p.type.join(' / ')}"),
            trailing: const Icon(Icons.info_outline, color: Colors.grey),
            onTap: () => _showQuickStats(context, p),
          );
        },
      ),
    );
  }

  void _showQuickStats(BuildContext context, Pokemon p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Ici tu peux ajouter les stats si elles sont dans ton modèle (HP, Attack, etc.)
            Text("Taille: ${p.height} | Poids: ${p.weight}"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}