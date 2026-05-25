import 'package:flutter/material.dart';

class MonexColors {
  static const Color ink = Color(0xFF17201D);
  static const Color muted = Color(0xFF6C7772);
  static const Color background = Color(0xFFF7F3EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF146C63);
  static const Color primaryDark = Color(0xFF0D3F3A);
  static const Color accent = Color(0xFFE5A935);
  static const Color income = Color(0xFF1F9D73);
  static const Color expense = Color(0xFFE45D4F);
  static const Color info = Color(0xFF4A65D9);
  static const Color line = Color(0xFFE4EAE6);
  static const Color darkInk = Color(0xFFF3FBF8);
  static const Color darkMuted = Color(0xFF91A8A0);
  static const Color darkBackground = Color(0xFF061B18);
  static const Color darkSurface = Color(0xFF102A26);
  static const Color darkLine = Color(0xFF24433E);
}

class MonexTheme {
  static const double radius = 18;

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [MonexColors.primaryDark, MonexColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: MonexColors.ink.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static BoxDecoration cardDecoration({
    Color color = MonexColors.surface,
    double radius = MonexTheme.radius,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: softShadow,
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MonexColors.primary,
      brightness: Brightness.light,
      primary: MonexColors.primary,
      secondary: MonexColors.accent,
      surface: MonexColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MonexColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: MonexColors.background,
        foregroundColor: MonexColors.ink,
        titleTextStyle: TextStyle(
          color: MonexColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MonexColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: MonexColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MonexColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MonexColors.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: MonexColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: MonexColors.primary),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: MonexColors.ink,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: MonexColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: MonexColors.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: MonexColors.ink),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MonexColors.primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF4FD0B9),
      secondary: MonexColors.accent,
      surface: MonexColors.darkSurface,
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MonexColors.darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: MonexColors.darkBackground,
        foregroundColor: MonexColors.darkInk,
        titleTextStyle: TextStyle(
          color: MonexColors.darkInk,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MonexColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: MonexColors.darkMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MonexColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4FD0B9), width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: MonexColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF4FD0B9)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: MonexColors.darkInk,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: MonexColors.darkInk,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: MonexColors.darkInk,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: MonexColors.darkInk),
      ),
    );
  }
}
