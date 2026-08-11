import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF4A90D9);
  static const Color bgColor = Color(0xFF0D1117);
  static const Color surfaceColor = Color(0xFF161B22);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1A3A5C),
      secondary: Color(0xFF58A6FF),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF1B2D47),
      surface: surfaceColor,
      onSurface: Color(0xFFC9D1D9),
      surfaceContainerHighest: Color(0xFF21262D),
      error: Color(0xFFF85149),
      onError: Colors.white,
      outline: Color(0xFF30363D),
      outlineVariant: Color(0xFF21262D),
      shadow: Colors.black54,
    ),
    scaffoldBackgroundColor: bgColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: Color(0xFFC9D1D9),
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF8B949E),
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF30363D)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF8B949E)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF30363D),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF21262D),
      contentTextStyle: const TextStyle(color: Color(0xFFC9D1D9)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFC9D1D9),
      ),
      displayMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFC9D1D9),
      ),
      headlineLarge: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFC9D1D9),
      ),
      headlineMedium: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFC9D1D9),
      ),
      headlineSmall: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFC9D1D9),
      ),
      titleLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFC9D1D9),
      ),
      titleMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFC9D1D9),
      ),
      titleSmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8B949E),
      ),
      bodyLarge: TextStyle(
        fontSize: 16, color: Color(0xFFC9D1D9),
      ),
      bodyMedium: TextStyle(
        fontSize: 14, color: Color(0xFFC9D1D9),
      ),
      bodySmall: TextStyle(
        fontSize: 12, color: Color(0xFF8B949E),
      ),
      labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFC9D1D9),
      ),
      labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8B949E),
      ),
      labelSmall: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF8B949E),
      ),
    ),
  );
}
