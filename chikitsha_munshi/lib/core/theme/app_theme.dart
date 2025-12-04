import 'package:flutter/material.dart';
import './app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.primaryLight),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        textStyle: WidgetStatePropertyAll(TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        )),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: WidgetStatePropertyAll(2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.grayLight),
      displayMedium: TextStyle(color: AppColors.grayLight),
      displaySmall: TextStyle(color: AppColors.grayLight),
      headlineMedium: TextStyle(color: AppColors.grayLight),
      headlineSmall: TextStyle(color: AppColors.grayLight),
      titleLarge: TextStyle(color: AppColors.grayLight),
      titleMedium: TextStyle(color: AppColors.grayLight),
      titleSmall: TextStyle(color: AppColors.grayLight),
      bodyLarge: TextStyle(color: AppColors.grayLight),
      bodyMedium: TextStyle(color: AppColors.grayLight),
      bodySmall: TextStyle(color: AppColors.grayLight),
      labelLarge: TextStyle(color: AppColors.grayLight),
      labelMedium: TextStyle(color: AppColors.grayLight),
      labelSmall: TextStyle(color: AppColors.grayLight),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundLight,
      labelStyle: TextStyle(
        color: AppColors.headerLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppColors.grayLight,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.grayLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.grayLight,
        ),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      surface: AppColors.backgroundLight,
      onPrimary: Colors.white,
      secondary: AppColors.successLight,
      onSurface: AppColors.headerLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.headerLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.headerLight),
      titleTextStyle: TextStyle(
        color: AppColors.headerLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.primaryDark),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        textStyle: WidgetStatePropertyAll(TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        )),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: WidgetStatePropertyAll(2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.primaryDark, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.grayDark),
      displayMedium: TextStyle(color: AppColors.grayDark),
      displaySmall: TextStyle(color: AppColors.grayDark),
      headlineMedium: TextStyle(color: AppColors.grayDark),
      headlineSmall: TextStyle(color: AppColors.grayDark),
      titleLarge: TextStyle(color: AppColors.grayDark),
      titleMedium: TextStyle(color: AppColors.grayDark),
      titleSmall: TextStyle(color: AppColors.grayDark),
      bodyLarge: TextStyle(color: AppColors.grayDark),
      bodyMedium: TextStyle(color: AppColors.grayDark),
      bodySmall: TextStyle(color: AppColors.grayDark),
      labelLarge: TextStyle(color: AppColors.grayDark),
      labelMedium: TextStyle(color: AppColors.grayDark),
      labelSmall: TextStyle(color: AppColors.grayDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundDark,
      labelStyle: TextStyle(
        color: AppColors.headerDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppColors.grayDark,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.grayDark,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryDark,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.grayDark,
        ),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      surface: AppColors.backgroundDark,
      onPrimary: Colors.black,
      secondary: AppColors.successDark,
      onSurface: AppColors.headerDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.headerDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.headerDark),
      titleTextStyle: TextStyle(
        color: AppColors.headerDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
