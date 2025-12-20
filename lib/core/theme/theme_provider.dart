import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Optimized ThemeNotifier for instant theme switching
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  // Load saved theme (runs once at startup)
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_key);
      if (savedTheme == 'dark') {
        state = ThemeMode.dark;
        _updateSystemUI(true);
      } else {
        state = ThemeMode.light;
        _updateSystemUI(false);
      }
    } catch (e) {
      // If SharedPreferences fails, stay on light mode
      debugPrint('Theme load error: $e');
    }
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
    
    // 3. Save to preferences in BACKGROUND (fire-and-forget)
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

  // Save to prefs in background (don't await)
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Theme save error: $e');
    }
  }
}

// Global Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
