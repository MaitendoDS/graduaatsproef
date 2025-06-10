import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:intl/intl.dart';
import '../models/menstruation_data.dart';
import '../services/menstruation_service.dart';
import '../widgets/buttons/buttons.dart';
import '../widgets/forms/menstruation_form.dart';

class MenstruationTab extends StatefulWidget {
  final DateTime selectedDay;
  final Map<String, dynamic>? initialData;  // Voor edit mode
  final bool isEditing;                     // Is dit een edit of nieuwe entry
  final String? documentId;                 // Document ID voor updates

  const MenstruationTab({
    super.key, 
    required this.selectedDay,
    this.initialData,
    this.isEditing = false,
    this.documentId,
  });

  @override
  State<MenstruationTab> createState() => _MenstruationTabState();
}

class _MenstruationTabState extends State<MenstruationTab> {
  final MenstruationData _data = MenstruationData();
  final MenstruationService _service = MenstruationService();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Load initial data if editing
    if (widget.isEditing && widget.initialData != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final data = widget.initialData!;
    
    // Load notes
    _notesController.text = data['notities'] ?? '';
    
    // Load selections
    if (data['sexOptions'] != null) {
      _data.selectedSexOptions.addAll(List<String>.from(data['sexOptions']));
    }
    if (data['symptoms'] != null) {
      _data.selectedSymptoms.addAll(List<String>.from(data['symptoms']));
    }
    if (data['dischargeAmount'] != null) {
      _data.selectedDischargeAmount.addAll(List<String>.from(data['dischargeAmount']));
    }
    if (data['dischargeType'] != null) {
      _data.selectedDischargeType.addAll(List<String>.from(data['dischargeType']));
    }
    if (data['other'] != null) {
      _data.selectedOther.addAll(List<String>.from(data['other']));
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateSelection(String type, Set<String> selectedItems) {
    setState(() {
      _data.updateSelection(type, selectedItems);
    });
  }

  Future<void> _saveData() async {
    bool success = false;
    
    if (widget.isEditing && widget.documentId != null) {
      // UPDATE bestaande entry
      success = await _service.updateMenstruationData(
        documentId: widget.documentId!,
        selectedDay: widget.selectedDay,
        data: _data,
        notes: _notesController.text.trim(),
      );
    } else {
      // CREATE nieuwe entry
      success = await _service.saveMenstruationData(
        selectedDay: widget.selectedDay,
        data: _data,
        notes: _notesController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      final successMessage = widget.isEditing 
          ? 'Menstruatiegegevens bijgewerkt' 
          : 'Menstruatiegegevens opgeslagen';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.pink.shade400,
        ),
      );
      Navigator.pop(context, true); // Return true voor refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Fout bij bijwerken' : 'Fout bij opslaan'),
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
        title: Text(widget.isEditing ? 'Menstruatie bewerken' : 'Menstruatie toevoegen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: widget.isEditing ? 'Menstruatie bewerken' : 'Menstruatie',
              subtitle: formattedDate,
              icon: Icons.favorite,
              color: Colors.pink,
            ),
            const SizedBox(height: 24),

            MenstruationSections(
              data: _data,
              notesController: _notesController,
              onSelectionChanged: _updateSelection,
            ),

            const SizedBox(height: 16),
            ActionButton(
              label: widget.isEditing 
                  ? "Menstruatiegegevens bijwerken" 
                  : "Menstruatiegegevens opslaan",
              icon: widget.isEditing ? Icons.update : Icons.check,
              color: Colors.pink.shade400,
              onPressed: _saveData,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}