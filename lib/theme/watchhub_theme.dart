
import 'package:flutter/material.dart';

class WatchHubColors {
  // Main purple colours
  static const Color royalPurple = Color(0xFF4C1D95);
  static const Color electricPurple = Color(0xFF7C3AED);
  static const Color lavender = Color(0xFFC084FC);

  // Background colours
  static const Color lightBackground = Color(0xFFF8F5FF);
  static const Color darkBackground = Color(0xFF171126);

  // Supporting colours
  static const Color white = Color(0xFFFFFFFF);
  static const Color softLavender = Color(0xFFF5F3FF);
  static const Color darkPlum = Color(0xFF241638);
}

class WatchHubTheme {
  // Main purple gradient for banners and featured sections
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      WatchHubColors.royalPurple,
      WatchHubColors.electricPurple,
      WatchHubColors.lavender,
    ],
  );

  // Darker gradient for important buttons
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      WatchHubColors.royalPurple,
      WatchHubColors.electricPurple,
    ],
  );

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: WatchHubColors.electricPurple,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: WatchHubColors.lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: WatchHubColors.royalPurple,
      foregroundColor: WatchHubColors.white,
      elevation: 0,
      centerTitle: false,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WatchHubColors.electricPurple,
        foregroundColor: WatchHubColors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WatchHubColors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDDD6FE),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDDD6FE),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: WatchHubColors.electricPurple,
          width: 2,
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: WatchHubColors.electricPurple,
      unselectedItemColor: Color(0xFF81758F),
      backgroundColor: WatchHubColors.white,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: WatchHubColors.electricPurple,
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: WatchHubColors.darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: WatchHubColors.darkPlum,
      foregroundColor: WatchHubColors.white,
      elevation: 0,
    ),

    cardColor: WatchHubColors.darkPlum,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WatchHubColors.electricPurple,
        foregroundColor: WatchHubColors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WatchHubColors.darkPlum,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: WatchHubColors.lavender,
          width: 2,
        ),
      ),
    ),
  );
}
