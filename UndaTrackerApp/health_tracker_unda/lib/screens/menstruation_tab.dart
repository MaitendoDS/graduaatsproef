import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:intl/intl.dart';
import '../models/menstruation_data.dart';
import '../services/menstruation_service.dart';
import '../widgets/buttons/buttons.dart';
import '../widgets/forms/menstruation_form.dart';

class MenstruationTab extends StatefulWidget {
  final DateTime selectedDay;

  const MenstruationTab({super.key, required this.selectedDay});

  @override
  State<MenstruationTab> createState() => _MenstruationTabState();
}

class _MenstruationTabState extends State<MenstruationTab> {
  final MenstruationData _data = MenstruationData();
  final MenstruationService _service = MenstruationService();
  final TextEditingController _notesController = TextEditingController();

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
    final success = await _service.saveMenstruationData(
      selectedDay: widget.selectedDay,
      data: _data,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Menstruatiegegevens opgeslagen'),
          backgroundColor: Colors.pink.shade400,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fout bij opslaan'),
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
            AppHeader(
              title: 'Menstruatie',
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
              label: "Menstruatiegegevens opslaan",
              icon: Icons.check,
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