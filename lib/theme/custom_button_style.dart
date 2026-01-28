// ignore_for_file: deprecated_member_use

import 'package:Rival/core/app_export.dart';
import 'package:flutter/material.dart';

/// A class that offers pre-defined button styles for customizing button appearance.
class CustomButtonStyles {
  // Filled button style
  static ButtonStyle get fillOnErrorContainer => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onErrorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: Size.fromHeight(56),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      );
  static ButtonStyle get fillOnPrimary => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: Size.fromHeight(56),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      );
  static ButtonStyle get fillPrimary => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: Size.fromHeight(56),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      );
  // text button style
  static ButtonStyle get none => ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        elevation: MaterialStateProperty.all<double>(0),
      );

  static ButtonStyle get primaryborderstyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: appTheme.buttonColor),
      borderRadius: BorderRadius.circular(12),
    ),
    minimumSize: Size.fromHeight(56),
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  );
}
