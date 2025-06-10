import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/buttons/buttons.dart';
import '../widgets/chip_selector.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/icon_selector.dart';
import '../widgets/section_container.dart';
import '../widgets/time_selector.dart';

class FoodTab extends StatefulWidget {
  final DateTime selectedDay;

  const FoodTab({super.key, required this.selectedDay});

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final Set<String> selectedFoodTypes = {};
  final Set<String> selectedAllergens = {};
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<Map<String, dynamic>> foodTypeOptions = [
    {'label': 'Ontbijt', 'icon': Icons.free_breakfast},
    {'label': 'Lunch', 'icon': Icons.lunch_dining},
    {'label': 'Diner', 'icon': Icons.dinner_dining},
    {'label': 'Snack', 'icon': Icons.cookie},
    {'label': 'Drinken', 'icon': Icons.local_drink},
  ];

  final List<String> allergenOptions = [
    'Zuivel',
    'Gluten',
    'Noten',
    'Eieren',
    'Vis',
    'Schaaldieren',
    'Soja',
    'Sesam',
    'Mosterd',
    'Selderij',
    'Lupine',
    'Sulfiet',
  ];

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

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

  Widget buildChipSelector(
    List<String> options,
    Set<String> selectedSet,
    Color chipColor,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((option) {
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
      'tijd': _selectedTime.format(context),
      'foodTypes': selectedFoodTypes.toList(),
      'wat': _foodController.text.trim(),
      'ingredienten': _ingredientsController.text.trim(),
      'allergenen': selectedAllergens.toList(),
      'notities': _notesController.text.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('voeding').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Voedinggegevens opgeslagen'),
          backgroundColor: Colors.green.shade400,
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
        title: const Text('Voeding toevoegen'),
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
              title: 'Voeding',
              subtitle: formattedDate,
              icon: Icons.restaurant,
              color: Colors.green,
            ),

            const SizedBox(height: 24),

            // Maaltijd type Card
            SectionContainer(
              title: 'Maaltijd type',
              icon: Icons.restaurant_menu,
              iconColor: Colors.orange.shade400,
              children: [
                IconSelector(
                  options: foodTypeOptions,
                  initialSelection: selectedFoodTypes,
                  baseColor: Colors.orange.shade400,
                  allowMultipleSelection: true,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedFoodTypes.clear();
                      selectedFoodTypes.addAll(selectedItems);
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            // Tijd Card
            SectionContainer(
              title: 'Tijdstip',
              icon: Icons.access_time,
              iconColor: Colors.blue.shade400,
              children: [
                TimeSelector(
                  selectedTime: _selectedTime,
                  selectedDay: widget.selectedDay,
                  onTap: _selectTime,
                  accentColor: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Wat gegeten Card
            SectionContainer(
              title: 'Wat heb je gegeten',
              icon: Icons.fastfood,
              iconColor: Colors.purple.shade400,
              children: [
                CustomTextField(
                  controller: _foodController,
                  hintText: 'Bijvoorbeeld: Boterham met kaas',
                  accentColor: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Ingrediënten Card
            SectionContainer(
              title: 'Ingrediënten',
              icon: Icons.eco,
              iconColor: Colors.green.shade400,
              children: [
                CustomTextField(
                  controller: _ingredientsController,
                  hintText: 'Bijvoorbeeld: brood, kaas, boter',
                  accentColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Allergenen Card
            SectionContainer(
              title: 'Allergenen',
              icon: Icons.warning_amber,
              iconColor: Colors.red.shade400,
              children: [
                ChipSelector(
                  options: allergenOptions,
                  chipColor: Colors.red,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      selectedAllergens.clear();
                      selectedAllergens.addAll(selectedItems);
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
              iconColor: Colors.teal.shade400,
              children: [
                CustomTextField(
                  controller: _notesController,
                  hintText: 'Voeg extra info toe...',
                  maxLines: 4,
                  accentColor: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Opslaan Button
            ActionButton(
              label: "Voedinggegevens opslaan",
              icon: Icons.check,
              color: Colors.green.shade400,
              onPressed: _saveToFirestore,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
