import 'package:flutter/material.dart';

import '../utils/constants.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: PictConstants.PictPrimary,
      brightness: Brightness.dark,
      background: PictConstants.PictBlack,
      surface: PictConstants.PictSurface,
      secondary: PictConstants.PictAccent,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'DmSans',
    );

    return base.copyWith(
      scaffoldBackgroundColor: PictConstants.PictBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: PictConstants.PictSecondary,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: PictConstants.PictSecondary,
        displayColor: PictConstants.PictSecondary,
      ),
      cardTheme: CardTheme(
        color: PictConstants.PictSurface.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: PictConstants.PictSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: PictConstants.PictSecondary,
        ),
        contentTextStyle: const TextStyle(
          color: PictConstants.PictGrey,
          fontSize: 16,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PictConstants.PictSurfaceVariant.withOpacity(0.9),
        hintStyle: const TextStyle(color: PictConstants.PictGrey),
        labelStyle: const TextStyle(color: PictConstants.PictGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: PictConstants.PictAccent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PictConstants.PictPrimary,
          foregroundColor: PictConstants.PictSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ).merge(
          ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.pressed)
                  ? PictConstants.PictAccent.withOpacity(0.2)
                  : null,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PictConstants.PictAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: PictConstants.PictAccent),
          foregroundColor: PictConstants.PictAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
