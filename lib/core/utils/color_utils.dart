import 'package:flutter/material.dart';

/// Small colour helpers used by the card factory.
///
/// This replaces the runtime dependency on `palette_generator` (which needs a
/// decoded image): since our card backgrounds are procedurally generated
/// gradients, we already know the base colours and can pick a contrasting
/// foreground directly from relative luminance (WCAG-style).
class ColorUtils {
  ColorUtils._();

  /// Picks black or white text for maximum contrast against [background].
  static Color contrastingText(Color background) {
    return background.computeLuminance() > 0.45
        ? const Color(0xFF10121A)
        : Colors.white;
  }

  /// A softer secondary foreground colour that still meets contrast on the card.
  static Color secondaryForeground(Color background) {
    final base = contrastingText(background);
    return base.withValues(alpha: 0.72);
  }

  /// Blends two colours by [t] (0..1).
  static Color lerp(Color a, Color b, double t) =>
      Color.lerp(a, b, t) ?? a;

  /// Deterministically darken a colour (for the second gradient stop).
  static Color darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Deterministically lighten a colour.
  static Color lighten(Color c, [double amount = 0.12]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
