import 'package:flutter/material.dart';
import '../models/app_settings.dart';

/// Theme palette builder that supports multiple color schemes
class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color completed;
  final Color chart;
  final Color error;

  const AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.completed,
    required this.chart,
    required this.error,
  });
}

class AppTheme {
  static ThemeScheme _activeScheme = ThemeScheme.palette;

  static const Map<ThemeScheme, AppThemeColors> _schemes = {
    ThemeScheme.palette: AppThemeColors(
      primary: Color(0xFF1B1B1B),
      secondary: Color(0xFFE9204F),
      background: Color(0xFFF3F3F3),
      surface: Colors.white,
      completed: Color(0xFFE9204F),
      chart: Color(0xFFE9204F),
      error: Color(0xFFE9204F),
    ),
    ThemeScheme.classic: AppThemeColors(
      primary: Color(0xFF1A1A1A),
      secondary: Color(0xFF666666),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      completed: Color(0xFF34C759),
      chart: Color(0xFF007AFF),
      error: Color(0xFFFF3B30),
    ),
  };

  static void setScheme(ThemeScheme scheme) {
    _activeScheme = scheme;
  }

  static AppThemeColors get colors => _schemes[_activeScheme]!;

  static Color get primaryColor => colors.primary;
  static Color get secondaryColor => colors.secondary;
  static Color get backgroundColor => colors.background;
  static Color get surfaceColor => colors.surface;
  static Color get completedColor => colors.completed;
  static Color get chartColor => colors.chart;
  static Color get errorColor => colors.error;

  // Grid cell dimensions
  static const double cellSize = 18.0;
  static const double cellSpacing = 4.0;

  // Theme data factory for a specific scheme
  static ThemeData themeData(ThemeScheme scheme) {
    final c = _schemes[scheme]!;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: c.primary,
        secondary: c.secondary,
        surface: c.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: c.primary,
      ),
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: c.background,
        foregroundColor: c.primary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.background,
        indicatorColor: Colors.grey.shade200,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
            side: const BorderSide(color: Colors.black, width: 1.4),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.chart,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: c.primary,
        overlayColor: c.primary.withAlpha(30),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.completed;
          }
          return Colors.grey.shade300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
    );
  }

  // Cell decoration for completion grid
  static BoxDecoration completedCellDecoration(bool isCompleted) =>
      BoxDecoration(
        color: isCompleted ? colors.completed : Colors.white,
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: Colors.black54, width: 1.4),
        boxShadow: const [
          BoxShadow(offset: Offset(2, 2), blurRadius: 0, color: Colors.black12),
        ],
      );
}
