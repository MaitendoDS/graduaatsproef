
import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/app_header.dart';
import 'package:intl/intl.dart';
import '../models/symptom_data.dart';
import '../services/symptom_service.dart';
import '../widgets/buttons.dart';
import '../widgets/symptom_form.dart';

class SymptomsTab extends StatefulWidget {
  final DateTime selectedDay;

  const SymptomsTab({super.key, required this.selectedDay});

  @override
  State<SymptomsTab> createState() => _SymptomsTabState();
}

class _SymptomsTabState extends State<SymptomsTab> {
  late SymptomData _currentSymptomData;

  @override
  void initState() {
    super.initState();
    _currentSymptomData = SymptomData(
      location: '',
      painScale: 5,
      notes: '',
      selectedDay: widget.selectedDay,
      selectedTime: TimeOfDay.now(),
    );
  }

  void _onSymptomDataChanged(SymptomData newData) {
    setState(() {
      _currentSymptomData = newData;
    });
  }

  Future<void> _confirm() async {
    final errorMessage = await SymptomService.saveSymptom(_currentSymptomData);
    
    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Symptoom opgeslagen'),
          backgroundColor: Colors.green.shade400,
        ),
      );
      Navigator.pop(context);
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
            AppHeader(
              title: 'Nieuw symptoom',
              subtitle: formattedDate,
              icon: Icons.health_and_safety,
            ),

            const SizedBox(height: 24),

            // Form
            SymptomForm(
              selectedDay: widget.selectedDay,
              onSymptomDataChanged: _onSymptomDataChanged,
              initialData: _currentSymptomData,
            ),

            const SizedBox(height: 32),

            // Bevestigen Button
            ActionButton(
              label: "Symptoom opslaan",
              icon: Icons.check,
              color: Colors.green.shade400,
              onPressed: _confirm,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}