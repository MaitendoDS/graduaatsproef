import 'package:flutter/material.dart';
import '../../models/cycle_calculator.dart';

class CycleHeaderWidget extends StatelessWidget {
  final DateTime selectedDay;
  final CycleCalculator cycleCalculator;

  const CycleHeaderWidget({
    super.key,
    required this.selectedDay,
    required this.cycleCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilPeriod = cycleCalculator.getDaysUntilNextPeriod(selectedDay);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade100, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 32,
            color: Colors.pink,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cyclus Tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _getStatusText(daysUntilPeriod),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int daysUntilPeriod) {
    if (cycleCalculator.lastPeriodStart == null) {
      return 'Registreer je eerste menstruatie om te beginnen';
    }
    
    if (daysUntilPeriod > 0) {
      return '$daysUntilPeriod dagen tot volgende menstruatie';
    } else if (daysUntilPeriod == 0) {
      return 'Menstruatie kan vandaag beginnen';
    } else {
      return 'Menstruatie kan elk moment beginnen';
    }
  }
}