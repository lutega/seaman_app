import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SrColors.primary,
          primary: SrColors.primary,
          onPrimary: SrColors.white,
          secondary: SrColors.teal,
          surface: SrColors.white,
          error: SrColors.danger,
        ),
        scaffoldBackgroundColor: SrColors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: SrColors.white,
          foregroundColor: SrColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: SrColors.textPrimary,
          ),
          shadowColor: SrColors.border,
          scrolledUnderElevation: 0.5,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: SrColors.white,
          selectedItemColor: SrColors.primary,
          unselectedItemColor: SrColors.textMuted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SrColors.primary,
            foregroundColor: SrColors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: SrColors.primary,
            side: const BorderSide(color: SrColors.primary),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SrColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SrRadius.sm),
            borderSide: const BorderSide(color: SrColors.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SrRadius.sm),
            borderSide: const BorderSide(color: SrColors.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SrRadius.sm),
            borderSide: const BorderSide(color: SrColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SrRadius.sm),
            borderSide: const BorderSide(color: SrColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SrRadius.sm),
            borderSide: const BorderSide(color: SrColors.danger, width: 1.5),
          ),
          labelStyle: const TextStyle(color: SrColors.textMuted, fontSize: 14),
          hintStyle: const TextStyle(color: SrColors.textMuted, fontSize: 14),
          errorStyle: const TextStyle(color: SrColors.danger, fontSize: 12),
        ),
        cardTheme: CardThemeData(
          color: SrColors.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SrRadius.md),
            side: const BorderSide(color: SrColors.border, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: SrColors.border,
          thickness: 0.5,
          space: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: SrColors.cardBg,
          selectedColor: SrColors.primary,
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SrRadius.full),
            side: const BorderSide(color: SrColors.border, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SrSpacing.sm),
        ),
      );
}
