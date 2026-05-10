import 'package:flutter/material.dart';

final hunterTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF39FF14), // Neon Green
  scaffoldBackgroundColor: const Color(0xFF121212), // Jet Black
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF39FF14),
    secondary: Color(0xFF39FF14),
    surface: Color(0xFF1E1E1E),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Color(0xFF39FF14),
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF39FF14), width: 1), // Green border as in mockup
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF39FF14),
      side: const BorderSide(color: Color(0xFF39FF14), width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
  useMaterial3: true,
);
