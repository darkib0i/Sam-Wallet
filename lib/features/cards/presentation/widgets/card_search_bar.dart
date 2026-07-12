import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Search field that filters the deck by bank name or network.
class CardSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const CardSearchBar({
    super.key,
    required this.onChanged,
    this.hint = 'Search by bank or network',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        cursorColor: AppColors.accentGlow,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
