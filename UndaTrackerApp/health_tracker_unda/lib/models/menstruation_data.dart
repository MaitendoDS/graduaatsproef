import 'package:flutter/material.dart';

class MenstruationData {
  final Set<String> selectedSexOptions = {};
  final Set<String> selectedSymptoms = {};
  final Set<String> selectedDischargeAmount = {};
  final Set<String> selectedDischargeType = {};
  final Set<String> selectedOther = {};

  // Options data
  static const List<Map<String, dynamic>> sexOptions = [
    {'label': 'Geen seks', 'icon': Icons.block},
    {'label': 'Beschermd', 'icon': Icons.shield},
    {'label': 'Onbeschermd', 'icon': Icons.warning},
    {'label': 'Masturbatie', 'icon': Icons.self_improvement},
    {'label': 'Meer zin', 'icon': Icons.favorite},
  ];

  static const List<String> symptomOptions = [
    'Ok', 'Krampen', 'Gevoelige borsten', 'Hoofdpijn', 'Vermoeid',
    'Misselijk', 'Acne', 'Rugpijn', 'Opgeblazen', 'Slapeloos',
    'Constipatie', 'Diarree', 'Duizelig', 'Bekkenpijn',
  ];

  static const List<String> dischargeAmounts = ['Geen', 'Licht', 'Gemiddeld', 'Zwaar'];
  static const List<String> dischargeTypes = [
    'Waterig', 'Slijmerig', 'Romig', 'Eiwit', 'Spotting', 'Abnormaal',
  ];
  static const List<String> otherOptions = ['Stress', 'Ziekte', 'Reizen'];

  void updateSelection(String type, Set<String> selectedItems) {
    switch (type) {
      case 'sex':
        selectedSexOptions.clear();
        selectedSexOptions.addAll(selectedItems);
        break;
      case 'symptoms':
        selectedSymptoms.clear();
        selectedSymptoms.addAll(selectedItems);
        break;
      case 'dischargeAmount':
        selectedDischargeAmount.clear();
        selectedDischargeAmount.addAll(selectedItems);
        break;
      case 'dischargeType':
        selectedDischargeType.clear();
        selectedDischargeType.addAll(selectedItems);
        break;
      case 'other':
        selectedOther.clear();
        selectedOther.addAll(selectedItems);
        break;
    }
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'sexOptions': selectedSexOptions.toList(),
      'symptoms': selectedSymptoms.toList(),
      'dischargeAmount': selectedDischargeAmount.toList(),
      'dischargeType': selectedDischargeType.toList(),
      'other': selectedOther.toList(),
    };
  }
}
