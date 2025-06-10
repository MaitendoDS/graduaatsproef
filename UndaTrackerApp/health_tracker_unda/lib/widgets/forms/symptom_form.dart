import 'package:flutter/material.dart';
import '../../constants/symptom_constants.dart';
import '../../models/symptom_data.dart';
import '../custom_text_field.dart';
import '../painscale_slider.dart';
import '../section_container.dart';
import '../symptom_type_selector.dart';
import '../time_selector.dart';

class SymptomForm extends StatefulWidget {
  final DateTime selectedDay;
  final Function(SymptomData) onSymptomDataChanged;
  final SymptomData initialData;

  const SymptomForm({
    super.key,
    required this.selectedDay,
    required this.onSymptomDataChanged,
    required this.initialData,
  });

  @override
  State<SymptomForm> createState() => _SymptomFormState();
}

class _SymptomFormState extends State<SymptomForm> {
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late TimeOfDay _selectedTime;
  late String? _selectedType;
  late int _painScale;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.initialData.location);
    _notesController = TextEditingController(text: widget.initialData.notes);
    _selectedTime = widget.initialData.selectedTime;
    _selectedType = widget.initialData.selectedType;
    _painScale = widget.initialData.painScale;
    
    // kijk naar changes in text fields
    _locationController.addListener(_updateSymptomData);
    _notesController.addListener(_updateSymptomData);
  }

  @override
  void dispose() {
    _locationController.removeListener(_updateSymptomData);
    _notesController.removeListener(_updateSymptomData);
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateSymptomData() {
    final symptomData = SymptomData(
      selectedType: _selectedType,
      location: _locationController.text,
      painScale: _painScale,
      notes: _notesController.text,
      selectedDay: widget.selectedDay,
      selectedTime: _selectedTime,
    );
    widget.onSymptomDataChanged(symptomData);
  }

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
      _updateSymptomData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Locatie Card
        SectionContainer(
          title: 'Locatie',
          icon: Icons.location_on,
          iconColor: Colors.orange.shade400,
          children: [
            CustomTextField(
              controller: _locationController,
              hintText: 'Waar voel je dit?',
              accentColor: Colors.orange,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Type Card
        SectionContainer(
          title: 'Type symptoom',
          icon: Icons.category,
          iconColor: Colors.purple.shade400,
          children: [
            SymptomTypeSelector(
              types: SymptomConstants.symptomTypes,
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() => _selectedType = type);
                _updateSymptomData();
              },
              accentColor: Colors.purple,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Tijd Card
        SectionContainer(
          title: 'Tijdstip',
          icon: Icons.access_time,
          iconColor: Colors.green.shade400,
          children: [
            TimeSelector(
              selectedTime: _selectedTime,
              selectedDay: widget.selectedDay,
              onTap: _selectTime,
              accentColor: Colors.green,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Pijnschaal Card
        SectionContainer(
          title: 'Pijnschaal',
          icon: Icons.trending_up,
          iconColor: SymptomConstants.getPainColor(_painScale),
          children: [
            PainScaleSlider(
              painScale: _painScale,
              onChanged: (value) {
                setState(() => _painScale = value);
                _updateSymptomData();
              },
              painDescriptions: SymptomConstants.painDescriptions,
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
      ],
    );
  }
}