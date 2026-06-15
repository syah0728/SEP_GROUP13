// lib/utils/app_colors.dart
// This file stores all the colors used in the app.
// By keeping colors here, we make sure the whole app looks consistent.
// If we want to change a color, we only change it in ONE place!

import 'package:flutter/material.dart';

class AppColors {
  // Adab staff theme: orange header, buttons, highlights
  static const Color primary = Color(0xFFE85D04);

  // Student theme: purple header, buttons, highlights
  static const Color studentPrimary = Color(0xFFAB43FE);

  // Lighter orange - used for selected sidebar item background
  static const Color primaryLight = Color(0xFFFFE0CC);

  // Dark blue/black - used for text
  static const Color textDark = Color(0xFF1A1A2E);

  // Grey - used for secondary text (like matric number, date)
  static const Color textGrey = Color(0xFF6B7280);

  // Green - used for Approve button and success messages
  static const Color success = Color(0xFF16A34A);

  // Red - used for Reject button and rejected status
  static const Color danger = Color(0xFFDC2626);

  // Yellow/Amber - used for Pending status
  static const Color warning = Color(0xFFD97706);

  // Light grey - used for page background
  static const Color background = Color(0xFFF3F4F6);

  // White - used for cards
  static const Color white = Color(0xFFFFFFFF);

  // Border color for input fields
  static const Color border = Color(0xFFD1D5DB);
}
