import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED)),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    );
  }
}
