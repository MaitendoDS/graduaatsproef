import 'package:flutter/material.dart';

class IconSelector extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final Set<String> initialSelection;
  final Color baseColor;
  final Function(Set<String>)? onSelectionChanged;
  final bool allowMultipleSelection;

  const IconSelector({
    Key? key,
    required this.options,
    this.initialSelection = const {},
    required this.baseColor,
    this.onSelectionChanged,
    this.allowMultipleSelection = true,
  }) : super(key: key);

  @override
  State<IconSelector> createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  late Set<String> selectedSet;

  @override
  void initState() {
    super.initState();
    selectedSet = Set<String>.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.options.map((option) {
          final isSelected = selectedSet.contains(option['label']);
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (widget.allowMultipleSelection) {
                    // Meerdere selecties toegestaan
                    if (isSelected) {
                      selectedSet.remove(option['label']);
                    } else {
                      selectedSet.add(option['label']);
                    }
                  } else {
                    // Alleen één selectie toegestaan
                    selectedSet.clear();
                    selectedSet.add(option['label']);
                  }
                });
                // Callback naar parent widget
                widget.onSelectionChanged?.call(selectedSet);
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.baseColor
                          : widget.baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? widget.baseColor
                            : widget.baseColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      option['icon'],
                      color: isSelected ? Colors.white : widget.baseColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? widget.baseColor
                            : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}