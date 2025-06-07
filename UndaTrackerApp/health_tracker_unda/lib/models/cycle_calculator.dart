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

  // functie om te checken of een dag symptomen heeft
  bool hasSymptoms(DateTime day) {
    List<String> symptoms = getSymptomsForDay(day);
    return symptoms.isNotEmpty;
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

  bool isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  // buildCalendarDay accepteert nu filters
  Widget? buildCalendarDay(DateTime day, Map<String, bool> filters) {
    bool hasSymptomsToday = hasSymptoms(day);
    bool isMenstruation = isMenstruationDay(day);
    bool isOvulation = isOvulationDay(day);
    bool isFertile = isFertileDay(day);
    bool isTodayFlag = isToday(day);

    if (isTodayFlag) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.lightBlue.shade100,
        icon: Icons.star,
        textColor: Colors.black,
        isToday: true,
        showSymptomsIcon: hasSymptomsToday && (filters['symptoms'] ?? true),
      );
    }

    if (isMenstruation && (filters['menstruation'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.pinkAccent,
        icon: Icons.water_drop,
        showSymptomsIcon: hasSymptomsToday && (filters['symptoms'] ?? true),
      );
    }

    if (isOvulation && (filters['ovulation'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.green,
        icon: Icons.favorite,
        showSymptomsIcon: hasSymptomsToday && (filters['symptoms'] ?? true),
      );
    }

    if (isFertile && (filters['fertile'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.green.shade100,
        icon: Icons.eco,
        textColor: Colors.green.shade700,
        hasBorder: true,
        borderColor: Colors.green.shade300,
        showSymptomsIcon: hasSymptomsToday && (filters['symptoms'] ?? true),
      );
    }


    // Als er geen fase maar wel symptomen zijn en symptomen filter aan
    if (hasSymptomsToday && (filters['symptoms'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.orange.shade300,
        icon: Icons.healing,
        textColor: Colors.white,
        showSymptomsIcon: false, // want al symptoom icoon = hoofdicoon hier
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
    bool isToday = false,
    bool showSymptomsIcon = false,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday
                  ? Colors.blue.shade700
                  : hasBorder
                      ? (borderColor ?? Colors.transparent)
                      : Colors.transparent,
              width: isToday
                  ? 2
                  : hasBorder
                      ? 1
                      : 0,
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: textColor),
              Text(
                '${day.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (showSymptomsIcon)
          Positioned(
            top: 2,
            right: 2,
            child: Icon(
              Icons.healing,
              size: 10,
              color: Colors.orange.shade900,
            ),
          ),
      ],
    );
  }
}
