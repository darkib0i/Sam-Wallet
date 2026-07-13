import 'package:flutter/material.dart';

/// Samsung One UI inspired palette. Deep true-blacks, layered grays, and the
/// signature Samsung blue used for accents and the payment glow.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceHigh = Color(0xFF2A2A2C);
  static const Color surfaceLow = Color(0xFF141416);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9A9A9D);
  static const Color textTertiary = Color(0xFF6E6E73);

  static const Color samsungBlue = Color(0xFF1B6EF3);
  static const Color samsungBlueDeep = Color(0xFF0B4FCE);
  static const Color glow = Color(0xFF2E8BFF);

  static const Color success = Color(0xFF2EC36B);
  static const Color warning = Color(0xFFFF8A00);
  static const Color divider = Color(0xFF3A3A3C);

  // Accent chips seen on the categories row.
  static const Color voucher = Color(0xFFC9A877);
  static const Color membership = Color(0xFFE29AC4);
}
