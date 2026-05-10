import 'package:flutter/material.dart';

final originalTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF1B365D), // Navy Blue
  scaffoldBackgroundColor: const Color(0xFFE5E7EB), // Light Gray
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1B365D),
    secondary: Color(0xFF1B365D),
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFE5E7EB),
    foregroundColor: Color(0xFF1B365D),
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1B365D),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
  useMaterial3: true,
);
