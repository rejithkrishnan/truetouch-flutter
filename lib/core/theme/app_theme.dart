import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm nursery colour palette matching the Godot design.
abstract final class AppColors {
  // Boot splash & fade overlay colour
  static const Color splash = Color(0xFFF1D7C0);

  // Card & panel backgrounds
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Page background tint (fallback when no image)
  static const Color pageBg = Color(0xFFF5E8D8);

  // Title text (changed to a lighter pastel sky blue)
  static const Color titleText = Color.fromARGB(255, 223, 157, 15);

  // Subtitle text (changed to a lighter pastel peach)
  static const Color subtitleText = Color(0xFFFF9966);

  // Parental Gate overlay
  static const Color gateOverlay = Color(0x1A262640);

  // Progress indicator (parental gate hold)
  static const Color gateProgress = Color(0x400080FF);

  // Random nursery card label colours (same palette as Godot)
  static const List<Color> nurseryPalette = [
    Color(0xFFFF7373), // Soft Coral
    Color(0xFF73D999), // Soft Mint
    Color(0xFF73A6FF), // Soft Sky
    Color(0xFFBF8CE6), // Soft Lavender
    Color(0xFFFFCC4D), // Soft Sunbeam
    Color(0xFFFF9966), // Soft Peach
  ];

  // Toggle on / off colours (Parent Menu)
  static const Color toggleOn = Color(0xFF4CAF50);
  static const Color toggleOff = Color(0xFFF44336);
}

/// Card decoration — 24 px radius, soft shadow.
BoxDecoration get cardDecoration => BoxDecoration(
  color: AppColors.cardWhite,
  borderRadius: BorderRadius.circular(24),
  boxShadow: const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 6)),
  ],
);

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.splash,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.pageBg,
    textTheme: GoogleFonts.quicksandTextTheme(_buildTextTheme()),
  );

  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.quicksand();
    return TextTheme(
      // App title "True Touch"
      displayLarge: base.copyWith(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: AppColors.titleText,
        shadows: const [
          Shadow(
            offset: Offset(3, 3),
            blurRadius: 5,
            color: Color(0x33000000), // Slightly darker shadow for contrast
          ),
        ],
      ),
      // Subtitle "Safe Learning Playroom"
      titleLarge: base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.subtitleText,
      ),
      // Card label (e.g. "Dog", "Cat")
      headlineMedium: base.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.cardWhite,
        shadows: const [
          Shadow(offset: Offset(2, 2), blurRadius: 4, color: Color(0x40000000)),
        ],
      ),
      // Module name on activity card
      bodyLarge: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.titleText,
      ),
      // Parent menu buttons, labels
      bodyMedium: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.titleText,
      ),
    );
  }
}
