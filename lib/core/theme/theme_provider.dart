import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. StateNotifier to manage ThemeMode
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  // Load saved theme
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);
    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light; // Default to Light, ignoring system
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    
    // Instant System Bar Update for "Snappy" feel
    final isDark = mode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8FAFC),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_key, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_key, 'dark');
    } else {
      await prefs.remove(_key); 
    }
  }
}

// 2. Global Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
