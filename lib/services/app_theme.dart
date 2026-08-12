import 'package:flutter/material.dart';

class AppTheme extends ValueNotifier<ThemeMode> {
  AppTheme(ThemeMode value) : super(value);

  static final instance = AppTheme(ThemeMode.system);

  static ThemeData buildThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Modern color palette
    const primaryColor = Color(0xFF6C63FF);
    const secondaryColor = Color(0xFFFF6584);
    const tertiaryColor = Color(0xFF00D2FF);
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      scaffoldBackgroundColor: isDark 
          ? const Color(0xFF0A0A0F) 
          : const Color(0xFFF8F9FE),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: isDark 
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.9)
            : Colors.white,
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconSize: 28,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.7)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1F2937),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
        labelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
        thickness: 1,
        space: 24,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }
}