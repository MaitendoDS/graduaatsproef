import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay selectedTime;
  final DateTime selectedDay;
  final VoidCallback onTap;
  final MaterialColor accentColor;

  const TimeSelector({
    super.key,
    required this.selectedTime,
    required this.selectedDay,
    required this.onTap,
    this.accentColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final tijdFormatted = DateFormat.Hm().format(
      DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: accentColor.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: accentColor.shade400),
            const SizedBox(width: 12),
            Text(
              tijdFormatted,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit,
              color: accentColor.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}