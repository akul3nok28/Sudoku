import 'package:flutter/material.dart';

class AppColors {
  static const peachLight = Color(0xFFFFE5D9);
  static const peachMedium = Color(0xFFFFD1BC);
  static const peachDark = Color(0xFFF4B266);
  static const peachAccent = Color(0xFFFF9E7D);
  static const background = Colors.white;
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF757575);
  static const grayLight = Color(0xFFF5F5F5);
  static const grayMedium = Color(0xFFE0E0E0);
  
  static const easyGreen = Color(0xFF81C784);
  static const mediumOrange = Color(0xFFFFB74D);
  static const hardRed = Color(0xFFE57373);
}

enum Difficulty {
  easy(38),
  medium(30),
  hard(24);

  final int clues;
  const Difficulty(this.clues);
}
