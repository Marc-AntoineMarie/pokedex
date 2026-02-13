import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StarterSelectionPage extends StatelessWidget {
  const StarterSelectionPage({super.key});

  // Liste des starters avec leurs IDs PokeAPI
  final List<Map<String, dynamic>> starters = const [
    {'id': 1, 'name': 'Bulbizarre', 'color': Colors.green, 'type': 'Plante'},
    {'id': 4, 'name': 'Salamèche', 'color': Colors.orange, 'type': 'Feu'},
    {'id': 7, 'name': 'Carapuce', 'color': Colors.blue, 'type': 'Eau'},
  ];

  Future<void> _confirmChoice(BuildContext context, int id, String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // 1. Ajouter au nouvel inventaire
    batch.set(userDoc.collection('inventory').doc(id.toString()), {
      'id': id,
      'name': name,
      'level': 5,
      'capturedAt': FieldValue.serverTimestamp(),
    });

    // 2. Valider le starter pour ne plus revenir sur cette page
    batch.update(userDoc, {'hasChosenStarter': true});

    await batch.commit();
    // Le StreamBuilder dans main.dart détectera le changement et changera de page tout seul !
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "CHOISIS TON COMPAGNON",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: starters.length,
                itemBuilder: (context, index) {
                  final s = starters[index];
                  return _buildStarterCard(context, s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarterCard(BuildContext context, Map<String, dynamic> starter) {
    return GestureDetector(
      onTap: () => _showDialog(context, starter),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [starter['color'].withOpacity(0.8), starter['color'].withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Image.network(
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${starter['id']}.png",
                height: 140,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    starter['name'],
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      starter['type'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, Map<String, dynamic> starter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Choisir ${starter['name']} ?"),
        content: const Text("Ce Pokémon sera ton premier partenaire pour toute l'aventure."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULER")),
          ElevatedButton(
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