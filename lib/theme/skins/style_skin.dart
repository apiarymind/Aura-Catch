import 'package:flutter/material.dart';

final styleTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFE5A9A9), // Soft Rose Gold/Pink
  scaffoldBackgroundColor: const Color(0xFFFFF0F0), // Very light soft pink
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFE5A9A9),
    secondary: Color(0xFFD68C8C),
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFF0F0),
    foregroundColor: Color(0xFFD68C8C),
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFFFF5F5), // Slightly tinted card
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE5A9A9),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
  useMaterial3: true,
);
