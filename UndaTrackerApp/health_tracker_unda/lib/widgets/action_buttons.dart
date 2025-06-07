import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onSymptomsPressed;
  final VoidCallback onMenstruationPressed;

  const ActionButtons({
    super.key,
    required this.selectedDay,
    required this.onSymptomsPressed,
    required this.onMenstruationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSymptomsPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.healing),
            label: const Text(
              'Symptomen',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onMenstruationPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade100,
              foregroundColor: Colors.pink.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.bloodtype),
            label: const Text(
              'Menstruatie',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
