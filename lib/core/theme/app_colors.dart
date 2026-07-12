import 'package:flutter/material.dart';

/// Aurora Wallet palette.
///
/// Deliberately distinct from any real-world payment brand. The accent is an
/// aurora violet/teal — not a bank blue — so the app never reads as an
/// imitation of an existing product.
class AppColors {
  AppColors._();

  // Base surfaces (deep near-black with a cool tint).
  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF15151C);
  static const Color surfaceElevated = Color(0xFF1E1E27);
  static const Color surfaceGlass = Color(0x33FFFFFF);

  // Aurora accent ramp.
  static const Color accent = Color(0xFF7C5CFF); // violet
  static const Color accentAlt = Color(0xFF2BD4C4); // teal
  static const Color accentGlow = Color(0xFF9D86FF);

  // Text.
  static const Color textPrimary = Color(0xFFF5F5FA);
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color textMuted = Color(0xFF6C6C7A);

  // Semantic.
  static const Color success = Color(0xFF3DDC97);
  static const Color divider = Color(0x1FFFFFFF);

  // Demo watermark tint.
  static const Color demoBadge = Color(0xFFFFC24B);

  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentAlt],
  );
}
