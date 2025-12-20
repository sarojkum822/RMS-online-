import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue (iOS Style)
  static const Color primaryContainer = Color(0xFFDBEAFE); // Blue 100
  
  // Minimal Palette
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure White as requested for "white ui"
  static const Color darkBackground = Color(0xFF000000);  // True Black remains for high contrast
  
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1C1C1E);     // iOS System Gray 6
  
  static const Color background = Color(0xFFF5F7FA); // Legacy compatibility

  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color darkTextPrimary = Color(0xFFF8FAFC);  // Slate 50
  
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color darkTextSecondary = Color(0xFF94A3B8);  // Slate 400

  // Glass Theme
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF2563EB).withValues(alpha: 0.08), // Subtle Blue shadow
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static final ThemeData lightTheme = ThemeData(
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
    
    // M3 Typography
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),

    // M3 Component Overrides
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground, 
      surfaceTintColor: Colors.transparent, // Avoid M3 scroll tint if desired
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
    
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE2E8F0)), // Outline Variant
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      )
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    iconTheme: const IconThemeData(color: lightTextPrimary),
    dividerColor: const Color(0xFFE2E8F0),
    dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
  );

  static final ThemeData darkTheme = ThemeData(
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
      surfaceTintColor: Colors.transparent,
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
    
    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C1E), // Slightly lighter than background
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF2C2C2E)),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      )
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    iconTheme: const IconThemeData(color: darkTextPrimary),
    dividerColor: const Color(0xFF2C2C2E),
    dividerTheme: const DividerThemeData(color: Color(0xFF2C2C2E), thickness: 1),
  );
}
