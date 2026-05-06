import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLg => GoogleFonts.manrope(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get displayMd => GoogleFonts.manrope(
        fontSize: 24,
        height: 1.33,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get titleLg => GoogleFonts.manrope(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMd => GoogleFonts.manrope(
        fontSize: 18,
        height: 1.44,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLg => GoogleFonts.manrope(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyMd => GoogleFonts.manrope(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 15,
        height: 1.33,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
