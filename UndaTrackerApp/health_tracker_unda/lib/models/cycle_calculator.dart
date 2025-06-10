import 'package:flutter/material.dart';

import '../services/tracking_service.dart';


class CycleCalculator {
  final FirestoreService _firestoreService = FirestoreService();
  
  int _cycleLength = 28;
  int _menstruationLength = 5;
  DateTime? _lastPeriodStart;
  
  // Cache for symptoms and menstruation data
  Map<String, List<Map<String, dynamic>>> _symptomsCache = {};
  Map<String, List<Map<String, dynamic>>> _foodCache = {};
  Map<String, Map<String, dynamic>> _menstruationCache = {};
  
  // Getters
  int get cycleLength => _cycleLength;
  int get menstruationLength => _menstruationLength;
  DateTime? get lastPeriodStart => _lastPeriodStart;

  // Initialize with user data from Firestore
  Future<void> initialize() async {
    final userData = await _firestoreService.getUserCycleData();
    if (userData != null) {
      _cycleLength = userData['cycleLength'] ?? 28;
      _menstruationLength = userData['menstruationLength'] ?? 5;
    }
    
    // Get the most recent menstruation start date
    final menstruationDates = await _firestoreService.getAllMenstruationDates();
    if (menstruationDates.isNotEmpty) {
      _lastPeriodStart = menstruationDates.first;
    } else {
      _lastPeriodStart = DateTime.now().subtract(const Duration(days: 8));
    }
  }

  // Load data for calendar display
  Future<void> loadDataForDateRange(DateTime startDate, DateTime endDate) async {
    _symptomsCache = await _firestoreService.getSymptomsForDateRange(startDate, endDate);
    _menstruationCache = await _firestoreService.getMenstruationForDateRange(startDate, endDate);
    _foodCache = await _firestoreService.getFoodForDateRange(startDate, endDate);
    print('FoodCache keys: ${_foodCache.keys.toList()}');
    print('SymptomsCache keys: ${_symptomsCache.keys.toList()}');
    print('MenstruationCache keys: ${_menstruationCache.keys.toList()}');
  }

  // Check if day has menstruation data from Firestore
  bool isMenstruationDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _menstruationCache.containsKey(dateKey);
  }

  // Predicted menstruation based on cycle
  bool isPredictedMenstruationDay(DateTime day) {
    if (_lastPeriodStart == null) return false;
    
    int daysSinceLastPeriod = day.difference(_lastPeriodStart!).inDays;
    return daysSinceLastPeriod >= 0 &&
        daysSinceLastPeriod % _cycleLength < _menstruationLength;
  }

  bool isOvulationDay(DateTime day) {
    if (_lastPeriodStart == null) return false;
    
    int cycleDay = (day.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
    return cycleDay == 14;
  }

  bool isFertileDay(DateTime day) {
    if (_lastPeriodStart == null) return false;
    
    int cycleDay = (day.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
    return cycleDay >= 10 && cycleDay <= 15;
  }

  // Check if day has symptoms from Firestore
  bool hasSymptoms(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _symptomsCache.containsKey(dateKey) && _symptomsCache[dateKey]!.isNotEmpty;
  }

  List<Map<String, dynamic>> getSymptomsForDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _symptomsCache[dateKey] ?? [];
  }

  List<Map<String, dynamic>> getFoodForDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _foodCache[dateKey] ?? [];
  }

  Map<String, dynamic>? getMenstruationForDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _menstruationCache[dateKey];
  }

  String getCycleDayLabel(DateTime date) {
    if (_lastPeriodStart == null) return 'Dag onbekend';
    
    int dayDiff = date.difference(_lastPeriodStart!).inDays;
    int cycleDay = (dayDiff % _cycleLength) + 1;

    if (isMenstruationDay(date)) {
      return 'Menstruatiedag (geregistreerd)';
    } else if (cycleDay <= _menstruationLength) {
      return 'Voorspelde menstruatiedag $cycleDay';
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
    if (_lastPeriodStart == null) return 'Geen cyclus data beschikbaar';
    
    int cycleDay = (date.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;

    if (isMenstruationDay(date)) {
      return 'Je menstruatie is geregistreerd voor deze dag.';
    } else if (cycleDay <= _menstruationLength) {
      return 'Voorspelde menstruatie. Registreer je periode als deze begint.';
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
    if (_lastPeriodStart == null) return 'Onbekend';
    
    int cycleDay = (date.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
    if (cycleDay == 14) return 'Zeer hoog (±80%)';
    if (cycleDay >= 12 && cycleDay <= 16) return 'Hoog (±60%)';
    if (cycleDay >= 10 && cycleDay <= 18) return 'Gemiddeld (±30%)';
    return 'Laag (<5%)';
  }

  Color getPregnancyChanceColor(DateTime date) {
    if (_lastPeriodStart == null) return Colors.grey;
    
    int cycleDay = (date.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
    if (cycleDay == 14) return Colors.red.shade600;
    if (cycleDay >= 12 && cycleDay <= 16) return Colors.orange.shade600;
    if (cycleDay >= 10 && cycleDay <= 18) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }

  DateTime? getNextPeriodStart(DateTime selectedDay) {
    if (_lastPeriodStart == null) return null;
    
    DateTime next = _lastPeriodStart!;
    while (next.isBefore(selectedDay)) {
      next = next.add(Duration(days: _cycleLength));
    }
    return next;
  }

  int getDaysUntilNextPeriod(DateTime selectedDay) {
    final nextPeriod = getNextPeriodStart(selectedDay);
    if (nextPeriod == null) return 0;
    return nextPeriod.difference(selectedDay).inDays;
  }

  bool isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  Widget? buildCalendarDay(DateTime day, Map<String, bool> filters) {
    bool hasSymptomsToday = hasSymptoms(day);
    bool isMenstruation = isMenstruationDay(day);
    bool isPredictedMenstruation = isPredictedMenstruationDay(day);
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

    // Actual menstruation takes priority over predicted
    if (isMenstruation && (filters['menstruation'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.pinkAccent,
        icon: Icons.water_drop,
        showSymptomsIcon: hasSymptomsToday && (filters['symptoms'] ?? true),
      );
    }

    // Show predicted menstruation with different styling
    if (isPredictedMenstruation && (filters['menstruation'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.pink.shade100,
        icon: Icons.water_drop_outlined,
        textColor: Colors.pink.shade700,
        hasBorder: true,
        borderColor: Colors.pink.shade300,
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

    // Show symptoms if no other phase
    if (hasSymptomsToday && (filters['symptoms'] ?? true)) {
      return _buildCalendarDayContainer(
        day: day,
        color: Colors.orange.shade300,
        icon: Icons.healing,
        textColor: Colors.white,
        showSymptomsIcon: false,
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