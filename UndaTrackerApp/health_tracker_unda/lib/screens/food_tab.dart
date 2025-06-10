import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FoodTab extends StatefulWidget {
  final DateTime selectedDay;

  const FoodTab({super.key, required this.selectedDay});

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  final List<String> _foodTypes = ['Maaltijd', 'Snack'];
  String? _selectedFoodType;

  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _containsDairy = false;
  bool _containsGluten = false;

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

  void _confirm() {
    final data = {
      'datum': widget.selectedDay,
      'tijd': _selectedTime.format(context),
      'type': _selectedFoodType,
      'wat': _foodController.text,
      'ingredienten': _ingredientsController.text,
      'bevat_zuivel': _containsDairy,
      'bevat_gluten': _containsGluten,
    };

    print('Voeding ingevoerd: $data');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voeding opgeslagen')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE d MMMM y', 'nl').format(widget.selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Voeding toevoegen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            const Text("Wat voor soort:", style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 10,
              children: _foodTypes.map((type) {
                final isSelected = _selectedFoodType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFoodType = type),
                  selectedColor: Colors.green.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text("Tijd:", style: TextStyle(fontWeight: FontWeight.w600)),
            ListTile(
              title: Text('Tijdstip: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),

            const Text("Wat heb je gegeten:", style: TextStyle(fontWeight: FontWeight.w600)),
            TextField(
              controller: _foodController,
              decoration: const InputDecoration(hintText: 'Bijvoorbeeld: Boterham met kaas'),
            ),
            const SizedBox(height: 16),

            const Text("Ingrediënten (optioneel):", style: TextStyle(fontWeight: FontWeight.w600)),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                hintText: 'Bijvoorbeeld: brood, kaas, boter',
              ),
            ),
            const SizedBox(height: 16),

            const Text("Bevat:", style: TextStyle(fontWeight: FontWeight.w600)),
            CheckboxListTile(
              title: const Text("Zuivel"),
              value: _containsDairy,
              onChanged: (value) => setState(() => _containsDairy = value!),
            ),
            CheckboxListTile(
              title: const Text("Gluten"),
              value: _containsGluten,
              onChanged: (value) => setState(() => _containsGluten = value!),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check),
                label: const Text("Bevestigen"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
