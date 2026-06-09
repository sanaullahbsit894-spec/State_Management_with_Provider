import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color sage = Color(0xFF9CB080);
  static const Color forest = Color(0xFF618764);
  static const Color deep = Color(0xFF2B5748);
  static const Color dark = Color(0xFF273338);

  static const Color surface = Color(0xFF1E2A2F);
  static const Color cardBg = Color(0xFF2E3D42);
  static const Color textPrimary = Color(0xFFF0F4EF);
  static const Color textSecondary = Color(0xFFB0C4B1);
  static const Color accent = Color(0xFF9CB080);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: dark,
    primaryColor: deep,
    colorScheme: const ColorScheme.dark(
      primary: sage,
      secondary: forest,
      surface: cardBg,
      onPrimary: dark,
      onSecondary: textPrimary,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: dark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: sage),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: forest,
      foregroundColor: textPrimary,
      elevation: 6,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      labelLarge: TextStyle(color: dark, fontWeight: FontWeight.w600),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: deep,
      selectedColor: sage,
      labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: deep, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: sage, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textSecondary),
    ),
  );
}
