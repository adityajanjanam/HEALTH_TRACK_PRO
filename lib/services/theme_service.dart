// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isHighContrast = false;
  final SharedPreferences _prefs;

  ThemeService(this._prefs) {
    _loadThemePreferences();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isHighContrast => _isHighContrast;

  void _loadThemePreferences() {
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _isHighContrast = _prefs.getBool('isHighContrast') ?? false;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void toggleContrast() {
    _isHighContrast = !_isHighContrast;
    _prefs.setBool('isHighContrast', _isHighContrast);
    notifyListeners();
  }

  ThemeData get currentTheme {
    if (_isDarkMode) {
      return _isHighContrast ? _darkHighContrastTheme : _darkTheme;
    }
    return _isHighContrast ? _lightHighContrastTheme : _lightTheme;
  }

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1976D2),      // Medical blue
      secondary: const Color(0xFF00ACC1),     // Cyan for medical accents
      tertiary: const Color(0xFF4CAF50),      // Success green for confirmations
      surface: Colors.white,
      background: const Color(0xFFF5F9FF),    // Light blue tinted background
      error: const Color(0xFFD32F2F),         // Error red
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1F2937),     // Dark gray for text
      onBackground: const Color(0xFF1F2937),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF374151),
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF4B5563),
        fontSize: 14,
        letterSpacing: 0.25,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1976D2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF90CAF9),       // Light blue for dark theme
      secondary: const Color(0xFF80DEEA),      // Light cyan for accents
      tertiary: const Color(0xFF81C784),      // Light green for success
      surface: const Color(0xFF1F2937),        // Dark surface
      background: const Color(0xFF111827),     // Darker background
      error: const Color(0xFFEF5350),         // Light red for errors
      onPrimary: const Color(0xFF1F2937),
      onSecondary: const Color(0xFF1F2937),
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1F2937),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFFF9FAFB),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
      titleMedium: TextStyle(
        color: Color(0xFFF9FAFB),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFFE5E7EB),
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFD1D5DB),
        fontSize: 14,
        letterSpacing: 0.25,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF374151),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4B5563)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4B5563)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF1F2937),
        backgroundColor: const Color(0xFF90CAF9),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final _lightHighContrastTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0052CC),
      secondary: Color(0xFF006644),
      surface: Colors.white,
      background: Colors.white,
      error: Color(0xFFDE350B),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF172B4D),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF172B4D),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF172B4D),
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF172B4D),
        fontSize: 14,
      ),
    ),
  );

  static final _darkHighContrastTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4C9AFF),
      secondary: Color(0xFF79F2C0),
      surface: Color(0xFF1B2638),
      background: Color(0xFF0D1424),
      error: Color(0xFFFF5630),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1B2638),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFFF7F8F9),
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFF7F8F9),
        fontSize: 14,
      ),
    ),
  );
} 