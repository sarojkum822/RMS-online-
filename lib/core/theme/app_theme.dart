import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue (iOS Style)
  static const Color primaryContainer = Color(0xFFDBEAFE); // Blue 100
  
  // Minimal Palette
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color darkBackground = Color(0xFF000000);  // True Black
  
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1C1C1E);     // iOS System Gray 6
  
  static const Color background = Color(0xFFF5F7FA); // Legacy compatibility

  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color darkTextPrimary = Color(0xFFF8FAFC);  // Slate 50
  
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color darkTextSecondary = Color(0xFF94A3B8);  // Slate 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF6366F1), // Indigo Accent
        onSecondary: Colors.white,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        outline: Color(0xFFE2E8F0), // Slate 200
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground, // Match Scaffold for minimal look
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      iconTheme: const IconThemeData(color: lightTextPrimary),
      dividerColor: const Color(0xFFE2E8F0),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF818CF8), // Lighter Indigo
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: Color(0xFFFCA5A5), // Red 300 (Salmon) - Readable on dark
        onError: Colors.white,
        outline: Color(0xFF2C2C2E),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary),
       dividerColor: const Color(0xFF2C2C2E),
    );
  }
}
