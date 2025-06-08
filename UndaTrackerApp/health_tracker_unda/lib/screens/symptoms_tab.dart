import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade400,
              onPrimary: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirm() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geen gebruiker ingelogd")),
      );
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecteer een type symptoom")),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vul een locatie in")),
      );
      return;
    }

    final tijdFormatted = DateFormat.Hm().format(
      DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );

    final data = {
      'uid': user.uid,
      'datum': Timestamp.fromDate(widget.selectedDay),
      'tijd': tijdFormatted,
      'type': _selectedType,
      'locatie': _locationController.text.trim(),
      'pijnschaal': _painScale,
      'notities': _notesController.text.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('symptomen').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Symptoom opgeslagen'),
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
    final formattedDate = DateFormat('EEEE d MMMM y', 'nl').format(widget.selectedDay);
    final tijdFormatted = DateFormat.Hm().format(
      DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Symptomen toevoegen'),
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
                  colors: [Colors.green.shade300, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200.withOpacity(0.3),
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
                      Icon(Icons.health_and_safety, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Nieuw symptoom',
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

            // Locatie Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on, color: Colors.orange.shade400),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Locatie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Waar voel je dit?',
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Type Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.category, color: Colors.purple.shade400),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Type symptoom',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: _types.map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.purple.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedType = type),
                        selectedColor: Colors.purple.shade400,
                        backgroundColor: Colors.purple.shade50,
                        side: BorderSide(
                          color: isSelected ? Colors.purple.shade400 : Colors.purple.shade200,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tijd Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.access_time, color: Colors.green.shade400),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tijdstip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.green.shade400),
                          const SizedBox(width: 12),
                          Text(
                            tijdFormatted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.edit, color: Colors.green.shade400, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pijnschaal Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                          color: _painScale <= 3
                              ? Colors.green.shade100
                              : _painScale <= 7
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: _painScale <= 3
                              ? Colors.green.shade400
                              : _painScale <= 7
                                  ? Colors.orange.shade400
                                  : Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pijnschaal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Text("😊", style: TextStyle(fontSize: 24)),
                      Expanded(child: SizedBox()),
                      Text("😣", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _painScale <= 3
                          ? Colors.green.shade400
                          : _painScale <= 7
                              ? Colors.orange.shade400
                              : Colors.red.shade400,
                      thumbColor: _painScale <= 3
                          ? Colors.green.shade400
                          : _painScale <= 7
                              ? Colors.orange.shade400
                              : Colors.red.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_painScale <= 3
                              ? Colors.green.shade50
                              : _painScale <= 7
                                  ? Colors.orange.shade50
                                  : Colors.red.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_painScale <= 3
                                ? Colors.green.shade200
                                : _painScale <= 7
                                    ? Colors.orange.shade200
                                    : Colors.red.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Score: $_painScale",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _painScale <= 3
                                ? Colors.green.shade700
                                : _painScale <= 7
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                        if (_painDescriptions.containsKey(_painScale)) ...[
                          const SizedBox(height: 8),
                          Text(
                            _painDescriptions[_painScale]!,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notities Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.note_alt, color: Colors.teal.shade400),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Notities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
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
                        borderSide: BorderSide(color: Colors.teal.shade400),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bevestigen Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check, size: 20),
                label: const Text(
                  "Symptoom opslaan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.green.shade200,
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