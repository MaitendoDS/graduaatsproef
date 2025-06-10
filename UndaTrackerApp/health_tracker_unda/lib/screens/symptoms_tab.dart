import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:intl/intl.dart';
import '../models/symptom_data.dart';
import '../services/symptom_service.dart';
import '../widgets/buttons/buttons.dart';
import '../widgets/forms/symptom_form.dart';

class SymptomsTab extends StatefulWidget {
  final DateTime selectedDay;
  final SymptomData? initialData;  // Voor edit mode
  final bool isEditing;            // Is dit een edit of nieuwe entry
  final String? documentId;        // Document ID voor updates

  const SymptomsTab({
    super.key, 
    required this.selectedDay,
    this.initialData,
    this.isEditing = false,
    this.documentId,
  });

  @override
  State<SymptomsTab> createState() => _SymptomsTabState();
}

class _SymptomsTabState extends State<SymptomsTab> {
  late SymptomData _currentSymptomData;

  @override
  void initState() {
    super.initState();
    
    // Gebruik initialData als beschikbaar, anders maak nieuwe data
    _currentSymptomData = widget.initialData ?? SymptomData(
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
    String? errorMessage;
    
    if (widget.isEditing && widget.documentId != null) {
      // UPDATE bestaande entry
      errorMessage = await SymptomService.updateSymptom(widget.documentId!, _currentSymptomData);
    } else {
      // CREATE nieuwe entry
      errorMessage = await SymptomService.saveSymptom(_currentSymptomData);
    }
    
    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } else {
      final successMessage = widget.isEditing 
          ? 'Symptoom bijgewerkt' 
          : 'Symptoom opgeslagen';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green.shade400,
        ),
      );
      Navigator.pop(context, true); // Return true voor refresh
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
        title: Text(widget.isEditing ? 'Symptoom bewerken' : 'Symptomen toevoegen'),
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
              title: widget.isEditing ? 'Symptoom bewerken' : 'Nieuw symptoom',
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

            // Save/Update Button
            ActionButton(
              label: widget.isEditing ? "Symptoom bijwerken" : "Symptoom opslaan",
              icon: widget.isEditing ? Icons.update : Icons.check,
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