import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF7c7be6);
  static const Color primaryLight = Color(0xFF9290FF);
  static const Color primaryDark = Color(0xFF6E6DE0);

  // Background colors
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF0A0A0F);

  // Surface colors
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF15151F);

  // Text colors
  static const Color lightTextPrimary = Colors.black;
  static const Color lightTextSecondary = Color.fromARGB(255, 97, 96, 96);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  // Error colors
  static const Color error = Colors.red;
  static const Color success = Colors.green;

  // Card colors
  static const Color lightCardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF181818);

  // Input field colors
  static const Color inputBackground = Color(0xFFF5F5F5);

  // Private constructor to prevent instantiation
  const AppColors._();
}
