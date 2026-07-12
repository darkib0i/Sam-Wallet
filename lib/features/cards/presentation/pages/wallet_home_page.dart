import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../../transactions/transaction_model.dart';
import '../../../transactions/transactions_sheet.dart';
import '../cubit/cards_cubit.dart';
import '../widgets/card_carousel.dart';
import '../widgets/card_search_bar.dart';

/// Single-activity home: persistent bottom navigation + an inner TabBar
/// (Cards / Quick Access / Rewards) on the wallet tab.
class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _transactions = TransactionFactory(7).generate(count: 14);
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<CardsCubit>().load(count: 500);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerSimulation() {
    final card = context.read<CardsCubit>().state.selectedCard;
    if (card == null) return;
    context.read<PaymentCubit>().runSimulation(card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _bottomIndex == 0 ? _payTrigger() : null,
      bottomNavigationBar: _bottomNav(),
      body: IndexedStack(
        index: _bottomIndex,
        children: [
          _walletTab(),
          _placeholderTab('Passes', Icons.confirmation_number_rounded),
          _placeholderTab('Rewards', Icons.card_giftcard_rounded),
          _placeholderTab('Settings', Icons.settings_rounded),
        ],
      ),
    );
  }

  Widget _payTrigger() {
    // The "NFC field detected" TEST trigger. Clearly a demo control — it does
    // not touch real NFC hardware.
    return FloatingActionButton.extended(
      backgroundColor: AppColors.accent,
      onPressed: _triggerSimulation,
      icon: const Icon(Icons.contactless_rounded),
      label: const Text('Simulate tap',
          style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _walletTab() {
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 34), // clears the demo watermark pill
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Text('Aurora Wallet', style: AppTheme.heading(context)),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: AppColors.auroraGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.accentGlow,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
                tabs: const [
                  Tab(text: 'Cards'),
                  Tab(text: 'Quick Access'),
                  Tab(text: 'Rewards'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _cardsView(),
                    _quickAccessView(),
                    _rewardsView(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Persistent, draggable frosted transactions sheet.
        TransactionsSheet(transactions: _transactions),
      ],
    );
  }

  Widget _cardsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: CardSearchBar(
            onChanged: (q) => context.read<CardsCubit>().search(q),
          ),
        ),
        Expanded(
          child: BlocBuilder<CardsCubit, CardsState>(
            builder: (context, state) {
              if (state.status != CardsStatus.ready) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              if (state.visibleCards.isEmpty) {
                return const _EmptyState();
              }
              return Column(
                children: [
                  Expanded(
                    child: CardCarousel(
                      key: ValueKey(state.query),
                      cards: state.visibleCards,
                      onPageChanged: (i) =>
                          context.read<CardsCubit>().selectIndex(i),
                    ),
                  ),
                  _deckMeta(state),
                  // Space so the collapsed sheet doesn't cover controls.
                  const SizedBox(height: 150),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _deckMeta(CardsState state) {
    final card = state.selectedCard;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            card == null
                ? ''
                : '${card.issuerName} · ${card.cardNetwork}',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '${state.visibleCards.length} of ${state.allCards.length} demo cards · tap a card to reveal details',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _quickAccessView() {
    final items = const [
      ['Boarding pass', Icons.flight_rounded],
      ['Transit card', Icons.directions_transit_rounded],
      ['Event ticket', Icons.local_activity_rounded],
      ['Car key', Icons.key_rounded],
      ['Membership', Icons.badge_rounded],
      ['Student ID', Icons.school_rounded],
    ];
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: [
        for (final it in items)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
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

  Widget _rewardsView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
      children: [
        for (final tier in const ['Aurora Points', 'Cashback', 'Travel miles'])
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.auroraGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${1000 + tier.length * 137} pts',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
      ],
    );
  }

  Widget _placeholderTab(String title, IconData icon) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Demo section',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _bottomIndex,
      onTap: (i) => setState(() => _bottomIndex = i),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
        BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_rounded), label: 'Passes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_rounded), label: 'Rewards'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
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
