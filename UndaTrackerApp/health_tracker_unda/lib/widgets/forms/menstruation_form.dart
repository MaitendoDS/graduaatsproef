import 'package:flutter/material.dart';
import '../../models/menstruation_data.dart';
import '../fields/chip_selector.dart';
import '../fields/custom_text_field.dart';
import '../fields/icon_selector.dart';
import '../section_container.dart';

class MenstruationSections extends StatelessWidget {
  final MenstruationData data;
  final TextEditingController notesController;
  final Function(String type, Set<String> selectedItems) onSelectionChanged;

  const MenstruationSections({
    Key? key,
    required this.data,
    required this.notesController,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionContainer(
      title: 'Seks',
      icon: Icons.favorite_border,
      iconColor: Colors.purple.shade400,
      children: [
        IconSelector(
          options: MenstruationData.sexOptions,
          initialSelection: data.selectedSexOptions,
          baseColor: Colors.purple.shade400,
          allowMultipleSelection: true,
          onSelectionChanged: (items) => onSelectionChanged('sex', items),
        ),
      ],
    ),
        const SizedBox(height: 16),
        SectionContainer(
      title: 'Symptomen',
      icon: Icons.health_and_safety,
      iconColor: Colors.green.shade400,
      children: [
        ChipSelector(
          options: MenstruationData.symptomOptions,
          initialSelection: data.selectedSymptoms,
          chipColor: Colors.green,
          onSelectionChanged: (items) => onSelectionChanged('symptoms', items),
        ),
      ],
    ),
        const SizedBox(height: 16),
        SectionContainer(
      title: 'Vaginale afscheiding',
      icon: Icons.water_drop,
      iconColor: Colors.red.shade400,
      children: [
        ChipSelector(
          options: MenstruationData.dischargeAmounts,
          initialSelection: data.selectedDischargeAmount,
          chipColor: Colors.red,
          onSelectionChanged: (items) => onSelectionChanged('dischargeAmount', items),
        ),
      ],
    ),
        const SizedBox(height: 16),
        SectionContainer(
      title: 'Type vaginale afscheiding',
      icon: Icons.category,
      iconColor: Colors.blueGrey.shade400,
      children: [
        ChipSelector(
          options: MenstruationData.dischargeTypes,
          initialSelection: data.selectedDischargeType,
          chipColor: Colors.blueGrey,
          onSelectionChanged: (items) => onSelectionChanged('dischargeType', items),
        ),
      ],
    ),
        const SizedBox(height: 16),
        SectionContainer(
      title: 'Overige',
      icon: Icons.more_horiz,
      iconColor: Colors.amber.shade400,
      children: [
        ChipSelector(
          options: MenstruationData.otherOptions,
          initialSelection: data.selectedOther,
          chipColor: Colors.amber,
          onSelectionChanged: (items) => onSelectionChanged('other', items),
        ),
      ],
    ),
        const SizedBox(height: 16),
        SectionContainer(
      title: 'Notities',
      icon: Icons.note_alt,
      iconColor: Colors.orange.shade400,
      children: [
        CustomTextField(
          controller: notesController,
          hintText: 'Voeg extra info toe...',
          maxLines: 4,
          accentColor: Colors.orange,
        ),
      ],
    ),
      ],
    );
  }

}