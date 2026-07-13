import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/card_template.dart';
import '../../../animations/spring_tap.dart';
import 'wallet_card.dart';

/// The full, scrollable catalogue of generated cards with a live search field.
class CardGallery extends StatelessWidget {
  const CardGallery({
    super.key,
    required this.cards,
    required this.query,
    required this.onSearch,
    required this.onTap,
  });

  final List<CardTemplate> cards;
  final String query;
  final ValueChanged<String> onSearch;
  final ValueChanged<CardTemplate> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: _SearchField(query: query, onSearch: onSearch),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Text('${cards.length} designs',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              const Text('Tap to preview',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            itemCount: cards.length,
            // ignore: deprecated_member_use
            cacheExtent: 600,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SpringTap(
                  onTap: () => onTap(card),
                  child: WalletCard(card: card),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.query, required this.onSearch});

  final String query;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search bank or network',
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
