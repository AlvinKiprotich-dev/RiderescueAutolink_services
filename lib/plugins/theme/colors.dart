import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color background;
  final Color scaffoldBackground;
  final Color card;
  final Color text;
  final Color secondaryText;
  final Color border;
  final Color icon;
  final Color error;
  final Color inputFieldBg;
  final Color inputFieldBorder;
  final Color bottomNavBarBarrier;
  final Color dividerColor;
  final Color drawerColor;

  const AppColors({
    required this.primary,
    required this.background,
    required this.scaffoldBackground,
    required this.card,
    required this.text,
    required this.secondaryText,
    required this.border,
    required this.icon,
    required this.error,
    required this.inputFieldBg,
    required this.inputFieldBorder,
    required this.bottomNavBarBarrier,
    required this.dividerColor,
    required this.drawerColor,
  });

  // Factory method to get colors based on brightness
  static AppColors fromBrightness(Brightness brightness) {
    return brightness == Brightness.light ? light : dark;
  }

  // Light theme - Orange/Dark Gray Theme
  static const light = AppColors(
    primary: Color(0xFFEC8027), // Orange from TODO.md
    background: Color(0xFFFFFFFF), // White background
    scaffoldBackground: Color(0xFFFFFFFF), // White scaffold
    card: Color(0xFFFFFFFF), // White
    text: Color(0xFF282828), // Dark gray from TODO.md
    secondaryText: Color(0xFF6B7280), // Medium gray
    border: Color.fromARGB(6, 142, 142, 141), // Orange border
    icon: Color(0xFF282828), // Dark gray icon
    error: Color(0xFFEF4444), // Red for errors
    inputFieldBg: Color(0xFFFFF8F3), // Very light orange
    inputFieldBorder: Color(0xFFEC8027), // Orange border
    bottomNavBarBarrier: Color.fromARGB(80, 0, 0, 0), // Semi-transparent
    dividerColor: Color(0xFFEC8027), // Orange divider
    drawerColor: Color(0xFFFFF8F3), // Very light orange
  );

  // Dark theme - Orange/Dark Gray Accent
  static const dark = AppColors(
    primary: Color(0xFFEC8027), // Orange from TODO.md
    background: Color(0xFF282828), // Dark gray from TODO.md
    scaffoldBackground: Color(0xFF282828), // Dark gray scaffold
    card: Color(0xFF282828), // Dark gray card
    text: Color(0xFFFFFFFF), // White for contrast
    secondaryText: Color(0xFFB0BEC5), // Light gray-blue
    border: Color.fromARGB(95, 79, 78, 78), // Orange border
    icon: Color(0xFFEC8027), // Orange icon
    error: Color(0xFFF87171), // Light red for errors
    inputFieldBg: Color(0xFF374151), // Dark gray
    inputFieldBorder: Color(0xFFEC8027), // Orange border
    bottomNavBarBarrier: Color.fromARGB(166, 0, 0, 0), // Semi-transparent dark gray
    dividerColor: Color(0xFFEC8027), // Orange divider
    drawerColor: Color(0xFF1F1F1F), // Darker gray for drawer
  );
}
