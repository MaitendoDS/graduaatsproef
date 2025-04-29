import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// De hoofdwidget
/// de eerste pagina (welkom) startscherm
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unda Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF81C784), // zachte groentint
          primary: Color(0xFF81C784),
          secondary: Color(0xFF388E3C), // donkerder groen
          surface: Color(0xFFF1F8E9), // lichtgroene achtergrond
        ),
        scaffoldBackgroundColor: Color(0xFFF1F8E9),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

/// Welkomscherm met een knop die je naar het login/register scherm brengt
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logov1.webp',
              height: 120,
            ),

            const SizedBox(height: 24),

            // Titel
            Text(
              'Welkom bij Unda Tracker',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Beschrijving
            Text(
              'Met Unda Health Tracker kun je je gezondheid bijhouden en patronen ontdekken.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Beschrijving
            Text(
              'Log in of registreer om verder te gaan.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            // Login knop
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Inloggen'),
              ),
            ),

            const SizedBox(height: 12),

            // Registratie knop
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Registratiescherm maken
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                child: const Text('Registreren'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Inlogscherm met een knop die je naar het hoofdscherm brengt.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inloggen')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Inloggen'),
          onPressed: () {
            // Navigeer naar het hoofdscherm en verwijder de vorige schermen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
    );
  }
}

/// Hoofdscherm met een bottom navigation bar (footerbar)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('🏠 Home')),
    Center(child: Text('🔍 Zoeken')),
    Center(child: Text('💬 Chat')),
    Center(child: Text('👤 Profiel')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoofdmenu')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Zoeken'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profiel'),
        ],
      ),
    );
  }
}
