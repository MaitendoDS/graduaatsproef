import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodData {
  final DateTime selectedDay;
  final TimeOfDay selectedTime;
  final Set<String> selectedFoodTypes;
  final String food;
  final String ingredients;
  final Set<String> selectedAllergens;
  final String notes;
  final BuildContext context;

  const FoodData({
    required this.selectedDay,
    required this.selectedTime,
    required this.selectedFoodTypes,
    required this.food,
    required this.ingredients,
    required this.selectedAllergens,
    required this.notes,
    required this.context,
  });

  // Factory constructor for creating empty data
  factory FoodData.empty(DateTime selectedDay, BuildContext context) {
    return FoodData(
      selectedDay: selectedDay,
      selectedTime: TimeOfDay.now(),
      selectedFoodTypes: {},
      food: '',
      ingredients: '',
      selectedAllergens: {},
      notes: '',
      context: context,
    );
  }

  // Copy with method for updating data
  FoodData copyWith({
    DateTime? selectedDay,
    TimeOfDay? selectedTime,
    Set<String>? selectedFoodTypes,
    String? food,
    String? ingredients,
    Set<String>? selectedAllergens,
    String? notes,
    BuildContext? context,
  }) {
    return FoodData(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedFoodTypes: selectedFoodTypes ?? this.selectedFoodTypes,
      food: food ?? this.food,
      ingredients: ingredients ?? this.ingredients,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
      notes: notes ?? this.notes,
      context: context ?? this.context,
    );
  }

  // Validation methods
  bool get isValid {
    return food.trim().isNotEmpty && selectedFoodTypes.isNotEmpty;
  }

  String? get validationError {
    if (food.trim().isEmpty) {
      return 'Voer in wat je hebt gegeten';
    }
    if (selectedFoodTypes.isEmpty) {
      return 'Selecteer minstens één type maaltijd';
    }
    return null;
  }

  // Convert to Map for display purposes
  Map<String, dynamic> toDisplayMap() {
    return {
      'datum': selectedDay,
      'tijd': selectedTime.format(context),
      'foodTypes': selectedFoodTypes.toList(),
      'wat': food,
      'ingredienten': ingredients,
      'allergenen': selectedAllergens.toList(),
      'notities': notes,
    };
  }

  // Create from Firestore document
  factory FoodData.fromFirestore(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    return FoodData(
      selectedDay: (data['datum'] as Timestamp).toDate(),
      selectedTime: TimeOfDay(
        hour: int.parse(data['tijd'].split(':')[0]),
        minute: int.parse(data['tijd'].split(':')[1]),
      ),
      selectedFoodTypes: Set<String>.from(data['foodTypes'] ?? []),
      food: data['wat'] ?? '',
      ingredients: data['ingredienten'] ?? '',
      selectedAllergens: Set<String>.from(data['allergenen'] ?? []),
      notes: data['notities'] ?? '',
      context: context,
    );
  }

  @override
  String toString() {
    return 'FoodData{selectedDay: $selectedDay, selectedTime: $selectedTime, '
        'selectedFoodTypes: $selectedFoodTypes, food: $food, '
        'ingredients: $ingredients, selectedAllergens: $selectedAllergens, '
        'notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodData &&
          runtimeType == other.runtimeType &&
          selectedDay == other.selectedDay &&
          selectedTime == other.selectedTime &&
          selectedFoodTypes == other.selectedFoodTypes &&
          food == other.food &&
          ingredients == other.ingredients &&
          selectedAllergens == other.selectedAllergens &&
          notes == other.notes;

  @override
  int get hashCode =>
      selectedDay.hashCode ^
      selectedTime.hashCode ^
      selectedFoodTypes.hashCode ^
      food.hashCode ^
      ingredients.hashCode ^
      selectedAllergens.hashCode ^
      notes.hashCode;
}