import 'package:flutter/material.dart';

/// Lightweight replacement for the `palette_generator` contrast logic:
/// picks readable foreground colors from a card's gradient without pulling in
/// an image-decoding dependency.
class ColorUtils {
  const ColorUtils._();

  /// Relative luminance of the "average" of a gradient, used to decide whether
  /// text should be light or dark for maximum contrast (WCAG-style).
  static Color contrastingText(List<Color> gradient) {
    final avg = _averageColor(gradient);
    // Perceived luminance. Bright backgrounds -> dark text, and vice versa.
    return avg.computeLuminance() > 0.55
        ? const Color(0xFF10131A)
        : const Color(0xFFFFFFFF);
  }

  /// A muted variant of the contrasting text for secondary labels.
  static Color secondaryText(List<Color> gradient) {
    final base = contrastingText(gradient);
    return base.withValues(alpha: 0.72);
  }

  static Color _averageColor(List<Color> colors) {
    double r = 0, g = 0, b = 0;
    for (final c in colors) {
      r += c.r;
      g += c.g;
      b += c.b;
    }
    final n = colors.length;
    return Color.from(alpha: 1, red: r / n, green: g / n, blue: b / n);
  }
}
