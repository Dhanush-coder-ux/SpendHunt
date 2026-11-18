import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme textTheme({required bool isDark}) {
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextTheme(
      // Large financial balance (30-36px)
      displayLarge: GoogleFonts.manrope(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: primaryColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: primaryColor,
        height: 1.2,
      ),

      // Screen headings (24-28px)
      headlineLarge: GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: primaryColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primaryColor,
        height: 1.25,
      ),

      // Section headings (17-20px)
      titleLarge: GoogleFonts.manrope(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primaryColor,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primaryColor,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),

      // Body text (13-15px)
      bodyLarge: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),

      // Supporting labels (11-12px)
      labelLarge: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.2,
      ),
    );
  }
}
