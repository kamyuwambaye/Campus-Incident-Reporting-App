import 'package:flutter/material.dart';

/// Central colour palette, tuned to match the purple campus-reporting design.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C4CF2);
  static const Color primaryDark = Color(0xFF4F34D4);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color background = Color(0xFFF6F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E6F0);
  static const Color textPrimary = Color(0xFF1C1B2E);
  static const Color textSecondary = Color(0xFF6F6E80);
  static const Color textHint = Color(0xFFA0A0B0);

  static const Color submitted = Color(0xFFE08A00);
  static const Color submittedBg = Color(0xFFFFF3E0);
  static const Color inProgress = Color(0xFF2F6BFF);
  static const Color inProgressBg = Color(0xFFE8EFFF);
  static const Color resolved = Color(0xFF1FA055);
  static const Color resolvedBg = Color(0xFFE3F6EA);
  static const Color danger = Color(0xFFE5484D);
  static const Color dangerBg = Color(0xFFFDE8E9);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color),
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: AppColors.border,
    );
  }
}
