import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Headings
  static TextStyle h1 = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.3,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.3,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.3,
  );

  // Paragraph
  static TextStyle mainText = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.3,
  );

  static TextStyle secondaryText = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.3,
  );

  static TextStyle smallText = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
  );

  // UI Elements
  static TextStyle tabbar = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
  );

  static TextStyle buttonMain = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
  );

  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
  );
}