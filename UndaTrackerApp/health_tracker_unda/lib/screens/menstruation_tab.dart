import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenstruationTab extends StatefulWidget {
  final DateTime selectedDay;

  const MenstruationTab({super.key, required this.selectedDay});

  @override
  State<MenstruationTab> createState() => _MenstruationTabState();
}

class _MenstruationTabState extends State<MenstruationTab> {
  final Set<String> selectedSexOptions = {};
  final Set<String> selectedSymptoms = {};
  final Set<String> selectedDischargeAmount = {};
  final Set<String> selectedDischargeType = {};
  final Set<String> selectedOther = {};
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> sexOptions = [
    {'label': 'Geen seks', 'icon': Icons.block},
    {'label': 'Beschermd', 'icon': Icons.shield},
    {'label': 'Onbeschermd', 'icon': Icons.warning},
    {'label': 'Masturbatie', 'icon': Icons.self_improvement},
    {'label': 'Meer zin', 'icon': Icons.favorite},
  ];

  final List<String> symptomOptions = [
    'Ok', 'Krampen', 'Gevoelige borsten', 'Hoofdpijn', 'Vermoeid', 'Misselijk',
    'Acne', 'Rugpijn', 'Opgeblazen', 'Slapeloos', 'Constipatie',
    'Diarree', 'Duizelig', 'Bekkenpijn'
  ];

  final List<String> dischargeAmounts = ['Geen', 'Licht', 'Gemiddeld', 'Zwaar'];
  final List<String> dischargeTypes = ['Waterig', 'Slijmerig', 'Romig', 'Eiwit', 'Spotting', 'Abnormaal'];
  final List<String> otherOptions = ['Stress', 'Ziekte', 'Reizen'];

  Widget buildStyledCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget buildChipSelector(List<String> options, Set<String> selectedSet, Color chipColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedSet.contains(option);
        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedSet.add(option);
              } else {
                selectedSet.remove(option);
              }
            });
          },
          selectedColor: chipColor,
          backgroundColor: chipColor.withOpacity(0.1),
          side: BorderSide(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }

  Widget buildIconSelector(List<Map<String, dynamic>> options, Set<String> selectedSet, Color baseColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          final isSelected = selectedSet.contains(option['label']);
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedSet.remove(option['label']);
                  } else {
                    selectedSet.add(option['label']);
                  }
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? baseColor : baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? baseColor : baseColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      option['icon'], 
                      color: isSelected ? Colors.white : baseColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? baseColor : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Geen gebruiker ingelogd"),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final data = {
      'uid': user.uid,
      'datum': Timestamp.fromDate(widget.selectedDay),
      'sexOptions': selectedSexOptions.toList(),
      'symptoms': selectedSymptoms.toList(),
      'dischargeAmount': selectedDischargeAmount.toList(),
      'dischargeType': selectedDischargeType.toList(),
      'other': selectedOther.toList(),
      'notities': _notesController.text.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('menstruatie').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Menstruatiegegevens opgeslagen'),
          backgroundColor: Colors.pink.shade400,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij opslaan: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE d MMMM y', 'nl').format(widget.selectedDay);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Menstruatie toevoegen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.pink.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade200.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Menstruatie',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Seks Card
            buildStyledCard(
              title: 'Seks',
              icon: Icons.favorite_border,
              iconColor: Colors.purple.shade400,
              child: buildIconSelector(sexOptions, selectedSexOptions, Colors.purple.shade400),
            ),

            // Symptomen Card
            buildStyledCard(
              title: 'Symptomen',
              icon: Icons.health_and_safety,
              iconColor: Colors.green.shade400,
              child: buildChipSelector(symptomOptions, selectedSymptoms, Colors.green.shade400),
            ),

            // Vaginale afscheiding hoeveelheid Card
            buildStyledCard(
              title: 'Vaginale afscheiding',
              icon: Icons.water_drop,
              iconColor: Colors.red.shade400,
              child: buildChipSelector(dischargeAmounts, selectedDischargeAmount, Colors.red.shade400),
            ),

            // Type vaginale afscheiding Card
            buildStyledCard(
              title: 'Type vaginale afscheiding',
              icon: Icons.category,
              iconColor: Colors.blueGrey.shade400,
              child: buildChipSelector(dischargeTypes, selectedDischargeType, Colors.blueGrey.shade400),
            ),

            // Overige Card
            buildStyledCard(
              title: 'Overige',
              icon: Icons.more_horiz,
              iconColor: Colors.amber.shade400,
              child: buildChipSelector(otherOptions, selectedOther, Colors.amber.shade400),
            ),

            // Notities Card
            buildStyledCard(
              title: 'Notities',
              icon: Icons.note_alt,
              iconColor: Colors.orange.shade400,
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Voeg extra info toe...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade400),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Opslaan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveToFirestore,
                icon: const Icon(Icons.check, size: 20),
                label: const Text(
                  "Menstruatiegegevens opslaan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.pink.shade200,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}