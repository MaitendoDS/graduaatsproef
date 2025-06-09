import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SymptomData {
  final String? selectedType;
  final String location;
  final int painScale;
  final String notes;
  final DateTime selectedDay;
  final TimeOfDay selectedTime;

  SymptomData({
    this.selectedType,
    required this.location,
    required this.painScale,
    required this.notes,
    required this.selectedDay,
    required this.selectedTime,
  });

  bool get isValid {
    return selectedType != null && location.trim().isNotEmpty;
  }

  Map<String, dynamic> toFirestoreData(String uid) {
    final tijdFormatted = DateFormat.Hm().format(
      DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );

    return {
      'uid': uid,
      'datum': Timestamp.fromDate(selectedDay),
      'tijd': tijdFormatted,
      'type': selectedType,
      'locatie': location.trim(),
      'pijnschaal': painScale,
      'notities': notes.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };
  }
}