import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int cycleLength = 28;
  int menstruationLength = 5;
  DateTime? birthDate;
  bool sexuallyActive = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        cycleLength = data['cycleLength'] ?? 28;
        menstruationLength = data['menstruationLength'] ?? 5;
        birthDate = (data['birthDate'] != null)
            ? (data['birthDate'] as Timestamp).toDate()
            : null;
        sexuallyActive = data['sexuallyActive'] ?? false;
        _hasChanges = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'cycleLength': cycleLength,
      'menstruationLength': menstruationLength,
      'birthDate': birthDate,
      'sexuallyActive': sexuallyActive,
    }, SetOptions(merge: true));

    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Instellingen opgeslagen')),
    );
  }

  int get age {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int calculatedAge = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  void _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
        _hasChanges = true;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uitloggen'),
        content: const Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Uitloggen'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => onChanged((value > 1) ? value - 1 : value),
            ),
            Text(value.toString()),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instellingen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            _buildNumberField(
              label: 'Cyclusduur (dagen)',
              value: cycleLength,
              onChanged: (val) => setState(() {
                cycleLength = val;
                _hasChanges = true;
              }),
            ),
            const SizedBox(height: 16),

            _buildNumberField(
              label: 'Duur menstruatie (dagen)',
              value: menstruationLength,
              onChanged: (val) => setState(() {
                menstruationLength = val;
                _hasChanges = true;
              }),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickBirthDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Geboortedatum'),
                  Text(
                    birthDate != null
                        ? DateFormat('dd-MM-yyyy').format(birthDate!)
                        : 'Kies datum',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Leeftijd: ${age > 0 ? '$age jaar' : 'Niet ingesteld'}'),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seksueel actief'),
                Switch(
                  value: sexuallyActive,
                  onChanged: (val) => setState(() {
                    sexuallyActive = val;
                    _hasChanges = true;
                  }),
                ),
              ],
            ),

            const SizedBox(height: 32),

            if (_hasChanges)
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Instellingen opslaan'),
              ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Rapport voor huisarts'),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lightbulb),
              label: const Text('Tips'),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Log uit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
