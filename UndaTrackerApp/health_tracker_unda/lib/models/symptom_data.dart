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
  
  // FROM FIRESTORE CONSTRUCTOR
  factory SymptomData.fromFirestore(Map<String, dynamic> data) {
  // Parse time correctly
  TimeOfDay parsedTime = TimeOfDay.now();
  
  if (data['tijd'] != null) {
    try {
      String timeString = data['tijd'].toString();
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? TimeOfDay.now().hour;
        final minute = int.tryParse(parts[1]) ?? TimeOfDay.now().minute;
        parsedTime = TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print('Error parsing symptom time "${data['tijd']}": $e');
      parsedTime = TimeOfDay.now();
    }
  }

  return SymptomData(
    selectedType: data['type'],
    location: data['locatie'] ?? '',
    painScale: data['pijnschaal'] ?? 5,
    notes: data['notities'] ?? '',
    selectedDay: (data['datum'] as Timestamp).toDate(),
    selectedTime: parsedTime,
  );
}}