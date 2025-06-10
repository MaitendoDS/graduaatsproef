import 'package:flutter/material.dart';

class FoodConstants {
  // Food type options with icons
  static const List<Map<String, dynamic>> foodTypeOptions = [
    {'label': 'Ontbijt', 'icon': Icons.free_breakfast},
    {'label': 'Lunch', 'icon': Icons.lunch_dining},
    {'label': 'Diner', 'icon': Icons.dinner_dining},
    {'label': 'Snack', 'icon': Icons.cookie},
    {'label': 'Drinken', 'icon': Icons.local_drink},
  ];

  // Allergen options
  static const List<String> allergenOptions = [
    'Zuivel',
    'Gluten',
    'Noten',
    'Eieren',
    'Vis',
    'Schaaldieren',
    'Soja',
    'Sesam',
    'Mosterd',
    'Selderij',
    'Lupine',
    'Sulfiet',
  ];

  // UI Constants
  static const double defaultPadding = 20.0;
  static const double sectionSpacing = 16.0;
  static const double borderRadius = 12.0;

  // Colors
  static const Color primaryFoodColor = Colors.green;
  static final Color backgroundGrey = Colors.grey.shade50;
  static final Color successGreen = Colors.green.shade400;
  static final Color errorRed = Colors.red.shade400;

  // Text constants
  static const String appBarTitle = 'Voeding toevoegen';
  static const String headerTitle = 'Voeding';
  static const String foodFieldLabel = 'Wat heb je gegeten?';
  static const String ingredientsFieldLabel = 'Ingrediënten';
  static const String notesFieldLabel = 'Notities';
  static const String foodTypesLabel = 'Type maaltijd';
  static const String allergensLabel = 'Allergenen';
  static const String timeLabel = 'Tijd';
  static const String saveButtonText = 'Opslaan';

  // Messages
  static const String successMessage = 'Voedinggegevens opgeslagen';
  static const String noUserMessage = 'Geen gebruiker ingelogd';
  static const String saveErrorPrefix = 'Fout bij opslaan: ';

  // Validation
  static const int maxFoodLength = 100;
  static const int maxIngredientsLength = 200;
  static const int maxNotesLength = 500;
}