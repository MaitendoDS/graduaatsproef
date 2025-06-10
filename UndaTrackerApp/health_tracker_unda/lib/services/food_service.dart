import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/food_data.dart';

class FoodService {
  static const String _collection = 'voeding';

  // Helper method voor consistente tijd formatting
  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute'; // Altijd 24-uurs formaat opslaan
  }

  static Future<void> saveFoodEntry(FoodData foodData) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Geen gebruiker ingelogd');
    }

    final data = {
      'uid': user.uid,
      'datum': Timestamp.fromDate(foodData.selectedDay),
      'tijd': _formatTime(foodData.selectedTime), // Gebruik helper method
      'foodTypes': foodData.selectedFoodTypes.toList(),
      'wat': foodData.food.trim(),
      'ingredienten': foodData.ingredients.trim(),
      'allergenen': foodData.selectedAllergens.toList(),
      'notities': foodData.notes.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection(_collection).add(data);
  }

  static Future<List<Map<String, dynamic>>> getFoodEntries(
    String uid,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('datum', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('datum')
        .orderBy('tijd')
        .get();

    return querySnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  
static Future<void> deleteFoodEntry(String documentId) async {
  try {
    final docRef = FirebaseFirestore.instance.collection(_collection).doc(documentId);
    
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      throw Exception('Voedingsitem bestaat niet meer');
    }
    
    await docRef.delete();
  } catch (e) {
    throw Exception('Fout bij verwijderen voedingsitem: $e');
  }
}

static Future<void> updateFoodEntry(String documentId, FoodData foodData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Geen gebruiker ingelogd');
  }

  try {
    final data = {
      'datum': Timestamp.fromDate(foodData.selectedDay),
      'tijd': _formatTime(foodData.selectedTime),
      'foodTypes': foodData.selectedFoodTypes.toList(),
      'wat': foodData.food.trim(),
      'ingredienten': foodData.ingredients.trim(),
      'allergenen': foodData.selectedAllergens.toList(),
      'notities': foodData.notes.trim(),
      'bijgewerktOp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(documentId)
        .update(data);
  } catch (e) {
    throw Exception('Fout bij bijwerken voedingsitem: $e');
  }
}

}