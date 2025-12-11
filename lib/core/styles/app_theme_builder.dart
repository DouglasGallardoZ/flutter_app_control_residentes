import 'package:flutter/material.dart';
import '../config/brand_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeBuilder {
  static ThemeData build(BrandTheme bt) {
    final primary = Color(bt.primary);
    final secondary = Color(bt.secondary);
    final error = Color(bt.error);

    final base = bt.dark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      colorScheme: (bt.dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: primary,
        secondary: secondary,
        error: error,
      ),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      snackBarTheme: SnackBarThemeData(backgroundColor: secondary, contentTextStyle: const TextStyle(color: Colors.white)),
    );
  }
}
