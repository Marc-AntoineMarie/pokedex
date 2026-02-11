import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> _authenticate() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Erreur")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec une PokeBall (Design simple)
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
              ),
              child: const Icon(Icons.catching_pokemon, size: 100, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Text(
                    isLogin ? "BIENVENUE DRESSEUR" : "NOUVELLE AVENTURE",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin ? "Connectez-vous pour voir votre PokeDex" : "Créez votre compte de dresseur",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  // Champ Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Champ Mot de passe
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Mot de passe",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bouton Principal
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLogin ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _authenticate,
                      child: Text(
                        isLogin ? "SE CONNECTER" : "CRÉER MON COMPTE",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Switch Login/Register
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(text: isLogin ? "Nouveau ici ? " : "Déjà dresseur ? "),
                          TextSpan(
                            text: isLogin ? "Inscrivez-vous" : "Connectez-vous",
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
}