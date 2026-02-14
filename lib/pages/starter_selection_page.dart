import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StarterSelectionPage extends StatelessWidget {
  const StarterSelectionPage({super.key});

  final List<Map<String, dynamic>> starters = const [
    {'id': 1, 'name': 'Bulbizarre', 'color': Colors.greenAccent, 'type': 'Plante'},
    {'id': 4, 'name': 'Salamèche', 'color': Colors.orangeAccent, 'type': 'Feu'},
    {'id': 7, 'name': 'Carapuce', 'color': Colors.lightBlueAccent, 'type': 'Eau'},
  ];

  Future<void> _confirmChoice(BuildContext context, int id, String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    // Garde-fou : ne pas attribuer de starter si l'équipe contient déjà des Pokémon
    final userSnapshot = await userDoc.get();
    final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
    final existingTeam = List<int>.from(userData['team'] ?? const []);
    if (existingTeam.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Starter non disponible : vous avez déjà des Pokémon dans l'équipe.",
            ),
          ),
        );
      }
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    batch.set(userDoc.collection('inventory').doc(id.toString()), {
      'id': id,
      'name': name,
      'level': 5,
      'capturedAt': FieldValue.serverTimestamp(),
    });

    batch.update(userDoc, {'hasChosenStarter': true});
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.yellow, Colors.orange],
                ).createShader(bounds),
                child: const Text(
                  "CHOISIS TON STARTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const Text(
                "L'aventure commence ici",
                style: TextStyle(color: Colors.white70, letterSpacing: 1.5),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: starters.length,
                  itemBuilder: (context, index) {
                    return _StarterCard(
                      starter: starters[index],
                      onSelect: () => _showDialog(context, starters[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, Map<String, dynamic> starter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: starter['color'], width: 2),
        ),
        title: Text(
          "Choisir ${starter['name']} ?",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Ce compagnon de type ${starter['type']} te suivra partout.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: starter['color'],
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmChoice(context, starter['id'], starter['name']);
            },
            child: const Text("C'EST PARTI !"),
          ),
        ],
      ),
    );
  }
}

class _StarterCard extends StatefulWidget {
  final Map<String, dynamic> starter;
  final VoidCallback onSelect;

  const _StarterCard({required this.starter, required this.onSelect});

  @override
  State<_StarterCard> createState() => _StarterCardState();
}

class _StarterCardState extends State<_StarterCard> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onSelect,
        child: AnimatedScale(
          scale: isPressed ? 0.95 : (isHovered ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 25),
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isHovered ? widget.starter['color'] : Colors.white10,
                width: isHovered ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? widget.starter['color'].withOpacity(0.5)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: isHovered ? 20 : 10,
                  spreadRadius: isHovered ? 5 : 0,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  isHovered
                      ? widget.starter['color']
                      : widget.starter['color'].withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Text(
                      widget.starter['type'].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Image.network(
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.starter['id']}.png",
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.starter['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.starter['type'],
                          style: TextStyle(
                            color: widget.starter['color'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
