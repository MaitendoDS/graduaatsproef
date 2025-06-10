import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:intl/intl.dart';

import '../../constants/food_constants.dart';
import '../../models/food_data.dart';
import '../buttons/buttons.dart';
import '../chip_selector.dart';
import '../custom_text_field.dart';
import '../icon_selector.dart';
import '../section_container.dart';
import '../time_selector.dart';

class FoodForm extends StatefulWidget {
  final DateTime selectedDay;
  final Function(FoodData) onSave;
  final FoodData? initialData;

  const FoodForm({
    super.key,
    required this.selectedDay,
    required this.onSave,
    this.initialData,
  });

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  late final TextEditingController _foodController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _notesController;

  late Set<String> selectedFoodTypes;
  late Set<String> selectedAllergens;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _foodController = TextEditingController(
      text: widget.initialData?.food ?? '',
    );
    _ingredientsController = TextEditingController(
      text: widget.initialData?.ingredients ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialData?.notes ?? '',
    );

    // Initialize selections
    selectedFoodTypes = Set.from(widget.initialData?.selectedFoodTypes ?? {});
    selectedAllergens = Set.from(widget.initialData?.selectedAllergens ?? {});
    _selectedTime = widget.initialData?.selectedTime ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _foodController.dispose();
    _ingredientsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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

  void _handleSave() {
    final foodData = FoodData(
      selectedDay: widget.selectedDay,
      selectedTime: _selectedTime,
      selectedFoodTypes: selectedFoodTypes,
      food: _foodController.text,
      ingredients: _ingredientsController.text,
      selectedAllergens: selectedAllergens,
      notes: _notesController.text,
      context: context,
    );

    // Validate before saving
    if (!foodData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(foodData.validationError ?? 'Ongeldige invoer'),
          backgroundColor: FoodConstants.errorRed,
        ),
      );
      return;
    }

    widget.onSave(foodData);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE d MMMM y',
      'nl',
    ).format(widget.selectedDay);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(FoodConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          const SizedBox(height: 24),
          // Maaltijd type Card
          SectionContainer(
            title: 'Maaltijd type',
            icon: Icons.restaurant_menu,
            iconColor: Colors.orange.shade400,
            children: [
              IconSelector(
                options: FoodConstants.foodTypeOptions,
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
                options: FoodConstants.allergenOptions,
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
          // Bevestigen Button
            ActionButton(
              label: "Voeding opslaan",
              icon: Icons.check,
              color: Colors.green.shade400,
              onPressed: _handleSave,
            ),
        ],
      ),
    );
  }

}