import 'package:flutter/material.dart';

class AppColors {
  // Verdes
  static const Color primaryGreen = Color(0xFF2A6A4E);
  static const Color lightGreen = Color(0xFFE9F5EB);
  static const Color iconGreen = Color(0xFF4CAF50);

  // Vermelhos
  static const Color primaryRed = Color(0xFFC62828);
  static const Color lightRed = Color(0xFFFCE8E8);

  // Neutros
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  // Textos
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF757575);

  // Bordas e Divisores
  static const Color border = Color(0xFFE0E0E0);

  static Color? get textLight => const Color.fromARGB(255, 244, 244, 244);

  static Color? get textDark => const Color.fromARGB(255, 0, 0, 0);

  static Color get primaryBlue => const Color.fromARGB(255, 29, 40, 251);
}
