import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class PokeCard extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;
  final bool isFavorite; // Savoir si on affiche le coeur plein ou vide
  final VoidCallback onFavoriteTap; // Action quand on clique sur le coeur

  const PokeCard({
    super.key, 
    required this.pokemon, 
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  State<PokeCard> createState() => _PokeCardState();
}

class _PokeCardState extends State<PokeCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    String imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.pokemon.id}.png";

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
          child: Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: isHovered ? 8 : 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(imgUrl, fit: BoxFit.contain),
                      ),
                    ),
                    Text(
                      widget.pokemon.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: Icon(
                    // Utilisation de la condition pour l'icône
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: widget.onFavoriteTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}