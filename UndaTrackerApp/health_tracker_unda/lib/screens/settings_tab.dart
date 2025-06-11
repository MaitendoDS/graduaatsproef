import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:health_tracker_unda/widgets/buttons/buttons.dart';
import 'package:health_tracker_unda/widgets/fields/number_inputfield.dart';
import 'package:health_tracker_unda/widgets/section_container.dart';
import 'package:health_tracker_unda/widgets/fields/switch_field.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/pdf_report_service.dart';
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
        birthDate =
            (data['birthDate'] != null)
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
      SnackBar(
        content: const Text('Instellingen opgeslagen'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade400,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _generateHealthReport() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Rapport genereren...'),
            const SizedBox(height: 8),
            Text(
              'Dit kan even duren',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final pdfBytes = await PdfReportService.generateHealthReport();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show options dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                const SizedBox(width: 8),
                const Text('Rapport Gereed'),
              ],
            ),
            content: const Text(
              'Je gezondheidsrapport is succesvol gegenereerd. Wat wil je ermee doen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuleren',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await PdfReportService.sharePdf(pdfBytes);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delen'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await PdfReportService.printPdf(pdfBytes);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Printen'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij genereren rapport: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 8),
                const Text('Uitloggen'),
              ],
            ),
            content: const Text('Weet je zeker dat je wilt uitloggen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Annuleer',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Uitloggen'),
              ),
            ],
          ),
    );
  }

  Widget _buildDateField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: InkWell(
        onTap: _pickBirthDate,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.cake, color: Colors.purple.shade400),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Geboortedatum',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Leeftijd: ${age > 0 ? '$age jaar' : 'Niet ingesteld'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade300),
              ),
              child: Text(
                birthDate != null
                    ? DateFormat('dd-MM-yyyy').format(birthDate!)
                    : 'Kies datum',
                style: TextStyle(
                  color:
                      birthDate != null ? Colors.black : Colors.purple.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            AppHeader(
              title: 'Instellingen',
              subtitle: 'Personaliseer je app-ervaring',
              icon: Icons.settings,
              
            ),

            const SizedBox(height: 24),

            // Cyclus instellingen
            SectionContainer(
              title: 'Cyclusinstellingen',
              icon: Icons.refresh,
              iconColor: Colors.green.shade400,
              children: [
                NumberInputField(
                  label: 'Cyclusduur',
                  subtitle: 'Gemiddelde lengte van je cyclus',
                  icon: Icons.calendar_month,
                  value: cycleLength,
                  onChanged:
                      (val) => setState(() {
                        cycleLength = val;
                        _hasChanges = true;
                      }),
                ),

                const SizedBox(height: 12),

                NumberInputField(
                  label: 'Duur menstruatie',
                  subtitle: 'Aantal dagen van je menstruatie',
                  icon: Icons.circle,
                  value: menstruationLength,
                  onChanged:
                      (val) => setState(() {
                        menstruationLength = val;
                        _hasChanges = true;
                      }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Persoonlijke informatie
            SectionContainer(
              title: 'Persoonlijke informatie',
              icon: Icons.person,
              iconColor: Colors.purple.shade400,
              children: [
                const SizedBox(height: 16),

                _buildDateField(),

                const SizedBox(height: 12),

                SwitchField(
                  title: 'Seksueel actief',
                  subtitle: 'Voor nauwkeurigere voorspellingen',
                  icon: Icons.favorite,
                  value: sexuallyActive,
                  activeColor: Colors.pink.shade400,
                  onChanged:
                      (val) => setState(() {
                        sexuallyActive = val;
                        _hasChanges = true;
                      }),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Acties
            SectionContainer(
              title: 'Acties',
              icon: Icons.dashboard,
              iconColor: Colors.orange.shade400,
              children: [
                const SizedBox(height: 16),

                if (_hasChanges) ...[
                  ActionButton(
                    label: 'Instellingen opslaan',
                    icon: Icons.save,
                    color: Colors.green.shade600,
                    onPressed: _saveSettings,
                  ),
                  const SizedBox(height: 12),
                ],

                ActionButton(
                  label: 'Rapport voor huisarts',
                  icon: Icons.picture_as_pdf,
                  color: Colors.teal.shade300,
                  onPressed: _generateHealthReport,
                ),

                const SizedBox(height: 12),

                ActionButton(
                  label: 'Tips',
                  icon: Icons.lightbulb,
                  color: Colors.amber.shade300,
                  onPressed: () {},
                ),

                const SizedBox(height: 12),

                ActionButton(
                  label: 'Log uit',
                  icon: Icons.logout,
                  color: Colors.red.shade400,
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}