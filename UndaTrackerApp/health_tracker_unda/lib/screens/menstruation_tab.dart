import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String notes = '';

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

  Widget buildCategory(String title, Widget child, {Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget buildChipSelector(List<String> options, Set<String> selectedSet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(option),
            selected: selectedSet.contains(option),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedSet.add(option);
                } else {
                  selectedSet.remove(option);
                }
              });
            },
          ),
        )).toList(),
      ),
    );
  }

  Widget buildIconSelector(List<Map<String, dynamic>> options, Set<String> selectedSet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) => Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedSet.contains(option['label'])) {
                      selectedSet.remove(option['label']);
                    } else {
                      selectedSet.add(option['label']);
                    }
                  });
                },
                child: CircleAvatar(
                  backgroundColor: selectedSet.contains(option['label']) ? Colors.pink[200] : Colors.grey[300],
                  child: Icon(option['icon'], color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(option['label'], style: const TextStyle(fontSize: 12)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menstruatie")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datum: ${DateFormat('EEEE d MMMM y', 'nl').format(widget.selectedDay)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            buildCategory('Seks', buildIconSelector(sexOptions, selectedSexOptions), color: Colors.purple[50]),
            buildCategory('Symptomen', buildChipSelector(symptomOptions, selectedSymptoms), color: Colors.blue[50]),
            buildCategory('Vaginale afscheiding', buildChipSelector(dischargeAmounts, selectedDischargeAmount), color: Colors.teal[50]),
            buildCategory('Type vaginale afscheiding', buildChipSelector(dischargeTypes, selectedDischargeType), color: Colors.cyan[50]),
            buildCategory('Overige', buildChipSelector(otherOptions, selectedOther), color: Colors.amber[50]),
            const SizedBox(height: 16),
            const Text("Notities:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Typ hier je notities...",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => notes = val,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Opslaan-logica hier
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text("Opslaan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
