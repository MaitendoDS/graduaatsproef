import 'package:flutter/material.dart';

class ChipSelector extends StatefulWidget {
  final List<String> options;
  final Set<String> initialSelection;
  final Color chipColor;
  final Function(Set<String>)? onSelectionChanged;

  const ChipSelector({
    Key? key,
    required this.options,
    this.initialSelection = const {},
    this.chipColor = Colors.blue,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  late Set<String> selectedSet;

  @override
  void initState() {
    super.initState();
    selectedSet = Set<String>.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((option) {
        final isSelected = selectedSet.contains(option);
        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.white : widget.chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedSet.add(option);
              } else {
                selectedSet.remove(option);
              }
            });
            // Callback naar parent widget
            widget.onSelectionChanged?.call(selectedSet);
          },
          selectedColor: widget.chipColor,
          backgroundColor: widget.chipColor.withOpacity(0.1),
          side: BorderSide(
            color: isSelected ? widget.chipColor : widget.chipColor.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }
}