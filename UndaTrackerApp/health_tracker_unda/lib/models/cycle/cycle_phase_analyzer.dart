
import 'package:flutter/material.dart';
import 'package:health_tracker_unda/models/cycle/cycle_data_manager.dart';
import 'package:health_tracker_unda/models/cycle/cycle_predictions.dart';

class CyclePhaseAnalyzer {
  String getCycleDayLabel(DateTime date, CycleDataManager dataManager, CyclePredictions predictions) {
    if (dataManager.lastPeriodStart == null) return 'Dag onbekend';

    int cycleDay = predictions.getCycleDay(date);

    if (dataManager.isMenstruationDay(date)) {
      return 'Menstruatiedag (geregistreerd)';
    } else if (cycleDay <= dataManager.menstruationLength) {
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

  String getPhaseDescription(DateTime date, CycleDataManager dataManager, CyclePredictions predictions) {
    if (dataManager.lastPeriodStart == null) return 'Geen cyclus data beschikbaar';

    int cycleDay = predictions.getCycleDay(date);

    if (dataManager.isMenstruationDay(date)) {
      return 'Je menstruatie is geregistreerd voor deze dag.';
    } else if (cycleDay <= dataManager.menstruationLength) {
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

  String getPregnancyChance(DateTime date, CyclePredictions predictions) {
    if (predictions.lastPeriodStart == null) return 'Onbekend';

    int cycleDay = predictions.getCycleDay(date);
    if (cycleDay == 14) return 'Zeer hoog (±80%)';
    if (cycleDay >= 12 && cycleDay <= 16) return 'Hoog (±60%)';
    if (cycleDay >= 10 && cycleDay <= 18) return 'Gemiddeld (±30%)';
    return 'Laag (<5%)';
  }

  Color getPregnancyChanceColor(DateTime date, CyclePredictions predictions) {
    if (predictions.lastPeriodStart == null) return Colors.grey;

    int cycleDay = predictions.getCycleDay(date);
    if (cycleDay == 14) return Colors.red.shade600;
    if (cycleDay >= 12 && cycleDay <= 16) return Colors.orange.shade600;
    if (cycleDay >= 10 && cycleDay <= 18) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }
}