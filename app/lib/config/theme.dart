import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 主色调 - 金贝贝的黄色
  static const Color primaryColor = Color(0xFFFFC107); // 琥珀色
  static const Color secondaryColor = Color(0xFFFF9800); // 橙色
  
  // 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'MiSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      displayMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      displaySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      headlineLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500),
    ),
  );
  
  // 深色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'MiSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      displayMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      displaySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      headlineLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500),
    ),
  );
}
