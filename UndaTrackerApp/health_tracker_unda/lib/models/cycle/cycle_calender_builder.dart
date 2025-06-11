import 'package:flutter/material.dart';
import 'cycle_data_manager.dart';
import 'cycle_predictions.dart';

class CycleCalendarBuilder {
  Widget? buildCalendarDay(
    DateTime day, 
    Map<String, bool> filters,
    CycleDataManager dataManager,
    CyclePredictions predictions,
  ) {
    bool hasSymptomsToday = dataManager.hasSymptoms(day);
    bool isMenstruation = dataManager.isMenstruationDay(day);
    // bool isPredictedMenstruation = predictions.isPredictedMenstruationDay(day);
    bool isOvulation = predictions.isOvulationDay(day);
    bool isFertile = predictions.isFertileDay(day);
    bool isTodayFlag = _isToday(day);

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

    // // toon predicted menstruation met andere styling
    // if (isPredictedMenstruation && (filters['menstruation'] ?? true)) {
    //   return _buildCalendarDayContainer(
    //     day: day,
    //     color: Colors.pink.shade100,
    //     icon: Icons.water_drop_outlined,
    //     textColor: Colors.pink.shade700,
    //     hasBorder: true,
    //     borderColor: Colors.pink.shade300,
    //     showSymptomsIcon: hasSymptomsToday && (filters['symptoms'] ?? true),
    //   );
    // }

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

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
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
            child: Icon(Icons.healing, size: 10, color: Colors.orange.shade900),
          ),
      ],
    );
  }
}