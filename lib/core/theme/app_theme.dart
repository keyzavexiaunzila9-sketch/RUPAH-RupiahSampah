import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RupahColors {
  static const green = Color(0xFF2E8B57);
  static const blue = Color(0xFF4FA3A5);
  static const white = Color(0xFFFFFFFF);
  static const dark = Color(0xFF1B2433);
  static const text = Color(0xFF27313F);
  static const muted = Color(0xFF6D7784);
  static const background = Color(0xFFF7F9FC);
  static const softGreen = Color(0xFFE3F7ED);
  static const softBlue = Color(0xFFE0F7F8);
  static const border = Color(0xFFE4E8ED);
  static const danger = Color(0xFFD9534F);
  static const warning = Color(0xFFE6A23C);
}

class RupahTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor:
          RupahColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RupahColors.green,
        primary: RupahColors.green,
        secondary: RupahColors.blue,
        surface: RupahColors.white,
      ),
    );

    return base.copyWith(
      textTheme:
          GoogleFonts.dmSansTextTheme(
        base.textTheme,
      ).apply(
        bodyColor: RupahColors.text,
        displayColor: RupahColors.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: RupahColors.white,
        foregroundColor: RupahColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: RupahColors.text,
        ),
      ),
      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: RupahColors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: RupahColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: RupahColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: RupahColors.green,
            width: 1.4,
          ),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: RupahColors.muted,
          fontSize: 14,
        ),
      ),
    );
  }

  static TextStyle heading({
    double size = 20,
    Color color = RupahColors.text,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle body({
    double size = 14,
    Color color = RupahColors.text,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}