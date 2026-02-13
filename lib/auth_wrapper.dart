import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'starter_selection_page.dart'; // Ta nouvelle page
import 'pokedex_page.dart'; // Ta page actuelle

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Écoute l'état de la connexion (Connecté ou pas ?)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 1. Si pas connecté -> Login
        if (!authSnapshot.hasData) {
          return const LoginPage();
        }

        // 2. Si connecté -> On va voir son flag dans Firestore
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(authSnapshot.data!.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Récupération du flag
            final data = userSnapshot.data!.data() as Map<String, dynamic>?;
            final bool hasChosen = data?['hasChosenStarter'] ?? false;

            // 3. Choix de la page selon le flag
            if (!hasChosen) {
              return const StarterSelectionPage();
            }

            return const HomePage();
          },
        );
      },
    );
  }
}