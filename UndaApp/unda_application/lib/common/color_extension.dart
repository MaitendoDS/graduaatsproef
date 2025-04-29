import 'package:flutter/material.dart';

class TColor{
  static Color get primCol1 => const Color(0xff92A3FD);
  static Color get primCol2 => const Color(0xff9DCEFF);

  static Color get secCol1 => const Color(0xffC58BF2);
  static Color get secoCol2 => const Color(0xffEEA4CE);

  static Set<Color> get primaryG => {primCol1, primCol2};
  static Set<Color> get secondaryG => {secCol1, secoCol2};

  static Color get black => const Color(0xff1D1617);
  static Color get white => Colors.white;
  static Color get gray => const Color(0xff786F72);

}