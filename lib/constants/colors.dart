import 'package:flutter/material.dart';

/// App color constants
/// Centralized color definitions for consistent theming across the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Blue 700
  static const Color primaryLight = Color(0xFF42A5F5); // Blue 400
  static const Color primaryDark = Color(0xFF1565C0); // Blue 600
  static const Color primaryBackground = Color(0xFFE3F2FD); // Blue 50

  // App Bar Colors
  static const Color appBarBackground = Color(0xFF1976D2); // Blue 700
  static const Color appBarForeground = Colors.white;

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF5F5F5); // Grey 100
  static const Color cardBackground = Colors.white;
  static const Color gradientStart = Color(0xFFE3F2FD); // Blue 50
  static const Color gradientMiddle = Colors.white;
  static const Color gradientEnd = Color(0xFFFAFAFA); // Grey 50

  // Action Card Colors
  static const Color convertCard = Colors.blue;
  static const Color calculateCard = Colors.green;
  static const Color historyCard = Colors.orange;
  static const Color settingsCard = Colors.purple;

  // Feature Item Colors
  static const Color fastConversion = Colors.red;
  static const Color multipleUnits = Colors.teal;
  static const Color beautifulUI = Colors.pink;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Grey 800
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textWhite = Colors.white;
  static const Color textWhiteOpacity = Color(
    0xE6FFFFFF,
  ); // White with 90% opacity

  // Border and Divider Colors
  static const Color divider = Color(0xFFBDBDBD); // Grey 400
  static const Color border = Color(0xFFE0E0E0); // Grey 300

  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
