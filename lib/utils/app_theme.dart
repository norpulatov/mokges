// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9B95FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43E97B);
  static const Color warning = Color(0xFFFFB347);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkCardLight = Color(0xFF252538);
  static const Color darkText = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF9898B0);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B8A);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondary,
      tertiary: accent,
      background: darkBg,
      surface: darkCard,
      onPrimary: Colors.white,
      onBackground: darkText,
      onSurface: darkText,
    ),
    scaffoldBackgroundColor: darkBg,
    cardColor: darkCard,
    textTheme: _buildTextTheme(darkText, darkTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        color: darkText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: darkText),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkCard,
      indicatorColor: primaryColor.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
      hintStyle: const TextStyle(color: darkTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCardLight,
      labelStyle: const TextStyle(color: darkText),
      selectedColor: primaryColor,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondary,
      tertiary: accent,
      background: lightBg,
      surface: lightCard,
      onPrimary: Colors.white,
      onBackground: lightText,
      onSurface: lightText,
    ),
    scaffoldBackgroundColor: lightBg,
    cardColor: lightCard,
    textTheme: _buildTextTheme(lightText, lightTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        color: lightText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: lightText),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightCard,
      indicatorColor: primaryColor.withOpacity(0.15),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEEEEFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
          color: primary, fontSize: 32, fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.poppins(
          color: primary, fontSize: 28, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.poppins(
          color: primary, fontSize: 24, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.poppins(
          color: primary, fontSize: 22, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(
          color: primary, fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(
          color: primary, fontSize: 16, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(
          color: primary, fontSize: 15, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(
          color: primary, fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall:
          GoogleFonts.poppins(color: secondary, fontSize: 13),
      bodyLarge: GoogleFonts.poppins(color: primary, fontSize: 15),
      bodyMedium: GoogleFonts.poppins(color: primary, fontSize: 14),
      bodySmall:
          GoogleFonts.poppins(color: secondary, fontSize: 12),
      labelLarge: GoogleFonts.poppins(
          color: primary, fontSize: 13, fontWeight: FontWeight.w500),
      labelSmall:
          GoogleFonts.poppins(color: secondary, fontSize: 11),
    );
  }

  // Gradient decorations
  static BoxDecoration get primaryGradient => BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF9B95FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration get greenGradient => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration get orangeGradient => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );
}

class AppColors {
  static const List<Color> habitColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43E97B),
    Color(0xFFFFB347),
    Color(0xFF38F9D7),
    Color(0xFFFC5C7D),
    Color(0xFF6A85B6),
    Color(0xFFF7971E),
  ];

  static Color fromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
