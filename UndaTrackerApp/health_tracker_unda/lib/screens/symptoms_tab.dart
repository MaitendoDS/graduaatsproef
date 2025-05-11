import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SymptomsTab extends StatefulWidget {
  final DateTime selectedDay;

  const SymptomsTab({super.key, required this.selectedDay});

  @override
  State<SymptomsTab> createState() => _SymptomsTabState();
}

class _SymptomsTabState extends State<SymptomsTab> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final Map<int, String> _painDescriptions = {
    1: "De pijn is amper merkbaar",
    2: "De pijn is merkbaar, maar stoort mijn activiteiten niet",
    3: "De pijn leidt me soms af",
    4: "De pijn leidt me af, maar ik kan gewone activiteiten doen",
    5: "De pijn onderbreekt sommige activiteiten",
    6: "De pijn is moeilijk te negeren, ik vermijd gewone activiteiten",
    7: "De pijn beheerst mijn aandacht, ik doe geen dagelijkse activiteiten",
    8: "De pijn is heel erg, het is moeilijk om iets te doen",
    9: "De pijn is niet uit te staan, niet mogelijk om iets te doen",
    10: "De pijn kan niet erger, niets anders is van belang",
  };

  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _types = ['Pijn', 'Last', 'Gevoelig'];
  String? _selectedType;

  int _painScale = 5;

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
      'type': _selectedType,
      'locatie': _locationController.text,
      'pijnschaal': _painScale,
      'notities': _notesController.text,
    };

    print('Symptoom ingevoerd: $data');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Symptoom opgeslagen')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE d MMMM y',
      'nl',
    ).format(widget.selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Symptomen toevoegen')),
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

            const Text(
              "Locatie:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Waar voel je dit?'),
            ),
            const SizedBox(height: 16),

            const Text("Wat:", style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 10,
              children:
                  _types.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedType = type),
                      selectedColor: Colors.blue.shade100,
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

            const Text(
              "Pijnschaal:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              children: const [
                Text("😊", style: TextStyle(fontSize: 20)),
                Expanded(child: SizedBox()),
                Text("😣", style: TextStyle(fontSize: 20)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor:
                    _painScale <= 3
                        ? Colors.green
                        : _painScale <= 7
                        ? Colors.orange
                        : Colors.red,
                thumbColor:
                    _painScale <= 3
                        ? Colors.green
                        : _painScale <= 7
                        ? Colors.orange
                        : Colors.red,
                inactiveTrackColor: Colors.grey[300],
              ),
              child: Slider(
                value: _painScale.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _painScale.toString(),
                onChanged: (value) {
                  setState(() {
                    _painScale = value.round();
                  });
                },
              ),
            ),
            Center(child: Text("Score: $_painScale")),
            if (_painDescriptions.containsKey(_painScale))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _painDescriptions[_painScale]!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),

            const Text(
              "Notities:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Voeg extra info toe...',
                border: OutlineInputBorder(),
              ),
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
