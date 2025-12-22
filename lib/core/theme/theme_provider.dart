import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_prefs_cache.dart';

// Optimized ThemeNotifier for INSTANT theme switching
// Uses unified AppPrefsCache (pre-initialized in main.dart)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_getInitialTheme()) {
    _updateSystemUI(state == ThemeMode.dark);
  }

  // Get theme SYNCHRONOUSLY from cached prefs (instant, no flicker)
  static ThemeMode _getInitialTheme() {
    final savedTheme = AppPrefsCache.theme;
    if (savedTheme == 'dark') return ThemeMode.dark;
    if (savedTheme == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  // Toggle theme (simpler API for switch)
  void toggle() {
    final isDark = state == ThemeMode.dark;
    setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  // Set theme - INSTANT state update, background save
  void setTheme(ThemeMode mode) {
    // 1. Update state IMMEDIATELY (no await)
    state = mode;
    
    // 2. Update system UI IMMEDIATELY
    final isDark = mode == ThemeMode.dark;
    _updateSystemUI(isDark);
    
    // 3. Save to preferences in BACKGROUND (fire-and-forget, uses cached prefs)
    _saveTheme(mode);
  }
  
  // Update system chrome instantly
  void _updateSystemUI(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  // Save to prefs in background (uses cached instance - no async getInstance())
  void _saveTheme(ThemeMode mode) {
    final value = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.system ? 'system' : 'light');
    AppPrefsCache.theme = value;
  }
}

// Global Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

