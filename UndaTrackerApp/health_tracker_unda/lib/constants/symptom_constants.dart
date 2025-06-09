import 'package:flutter/material.dart';

class SymptomConstants {
  static const List<String> symptomTypes = ['Pijn', 'Last', 'Gevoelig'];
  
  static const Map<int, String> painDescriptions = {
    1: "De pijn is amper merkbaar",
    2: "De pijn is merkbaar, maar stoort mijn activiteiten niet",
    3: "De pijn leidt me soms af",
    4: "De pijn leidt me af, maar ik kan gewone activiteiten doen",
    5: "De pijn onderbreekt sommige activiteiten",
    6: "De pijn is moeilijk te negeren, ik vermijd gewone activiteiten",
    7: "De pijn beheerst mijn aandacht, ik doe geen dagelijkse activiteiten",
    8: "De pijn is heel erg, het is moeilijk om iets te doen",
    9: "De pijn is niet uit te staan, niet mogelijk om iets te doen",
    10: "De pijn kan niet erger, niets anders is van belang",
  };

  static Color getPainColor(int painScale) {
    if (painScale <= 3) {
      return Colors.green.shade400;
    } else if (painScale <= 7) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }
}