import 'home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  void signIn() {
    // String email = emailController.text.trim();
    // String password = passwordController.text;
      String email = "email@tester.be";
      String password = "wachtwoord";

    if (email.isEmpty || password.isEmpty) {
      showError('Vul zowel je e-mailadres als wachtwoord in.');
    } else if (!emailRegex.hasMatch(email)) {
      showError('Voer een geldig e-mailadres in.');
    } else {
      // Alles is in orde, navigeer naar HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fout'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inloggen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Wachtwoord'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              child: const Text('Inloggen'),
            ),
          ],
        ),
      ),
    );
  }
}
