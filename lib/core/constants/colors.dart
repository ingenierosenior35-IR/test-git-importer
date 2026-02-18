import 'package:flutter/material.dart';

/// Rival App Design System Colors
/// Black + Neon Yellow theme with subtle greys
class AppColors {
  // Primary Colors
  static const Color kPrimary = Color(0xFFDDEE5E); // Neon Yellow-Green #DDEE5E
  static const Color kYellowAccent = Color(0xFFDDEE5E); // Alias for compatibility
  
  // Background Colors
  static const Color kBlack = Color(0xFF000000);
  static const Color kDarkBackground = Color(0xFF192126);
  static const Color kDarkCard = Color(0xFF252D32);
  static const Color kDarkSurface = Color(0xFF30373B);
  
  // Text Colors
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kGrey = Color(0xFF888888);
  static const Color kGreyLight = Color(0xFFA3A3B5);
  static const Color kGreyDark = Color(0xFF666666);
  
  // Status Colors
  static const Color kRed = Color(0xFFD65656);
  static const Color kGreen = Color(0xFF34C759);
  static const Color kOrange = Color(0xFFEFA83C);
  
  // Semantic Colors
  static const Color kSuccess = kGreen;
  static const Color kError = kRed;
  static const Color kWarning = kOrange;
  
  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
