import 'package:flutter/material.dart';

class AppColors {
  static const background = Colors.white;
  static const peachLight = Color(0xFFFFF5EB);
  static const peachMedium = Color(0xFFFFDAB9);
  static const peachDark = Color(0xFFE69138); 
  static const peachCircle = Color(0xFFFFEBD6);
  
  static const textPrimary = Colors.black;
  static const textSecondary = Color(0xFF9E9E9E);
  static const iconGray = Color(0xFFBDBDBD);
  
  static const easyGreen = Color(0xFF2E7D32);
  static const mediumOrange = Color(0xFFE69138);
  static const hardRed = Color(0xFFC62828);
  
  static const gridHighlight = Color(0xFFF0F0F0);
  static const gridLines = Colors.black;
}

enum Difficulty {
  easy(38, 'лёгкі', AppColors.easyGreen),
  medium(30, 'сярэдні', AppColors.mediumOrange),
  hard(24, 'складаны', AppColors.hardRed);

  final int clues;
  final String label;
  final Color color;
  const Difficulty(this.clues, this.label, this.color);
}

class AppStrings {
  static const title = 'SUDOKU';
  static const newGame = 'новая гульня';
  static const exit = 'выхад';
}
