
import 'package:flutter/material.dart';

class CycleCalculator {
  int _cycleLength = 28;
  int _menstruationLength = 5;
  DateTime _lastPeriodStart = DateTime.now().subtract(const Duration(days: 1));

  // Getters
  int get cycleLength => _cycleLength;
  int get menstruationLength => _menstruationLength;
  DateTime get lastPeriodStart => _lastPeriodStart;

  // Cycle detection functies
  bool isMenstruationDay(DateTime day) {
    int daysSinceLastPeriod = day.difference(_lastPeriodStart).inDays;
    return daysSinceLastPeriod >= 0 &&
        daysSinceLastPeriod % _cycleLength < _menstruationLength;
  }

  bool isOvulationDay(DateTime day) {
    int cycleDay = (day.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    return cycleDay == 14;
  }

  bool isFertileDay(DateTime day) {
    int cycleDay = (day.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    return cycleDay >= 10 && cycleDay <= 15;
  }

  bool isPreMenstrualDay(DateTime day) {
    int cycleDay = (day.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    return cycleDay >= 25 && cycleDay <= 28;
  }

  List<String> getSymptomsForDay(DateTime day) {
    if (day.day % 5 == 0) return ['Buikpijn', 'Vermoeid'];
    if (day.day % 3 == 0) return ['Hoofdpijn'];
    return [];
  }

  String getCycleDayLabel(DateTime date) {
    int dayDiff = date.difference(_lastPeriodStart).inDays;
    int cycleDay = (dayDiff % _cycleLength) + 1;
    
    if (cycleDay <= _menstruationLength) {
      return 'Menstruatiedag $cycleDay';
    } else if (cycleDay >= 10 && cycleDay <= 15) {
      return 'Vruchtbare periode - Dag $cycleDay';
    } else if (cycleDay == 14) {
      return 'Eisprong - Dag $cycleDay';
    } else if (cycleDay >= 25) {
      return 'Pre-menstrueel - Dag $cycleDay';
    } else {
      return 'Follikulaire fase - Dag $cycleDay';
    }
  }

  String getPhaseDescription(DateTime date) {
    int cycleDay = (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    
    if (cycleDay <= _menstruationLength) {
      return 'Je menstruatie is bezig. Zorg goed voor jezelf!';
    } else if (cycleDay >= 10 && cycleDay <= 15) {
      return 'Dit is je vruchtbare periode. Verhoogde kans op zwangerschap.';
    } else if (cycleDay == 14) {
      return 'Eisprong vindt vandaag plaats. Hoogste vruchtbaarheid.';
    } else if (cycleDay >= 25) {
      return 'Pre-menstruele fase. Je menstruatie komt eraan.';
    } else {
      return 'Follikulaire fase. Je lichaam bereidt zich voor op de eisprong.';
    }
  }

  String getPregnancyChance(DateTime date) {
    int cycleDay = (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    if (cycleDay == 14) return 'Zeer hoog (±80%)';
    if (cycleDay >= 12 && cycleDay <= 16) return 'Hoog (±60%)';
    if (cycleDay >= 10 && cycleDay <= 18) return 'Gemiddeld (±30%)';
    return 'Laag (<5%)';
  }

  Color getPregnancyChanceColor(DateTime date) {
    int cycleDay = (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    if (cycleDay == 14) return Colors.red.shade600;
    if (cycleDay >= 12 && cycleDay <= 16) return Colors.orange.shade600;
    if (cycleDay >= 10 && cycleDay <= 18) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }

  DateTime getNextPeriodStart(DateTime selectedDay) {
    DateTime next = _lastPeriodStart;
    while (next.isBefore(selectedDay)) {
      next = next.add(Duration(days: _cycleLength));
    }
    return next;
  }

  int getDaysUntilNextPeriod(DateTime selectedDay) {
    return getNextPeriodStart(selectedDay).difference(selectedDay).inDays;
  }

  Widget? buildCalendarDay(DateTime day) {
    if (isMenstruationDay(day)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.pinkAccent,
        icon: Icons.water_drop,
      );
    } else if (isOvulationDay(day)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.green,
        icon: Icons.favorite,
      );
    } else if (isFertileDay(day)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.green.shade100,
        icon: Icons.eco,
        textColor: Colors.green.shade700,
        hasBorder: true,
        borderColor: Colors.green.shade300,
      );
    } else if (isPreMenstrualDay(day)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.purple.shade100,
        icon: Icons.schedule,
        textColor: Colors.purple.shade700,
        hasBorder: true,
        borderColor: Colors.purple.shade300,
      );
    }
    return null;
  }

  Widget _buildCalendarDayContainer({
    required DateTime day,
    required Color color,
    required IconData icon,
    Color textColor = Colors.white,
    bool hasBorder = false,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: hasBorder && borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: !hasBorder ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: hasBorder ? 10 : 12,
            color: textColor,
          ),
          Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
