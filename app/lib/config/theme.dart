import 'package:flutter/material.dart';

/// 应用主题配置 - 金贝贝酷炫主题
class AppTheme {
  // 金贝贝专属配色 - 活力橙黄渐变
  static const Color primaryColor = Color(0xFFFFB347); // 温暖橙
  static const Color secondaryColor = Color(0xFFFFCC33); // 明亮黄
  static const Color accentColor = Color(0xFFFF6B6B); // 活力红
  static const Color deepPurple = Color(0xFF6C5CE7); // 深邃紫
  
  // 渐变色定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );
  
  static const LinearGradient vibrantGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A56), Color(0xFFFFCD75), Color(0xFFFFF59D)],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D3436), Color(0xFF1A1A2E)],
  );
  
  // 毛玻璃效果
  static BoxDecoration glassEffect({Color? color, double blur = 20}) {
    return BoxDecoration(
      color: color ?? const Color(0x40FFFFFF),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0x30FFFFFF),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'MiSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: const Color(0xFFFAFAFA),
      background: const Color(0xFFF8F9FA),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF2D3436),
      titleTextStyle: const TextStyle(
        fontFamily: 'MiSans',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3436),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF2D3436),
        size: 24,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 6,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 24),
      headlineLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 22),
      headlineMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 20),
      headlineSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal, fontSize: 14),
      bodySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal, fontSize: 12),
      labelLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 14),
      labelMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500, fontSize: 12),
      labelSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500, fontSize: 10),
    ),
  );
  
  // 深色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'MiSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: secondaryColor,
      secondary: primaryColor,
      tertiary: accentColor,
      surface: const Color(0xFF1A1A2E),
      background: const Color(0xFF0F0F1A),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontFamily: 'MiSans',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xFF1A1A2E),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 6,
      backgroundColor: secondaryColor,
      foregroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: const Color(0xFF1A1A2E),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
      displayMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
      displaySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
      headlineLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
      headlineMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      headlineSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      titleMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
      titleSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
      bodyLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal, fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal, fontSize: 14, color: Colors.white70),
      bodySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white60),
      labelLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
      labelMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white),
      labelSmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w500, fontSize: 10, color: Colors.white70),
    ),
  );
}
