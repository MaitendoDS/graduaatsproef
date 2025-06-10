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

  // FIXED: Delete method with proper error handling
  static Future<void> deleteFoodEntry(String documentId) async {
    try {
      print('Attempting to delete food entry: $documentId'); // Debug log
      
      final docRef = FirebaseFirestore.instance.collection(_collection).doc(documentId);
      
      // Check if document exists first
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Voedingsitem bestaat niet meer');
      }
      
      // Delete the document
      await docRef.delete();
      
      print('Successfully deleted food entry: $documentId'); // Debug log
    } catch (e) {
      print('Error deleting food entry: $e'); // Debug log
      throw Exception('Fout bij verwijderen voedingsitem: $e');
    }
  }

  // FIXED: Update method with consistent time format
  static Future<void> updateFoodEntry(
    String documentId,
    FoodData foodData,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Geen gebruiker ingelogd');
    }

    try {
      print('Attempting to update food entry: $documentId'); // Debug log
      
      final data = {
        'datum': Timestamp.fromDate(foodData.selectedDay),
        'tijd': _formatTime(foodData.selectedTime), // Gebruik helper method
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
          
      print('Successfully updated food entry: $documentId'); // Debug log
    } catch (e) {
      print('Error updating food entry: $e'); // Debug log
      throw Exception('Fout bij bijwerken voedingsitem: $e');
    }
  }
}