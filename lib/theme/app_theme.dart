import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1); // Modern indigo
  static const Color accentColor = Color(0xFF8B5CF6); // Beautiful purple
  static const Color secondaryColor = Color(0xFF64748B); // Slate gray
  static const Color goldColor = Color(0xFFD4AF37); // Gold/amber from logo

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFF8FAFF), Color(0xFFE8F2FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  // Beautiful Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // Text styles optimized for glass components
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 3.0,
        color: Color.fromARGB(100, 0, 0, 0),
      ),
    ],
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 2.0,
        color: Color.fromARGB(80, 0, 0, 0),
      ),
    ],
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Colors.white,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB0B0B0),
  );

  // Icon themes for glass visibility
  static const IconThemeData glassIconTheme = IconThemeData(
    color: Colors.white,
    size: 24,
  );

  static const IconThemeData accentIconTheme = IconThemeData(
    color: primaryColor,
    size: 24,
  );

  // Glass button styles
  static ButtonStyle glassButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withValues(alpha: 0.1),
    foregroundColor: Colors.white,
    elevation: 0,
    side: BorderSide(
      color: Colors.white.withValues(alpha: 0.2),
      width: 1,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle primaryGlassButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor.withValues(alpha: 0.8),
    foregroundColor: Colors.white,
    elevation: 8,
    shadowColor: primaryColor.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
}