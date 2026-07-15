import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Theme provider for light/dark mode toggle.
/// Singleton pattern for global access.
class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider instance = ThemeProvider._();
  ThemeProvider._();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Get current background color based on theme.
  Color get backgroundColor =>
      isDark ? AppColors.darkBackground : AppColors.background;

  /// Get current surface color based on theme.
  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.surface;

  /// Get current text primary color based on theme.
  Color get textPrimaryColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  /// Get current text secondary color based on theme.
  Color get textSecondaryColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  /// Get current divider color based on theme.
  Color get dividerColor =>
      isDark ? AppColors.darkDivider : AppColors.divider;
}
