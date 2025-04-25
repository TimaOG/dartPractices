import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';

class ThemeManager {
  static const String _themeKey = 'isDark';

  static Future<bool> get isDarkMode async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> toggleTheme(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = await isDarkMode;

    await prefs.setBool(_themeKey, !isDark);
    _updateTheme(context);
  }

  static void _updateTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newTheme = isDark ? AppTheme.light() : AppTheme.dark();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Theme(
          data: newTheme,
          child: const HomeScreen(),
        ),
      ),
    );
  }
}