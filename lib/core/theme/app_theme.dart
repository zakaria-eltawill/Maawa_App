import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - matching mockup design (vibrant blue scheme)
  static const Color primaryBlue = Color(0xFF1D6FEF); // Bright blue from mockups
  static const Color lightBlue = Color(0xFF5B9BFF);
  static const Color successGreen = Color(0xFF10B981); // Emerald green
  static const Color warningOrange = Color(0xFFFF6B35); // Orange for "reserved"
  static const Color dangerRed = Color(0xFFEF4444); // Red
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color goldYellow = Color(0xFFFBBF24); // For ratings/stars
  
  // Neutral grays
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  static ThemeData lightTheme([Locale? locale]) {
    // Create text theme with locale-specific font
    final baseTextTheme = locale?.languageCode == 'ar'
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.interTextTheme();
    
    final fontFamily = locale?.languageCode == 'ar'
        ? GoogleFonts.cairo().fontFamily
        : GoogleFonts.inter().fontFamily;
    
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: primaryBlue,
        error: dangerRed,
        surface: Colors.white,
        onSurface: gray900,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: gray50,
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: baseTextTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        textStyle: baseTextTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: gray300),
        foregroundColor: gray700,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor: primaryBlue,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: gray900,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: gray900,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: gray900,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: gray900,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: gray900,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: gray900,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: gray900,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: gray900,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: gray900,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: gray700,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: gray700,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: gray600,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: gray700,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: gray600,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: gray500,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerTheme: const DividerThemeData(
      color: gray200,
      thickness: 1,
      space: 1,
    ),
    );
  }

  // Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
}

