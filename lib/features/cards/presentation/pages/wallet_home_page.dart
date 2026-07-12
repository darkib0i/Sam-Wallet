import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../../transactions/transaction_model.dart';
import '../../../transactions/transactions_sheet.dart';
import '../cubit/cards_cubit.dart';
import '../widgets/card_carousel.dart';
import '../widgets/card_search_bar.dart';

/// Single-screen wallet home modelled on a clean card-wallet layout:
/// title bar + actions, promo banner, top segmented tabs, a centred card
/// carousel with peeking neighbours, an action pill, and bottom view tabs.
class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  final _transactions = TransactionFactory(7).generate(count: 14);
  bool _showPromo = true;
  int _topTab = 0; // 0 = Cards, 1 = Memberships
  int _bottomView = 0; // 0 = Quick access (carousel), 1 = All (grid)

  @override
  void initState() {
    super.initState();
    context.read<CardsCubit>().load(count: 500);
  }

  void _triggerSimulation() {
    final card = context.read<CardsCubit>().state.selectedCard;
    if (card == null) return;
    context.read<PaymentCubit>().runSimulation(card);
  }

  void _openRecent() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TransactionsSheet(transactions: _transactions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            if (_showPromo) _promoBanner(),
            const SizedBox(height: 8),
            _segmentedTabs(),
            Expanded(
              child: _bottomView == 0 ? _quickAccessView() : _allCardsView(),
            ),
            _bottomTabs(),
          ],
        ),
      ),
    );
  }

  // ---- Top bar ------------------------------------------------------------

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: Row(
        children: [
          const Text(
            'Aurora Wallet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _iconBtn(Icons.add_rounded),
          _iconBtn(Icons.campaign_outlined),
          _iconBtn(Icons.more_vert_rounded),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) => IconButton(
        onPressed: () {},
        icon: Icon(icon, color: AppColors.textPrimary, size: 24),
        splashRadius: 22,
      );

  // ---- Promo banner -------------------------------------------------------

  Widget _promoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('👛', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Add your membership cards to get and use points.',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.3),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showPromo = false),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                    color: AppColors.surface, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Segmented tabs -----------------------------------------------------

  Widget _segmentedTabs() {
    Widget tab(int i, IconData icon, String label) {
      final active = _topTab == i;
      return GestureDetector(
        onTap: () => setState(() => _topTab = i),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 20,
                color: active ? AppColors.accentGlow : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          tab(0, Icons.credit_card_rounded, 'Cards'),
          Container(
            width: 1,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: AppColors.divider,
          ),
          tab(1, Icons.badge_outlined, 'Memberships'),
        ],
      ),
    );
  }

  // ---- Quick access (carousel) view --------------------------------------

  Widget _quickAccessView() {
    if (_topTab == 1) return _membershipsGrid();

    return BlocBuilder<CardsCubit, CardsState>(
      builder: (context, state) {
        if (state.status != CardsStatus.ready) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        }
        final card = state.selectedCard;
        return Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: CardCarousel(
                cards: state.visibleCards,
                onPageChanged: (i) =>
                    context.read<CardsCubit>().selectIndex(i),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              card == null ? '' : '${card.issuerName} · ${card.cardNetwork}',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the card to reveal details',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const Spacer(),
            // Action pill row (analogous to the reference's action pill).
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pill(Icons.contactless_rounded, 'Tap to pay',
                    primary: true, onTap: _triggerSimulation),
                const SizedBox(width: 12),
                _pill(Icons.receipt_long_rounded, 'Recent', onTap: _openRecent),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _pill(IconData icon, String label,
      {bool primary = false, required VoidCallback onTap}) {
    return Material(
      color: primary ? AppColors.accent : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: primary ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: primary ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  // ---- All cards (searchable grid) ---------------------------------------

  Widget _allCardsView() {
    if (_topTab == 1) return _membershipsGrid();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: CardSearchBar(
            onChanged: (q) => context.read<CardsCubit>().search(q),
          ),
        ),
        Expanded(
          child: BlocBuilder<CardsCubit, CardsState>(
            builder: (context, state) {
              if (state.status != CardsStatus.ready) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.accent));
              }
              if (state.visibleCards.isEmpty) {
                return const _EmptyState();
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 118,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.visibleCards.length,
                itemBuilder: (context, i) {
                  final c = state.visibleCards[i];
                  return _MiniCardRow(
                    label: '${c.issuerName} · ${c.productTier}',
                    network: c.cardNetwork,
                    last4: c.last4,
                    start: c.gradientStart,
                    end: c.gradientEnd,
                    onTap: () {
                      context.read<CardsCubit>().selectIndex(i);
                      setState(() => _bottomView = 0);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _membershipsGrid() {
    const items = [
      ['Boarding pass', Icons.flight_rounded],
      ['Transit card', Icons.directions_transit_rounded],
      ['Event ticket', Icons.local_activity_rounded],
      ['Membership', Icons.badge_rounded],
      ['Car key', Icons.key_rounded],
      ['Student ID', Icons.school_rounded],
    ];
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        for (final it in items)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(it[1] as IconData,
                    color: AppColors.accentGlow, size: 26),
                Text(it[0] as String,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  // ---- Bottom view tabs ---------------------------------------------------

  Widget _bottomTabs() {
    Widget tab(int i, String label) {
      final active = _bottomView == i;
      return GestureDetector(
        onTap: () => setState(() => _bottomView = i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color:
                        active ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 120 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Expanded(child: Center(child: tab(0, 'Quick access'))),
          Expanded(child: Center(child: tab(1, 'All'))),
        ],
      ),
    );
  }
}

class _MiniCardRow extends StatelessWidget {
  final String label;
  final String network;
  final String last4;
  final Color start;
  final Color end;
  final VoidCallback onTap;

  const _MiniCardRow({
    required this.label,
    required this.network,
    required this.last4,
    required this.start,
    required this.end,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 92,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [start, end],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('$network  ···· $last4',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 44),
          SizedBox(height: 10),
          Text('No cards match your search',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
