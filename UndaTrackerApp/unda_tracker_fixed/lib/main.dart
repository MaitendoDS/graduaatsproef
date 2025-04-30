import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Zorg ervoor dat Flutter bindings zijn geinitialiseerd
  await Firebase.initializeApp();  // Firebase initialiseren
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unda Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF81C784),
          primary: const Color(0xFF81C784),
          secondary: const Color(0xFF388E3C),
          surface: const Color(0xFFF1F8E9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8E9),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
