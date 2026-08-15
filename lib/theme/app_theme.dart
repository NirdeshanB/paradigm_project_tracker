import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const String _interFamily = 'Inter';
  static const String _outfitFamily = 'Outfit';
  // ─────────────────────────────
  // Colors
  // ─────────────────────────────
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4338CA);

  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceSecondary = Color(0xFFF0F1FA);

  static const Color textPrimary = Color(0xFF0F0E17);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7F0);
  static const Color borderLight = Color(0xFFEEF0F7);

  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFECFDF5);

  static const Color danger = Color(0xFFBE123C);
  static const Color dangerBg = Color(0xFFFFF1F2);

  static const Color warning = Color(0xFFF97316);
  static const Color warningBg = Color(0xFFFFF7ED);

  static const Color info = Color(0xFF0284C7);
  static const Color infoBg = Color(0xFFF0F9FF);

  // Priority colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF97316);
  static const Color priorityLow = Color(0xFF10B981);

  // ─────────────────────────────
  // Light Theme
  // ─────────────────────────────
  static ThemeData get light {
    final baseTextTheme = ThemeData.light().textTheme.apply(fontFamily: _interFamily);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        background: background,
        error: danger,
        brightness: Brightness.light,
        errorContainer: const Color(0xFFFFF2F2),
        onErrorContainer: const Color(0xFF991B1B),
        primaryContainer: const Color(0xFFEEF0FF),
        onPrimaryContainer: const Color(0xFF4F46E5),
        secondaryContainer: const Color(0xFFE8F5FE),
        onSecondaryContainer: const Color(0xFF0EA5E9),
        tertiaryContainer: const Color(0xFFFFF2EC),
        onTertiaryContainer: const Color(0xFFF97316),
      ),

      // Typography
      textTheme: baseTextTheme.copyWith(
        displayLarge: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontFamily: _interFamily, 
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: TextStyle(fontFamily: _interFamily, 
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(fontFamily: _interFamily, 
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.4,
        ),
        labelSmall: TextStyle(fontFamily: _interFamily, 
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          color: textMuted.withValues(alpha: 0.7),
        ),
        labelStyle: TextStyle(fontFamily: _interFamily, 
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(fontFamily: _outfitFamily, 
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: TextStyle(fontFamily: _interFamily, 
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(fontFamily: _interFamily, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────
  // Dark Theme (Premium slate design)
  // ─────────────────────────────
  static ThemeData get dark {
    final baseTextTheme = ThemeData.dark().textTheme.apply(fontFamily: _interFamily);
    const darkBackground = Color(0xFF0F172A); // slate-900
    const darkSurface = Color(0xFF1E293B);    // slate-800
    const darkBorder = Color(0xFF334155);     // slate-700
    const darkTextPrimary = Color(0xFFF8FAFC);
    const darkTextSecondary = Color(0xFF94A3B8);
    const darkTextMuted = Color(0xFF64748B);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryLight,
      dividerColor: darkBorder,
      cardColor: darkSurface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primaryLight,
        secondary: primaryLight,
        surface: darkSurface,
        background: darkBackground,
        error: danger,
        brightness: Brightness.dark,
        errorContainer: const Color(0xFF2C1616),
        onErrorContainer: const Color(0xFFFCA5A5),
        primaryContainer: const Color(0xFF1C1E4A),
        onPrimaryContainer: const Color(0xFF818CF8),
        secondaryContainer: const Color(0xFF1E3A5F),
        onSecondaryContainer: const Color(0xFF38BDF8),
        tertiaryContainer: const Color(0xFF4C2A1E),
        onTertiaryContainer: const Color(0xFFFB923C),
      ),

      // Typography
      textTheme: baseTextTheme.copyWith(
        displayLarge: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        headlineSmall: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleSmall: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(fontFamily: _interFamily, 
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
        bodySmall: TextStyle(fontFamily: _interFamily, 
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkTextMuted,
        ),
        labelLarge: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        labelMedium: TextStyle(fontFamily: _interFamily, 
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
          letterSpacing: 0.4,
        ),
        labelSmall: TextStyle(fontFamily: _interFamily, 
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkTextMuted,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: _outfitFamily, 
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(fontFamily: _interFamily, 
          fontSize: 14,
          color: darkTextMuted,
        ),
        labelStyle: TextStyle(fontFamily: _interFamily, 
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
          letterSpacing: 0.4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(fontFamily: _outfitFamily, 
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: TextStyle(fontFamily: _interFamily, 
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: TextStyle(fontFamily: _interFamily, color: darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
