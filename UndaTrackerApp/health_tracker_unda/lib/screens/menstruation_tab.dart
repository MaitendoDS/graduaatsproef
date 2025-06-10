import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/chip_selector.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/icon_selector.dart';
import '../widgets/section_container.dart';

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
    'Ok',
    'Krampen',
    'Gevoelige borsten',
    'Hoofdpijn',
    'Vermoeid',
    'Misselijk',
    'Acne',
    'Rugpijn',
    'Opgeblazen',
    'Slapeloos',
    'Constipatie',
    'Diarree',
    'Duizelig',
    'Bekkenpijn',
  ];

  final List<String> dischargeAmounts = ['Geen', 'Licht', 'Gemiddeld', 'Zwaar'];
  final List<String> dischargeTypes = [
    'Waterig',
    'Slijmerig',
    'Romig',
    'Eiwit',
    'Spotting',
    'Abnormaal',
  ];
  final List<String> otherOptions = ['Stress', 'Ziekte', 'Reizen'];

  Widget buildIconSelector(
    List<Map<String, dynamic>> options,
    Set<String> selectedSet,
    Color baseColor,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            options.map((option) {
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
                          color:
                              isSelected
                                  ? baseColor
                                  : baseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color:
                                isSelected
                                    ? baseColor
                                    : baseColor.withOpacity(0.3),
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
                            color:
                                isSelected ? baseColor : Colors.grey.shade600,
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
    final formattedDate = DateFormat(
      'EEEE d MMMM y',
      'nl',
    ).format(widget.selectedDay);

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
            AppHeader(
              title: 'Menstruatie',
              subtitle: formattedDate,
              icon: Icons.favorite,
              color: Colors.pink,
            ),

            const SizedBox(height: 24),

            // Seks Card
            SectionContainer(
              title: 'Seks',
              icon: Icons.favorite_border,
              iconColor: Colors.purple.shade400,
              children: [
                IconSelector(
                  options: sexOptions,
                  initialSelection: selectedSexOptions,
                  baseColor: Colors.purple.shade400,
                  allowMultipleSelection: true,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedSexOptions.clear();
                      selectedSexOptions.addAll(selectedItems);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Symptomen Card
            SectionContainer(
              title: 'Symptomen',
              icon: Icons.health_and_safety,
              iconColor: Colors.green.shade400,
              children: [
                ChipSelector(
                  options: symptomOptions,
                  chipColor: Colors.green,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedSymptoms.clear();
                      selectedSymptoms.addAll(selectedItems);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Vaginale afscheiding hoeveelheid Card
            SectionContainer(
              title: 'Vaginale afscheiding',
              icon: Icons.water_drop,
              iconColor: Colors.red.shade400,
              children: [
                ChipSelector(
                  options: dischargeAmounts,
                  chipColor: Colors.red,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedDischargeAmount.clear();
                      selectedDischargeAmount.addAll(selectedItems);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Type vaginale afscheiding Card
            SectionContainer(
              title: 'Type vaginale afscheiding',
              icon: Icons.category,
              iconColor: Colors.blueGrey.shade400,
              children: [
                ChipSelector(
                  options: dischargeTypes,
                  chipColor: Colors.blueGrey,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedDischargeType.clear();
                      selectedDischargeType.addAll(selectedItems);
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Overige Card
            SectionContainer(
              title: 'Overige',
              icon: Icons.more_horiz,
              iconColor: Colors.amber.shade400,
              children: [
                ChipSelector(
                  options: otherOptions,
                  chipColor: Colors.amber,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedOther.clear();
                      selectedOther.addAll(selectedItems);
                    });
                  },
                ),
              ],
            ),
   const SizedBox(height: 16),

            // Notities Card
            SectionContainer(
          title: 'Notities',
          icon: Icons.note_alt,
          iconColor: Colors.orange.shade400,
          children: [
            CustomTextField(
              controller: _notesController,
              hintText: 'Voeg extra info toe...',
              maxLines: 4,
              accentColor: Colors.orange,
            ),
          ],
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
