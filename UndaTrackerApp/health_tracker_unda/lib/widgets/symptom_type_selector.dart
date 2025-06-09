import 'package:flutter/material.dart';

class SymptomTypeSelector extends StatelessWidget {
  final List<String> types;
  final String? selectedType;
  final Function(String) onTypeSelected;
  final MaterialColor accentColor;

  const SymptomTypeSelector({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
    this.accentColor = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: types.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : accentColor.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onTypeSelected(type),
          selectedColor: accentColor.shade400,
          backgroundColor: accentColor.shade50,
          side: BorderSide(
            color: isSelected ? accentColor.shade400 : accentColor.shade200,
          ),
        );
      }).toList(),
    );
  }
}