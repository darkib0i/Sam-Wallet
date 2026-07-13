import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../../payment/presentation/widgets/payment_overlay.dart';
import '../../../payment/presentation/widgets/transactions_sheet.dart';
import '../../domain/card_template.dart';
import '../cubit/cards_cubit.dart';
import '../widgets/card_carousel.dart';
import '../widgets/card_gallery.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  int _tab = 0; // 0 = Cards, 1 = Quick access, 2 = Rewards

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _NfcTestButton(
        onTap: () => context.read<PaymentCubit>().simulateTap(),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _WalletHeader(),
                _Tabs(current: _tab, onChanged: (i) => setState(() => _tab = i)),
                Expanded(child: _body()),
              ],
            ),
          ),
          if (_tab == 0) const TransactionsSheet(),
          // SIMULATED payment overlay — only while a demo tap is running.
          BlocBuilder<PaymentCubit, PaymentState>(
            builder: (context, state) {
              if (!state.isActive) return const SizedBox.shrink();
              return PaymentOverlay(
                phase: state.phase,
                reference: state.reference,
                onDismiss: () => context.read<PaymentCubit>().dismiss(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case 1:
        return BlocBuilder<CardsCubit, CardsState>(
          builder: (context, state) => CardGallery(
            cards: state.filtered,
            query: state.query,
            onSearch: context.read<CardsCubit>().search,
            onTap: (card) => _showCardDetail(context, card),
          ),
        );
      case 2:
        return const _RewardsPlaceholder();
      default:
        return const _CardsTab();
    }
  }
}

class _CardsTab extends StatelessWidget {
  const _CardsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardsCubit, CardsState>(
      builder: (context, state) {
        final cards = state.filtered;
        return Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: context.read<CardsCubit>().search,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search your cards',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            CardCarousel(
              cards: cards,
              revealedId: state.revealedId,
              onPageChanged: context.read<CardsCubit>().selectIndex,
              onCardTapped: (card) =>
                  context.read<CardsCubit>().toggleReveal(card.id),
            ),
            const SizedBox(height: 14),
            if (cards.isNotEmpty)
              Text(
                state.revealedId == cards[state.selectedIndex.clamp(0, cards.length - 1)].id
                    ? 'Tap again to hide details'
                    : 'Tap the card to reveal number & CVV',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
          ],
        );
      },
    );
  }
}

void _showCardDetail(BuildContext context, CardTemplate card) {
  context.read<CardsCubit>().search('');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.surfaceHigh,
      content: Text('${card.bankName} · ${card.network.label} ••${card.last4}',
          style: const TextStyle(color: Colors.white)),
      duration: const Duration(milliseconds: 900),
    ),
  );
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
      child: Row(
        children: [
          const Text('Wallet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('DEMO',
                style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
          ),
          const Spacer(),
          const Icon(Icons.add, color: Colors.white, size: 26),
          const SizedBox(width: 18),
          const Icon(Icons.campaign_outlined, color: Colors.white, size: 26),
          const SizedBox(width: 18),
          const Icon(Icons.more_vert, color: Colors.white, size: 26),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  static const _labels = ['Cards', 'Quick access', 'Rewards'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final active = i == current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_labels[i],
                      style: TextStyle(
                          color: active
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 17,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    width: active ? 26 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RewardsPlaceholder extends StatelessWidget {
  const _RewardsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final r in const [
          ['Coffee House', '4 / 8 stars to a free drink'],
          ['CineMax', '2,340 points'],
          ['SkyMiles', '18,905 miles'],
          ['GreenGrocer', 'Gold tier'],
        ])
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                    backgroundColor: AppColors.surfaceHigh,
                    child: Icon(Icons.card_giftcard, color: Colors.white)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(r[1],
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NfcTestButton extends StatelessWidget {
  const _NfcTestButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: AppColors.samsungBlue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.wifi_rounded),
      label: const Text('NFC field (test)'),
    );
  }
}
