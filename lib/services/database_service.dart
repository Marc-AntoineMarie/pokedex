import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  // Ajouter ou supprimer un favori
  Future toggleFavorite(int pokemonId) async {
    DocumentReference userDoc = usersCollection.doc(uid);
    
    // On récupère le document de l'utilisateur
    DocumentSnapshot doc = await userDoc.get();
    List favorites = [];
    
    if (doc.exists) {
      favorites = (doc.data() as Map)['favorites'] ?? [];
    }

    if (favorites.contains(pokemonId)) {
      favorites.remove(pokemonId); // On l'enlève s'il y est déjà
    } else {
      favorites.add(pokemonId); // On l'ajoute sinon
    }

    return await userDoc.set({'favorites': favorites}, SetOptions(merge: true));
  }

  // Stream pour écouter les favoris en temps réel
  Stream<List<int>> get favoritesStream {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return List<int>.from((snapshot.data() as Map)['favorites'] ?? []);
      }
      return [];
    });
  }

  // Ajouter ou retirer de l'équipe (Max 6)
  Future<String?> toggleTeam(int pokemonId) async {
    DocumentReference userDoc = usersCollection.doc(uid);
    DocumentSnapshot doc = await userDoc.get();
    
    List<int> team = [];
    if (doc.exists && (doc.data() as Map).containsKey('team')) {
      team = List<int>.from((doc.data() as Map)['team']);
    }

    if (team.contains(pokemonId)) {
      team.remove(pokemonId); // On le retire s'il y est déjà
    } else {
      if (team.length >= 6) {
        return "Équipe complète ! (6 max)";
      }
      // Pas besoin de vérifier le doublon ici car le "if (team.contains)" s'en occupe
      team.add(pokemonId);
    }

    await userDoc.update({'team': team}); // Update est plus sûr que Set ici
    return null;
  }

  // Stream pour l'équipe
  Stream<List<int>> get teamStream {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return List<int>.from((snapshot.data() as Map)['team'] ?? []);
      }
      return [];
    });
  }
}