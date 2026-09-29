import 'package:flutter/material.dart';

/// Colors recovered from web/pago-ok.html, which says they match
/// lib/theme/app_theme.dart — AppColors.
class AppColors {
  static const bg = Color(0xFFF3D7B7);
  static const textPrimary = Color(0xFF1F1F1F);
  static const textSecondary = Color(0xFF6C6C6C);
  static const surface = Color(0xE0FFFFFF);
  static const success = Color(0xFF2E7D32);
  static const brown = Color(0xFF8B5A2B);
  static const brownPressed = Color(0xFF74461F);
  static const teal = Color(0xFF5FADBB);
  static const olive = Color(0xFFD4D9A1);
  static const danger = Color(0xFFB3261E);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEB74461F),
      Color(0x8C5FADBB),
      Color(0xEB8B5A2B),
    ],
    stops: [0, 0.42, 1],
  );
}

class AppTheme {
  static const radius = 22.0;
  static const radiusSm = 16.0;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brown,
        primary: AppColors.brown,
        onPrimary: Colors.white,
        secondary: AppColors.teal,
        surface: Colors.white,
      ),
      fontFamily: 'MPLUSRounded1c',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'MPLUSRounded1c',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: AppColors.brown.withValues(alpha: 0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: AppColors.brown.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.brown, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brown.withValues(alpha: 0.35),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        indicatorColor: AppColors.olive,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}
