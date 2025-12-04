import 'package:flutter/material.dart';

/// Neobrutalist design constants for the Daily Tracker app
class NeoBrutalistTheme {
  // Border styling
  static const double borderWidth = 2.5;
  static const double thinBorderWidth = 1.5;
  static const Color borderColor = Colors.black;

  // Colors
  static const Color backgroundColor = Colors.white;
  static const Color primaryColor = Colors.black;
  static const Color completedColor = Color(0xFF00C853); // Pure green
  static const Color chartColor = Color(0xFF2979FF); // Pure blue
  static const Color accentColor = Color(0xFFFFD600); // Pure yellow

  // Grid cell dimensions (GitHub-style)
  static const double cellSize = 16.0;
  static const double cellSpacing = 3.0;

  // Typography
  static const String fontFamily = 'Roboto';

  static const TextStyle headingStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: primaryColor,
    letterSpacing: 0,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: primaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: primaryColor,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: primaryColor,
  );

  static const TextStyle smallStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: primaryColor,
  );

  // Box decoration
  static BoxDecoration get boxDecoration => BoxDecoration(
    color: backgroundColor,
    border: Border.all(color: borderColor, width: borderWidth),
  );

  static BoxDecoration get thinBoxDecoration => BoxDecoration(
    color: backgroundColor,
    border: Border.all(color: borderColor, width: thinBorderWidth),
  );

  static BoxDecoration completedCellDecoration(bool isCompleted) =>
      BoxDecoration(
        color: isCompleted ? completedColor : backgroundColor,
        border: Border.all(color: borderColor, width: thinBorderWidth),
      );

  // Button style
  static ButtonStyle get buttonStyleFlat => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(backgroundColor),
    foregroundColor: WidgetStateProperty.all(primaryColor),
    shape: WidgetStateProperty.all(
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
    ),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textStyle: WidgetStateProperty.all(buttonStyle),
    elevation: WidgetStateProperty.all(0),
  );

  // Input decoration
  static InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: bodyStyle.copyWith(color: Colors.black45),
    filled: true,
    fillColor: backgroundColor,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: borderColor, width: 3),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );

  // Theme data for MaterialApp
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: backgroundColor,
      surface: backgroundColor,
      onSurface: primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineMedium: headingStyle,
      titleMedium: titleStyle,
      bodyMedium: bodyStyle,
      labelMedium: buttonStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyleFlat),
    outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyleFlat),
  );
}
