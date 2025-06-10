import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'food_data.dart';

class FoodService {
  static const String _collection = 'voeding';

  static Future<void> saveFoodEntry(FoodData foodData) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Geen gebruiker ingelogd');
    }

    final data = {
      'uid': user.uid,
      'datum': Timestamp.fromDate(foodData.selectedDay),
      'tijd': foodData.selectedTime.format(foodData.context),
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
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(documentId)
        .delete();
  }

  static Future<void> updateFoodEntry(
    String documentId,
    FoodData foodData,
  ) async {
    final data = {
      'datum': Timestamp.fromDate(foodData.selectedDay),
      'tijd': foodData.selectedTime.format(foodData.context),
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
  }
}