import 'package:customer/themes/app_them_data.dart';
import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme ? AppThemeData.surfaceDark : AppThemeData.surface,
      primaryColor: isDarkTheme ? AppThemeData.primary300 : AppThemeData.primary300,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDarkTheme ? AppThemeData.grey700 : AppThemeData.grey300,
        dialTextStyle: TextStyle(fontWeight: FontWeight.bold, color: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800),
        dialTextColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800,
        hourMinuteTextColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800,
        dayPeriodTextColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800,
      ),
    );
  }
}
