
import 'package:flutter/material.dart';

import 'cycle/cycle_calender_builder.dart';
import 'cycle/cycle_data_manager.dart';
import 'cycle/cycle_phase_analyzer.dart';
import 'cycle/cycle_predictions.dart';

class CycleCalculator {
  final _dataManager = CycleDataManager();
  final _predictions = CyclePredictions();
  final _calendarBuilder = CycleCalendarBuilder();
  final _phaseAnalyzer = CyclePhaseAnalyzer();

  // Getters - behoud backward compatibility
  int get cycleLength => _dataManager.cycleLength;
  int get menstruationLength => _dataManager.menstruationLength;
  DateTime? get lastPeriodStart => _dataManager.lastPeriodStart;

  // Main initialization
  Future<void> initialize() async {
    await _dataManager.initialize();
    _predictions.updateCycleData(
      _dataManager.cycleLength, 
      _dataManager.menstruationLength,
      _dataManager.lastPeriodStart,
    );
  }

  // Data loading
  Future<void> loadDataForDateRange(DateTime startDate, DateTime endDate) async {
    await _dataManager.loadDataForDateRange(startDate, endDate);
  }

  // Calendar day building - main public interface
  Widget? buildCalendarDay(DateTime day, Map<String, bool> filters) {
    return _calendarBuilder.buildCalendarDay(
      day, 
      filters, 
      _dataManager, 
      _predictions,
    );
  }

  // Data access methods
  bool isMenstruationDay(DateTime day) => _dataManager.isMenstruationDay(day);
  bool hasSymptoms(DateTime day) => _dataManager.hasSymptoms(day);
  List<Map<String, dynamic>> getFoodForDay(DateTime day) => _dataManager.getFoodForDay(day);
  List<Map<String, dynamic>> getSymptomsForDay(DateTime day) => _dataManager.getSymptomsForDay(day);
  Map<String, dynamic>? getMenstruationForDay(DateTime day) => _dataManager.getMenstruationForDay(day);

  // Prediction methods
  bool isPredictedMenstruationDay(DateTime day) => _predictions.isPredictedMenstruationDay(day);
  bool isOvulationDay(DateTime day) => _predictions.isOvulationDay(day);
  bool isFertileDay(DateTime day) => _predictions.isFertileDay(day);
  DateTime? getNextPeriodStart(DateTime selectedDay) => _predictions.getNextPeriodStart(selectedDay);
  int getDaysUntilNextPeriod(DateTime selectedDay) => _predictions.getDaysUntilNextPeriod(selectedDay);

  // Phase analysis
  String getCycleDayLabel(DateTime date) => _phaseAnalyzer.getCycleDayLabel(date, _dataManager, _predictions);
  String getPhaseDescription(DateTime date) => _phaseAnalyzer.getPhaseDescription(date, _dataManager, _predictions);
  String getPregnancyChance(DateTime date) => _phaseAnalyzer.getPregnancyChance(date, _predictions);
  Color getPregnancyChanceColor(DateTime date) => _phaseAnalyzer.getPregnancyChanceColor(date, _predictions);

  // Utility
  bool isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}