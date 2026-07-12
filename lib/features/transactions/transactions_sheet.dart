import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'transaction_model.dart';

/// Draggable, frosted-glass "Recent activity" sheet.
///
/// Uses a [DraggableScrollableSheet] with a backdrop blur for the frosted look.
/// Transactions are fake and randomised, with relative timestamps.
class TransactionsSheet extends StatelessWidget {
  final List<FakeTransaction> transactions;

  const TransactionsSheet({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.35, 0.6, 0.92],
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.82),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _grabberAndHeader()),
                  SliverList.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 68,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, i) => _row(transactions[i]),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _grabberAndHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textMuted,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Recent activity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                'Sample data',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _row(FakeTransaction t) {
    final isRefund = t.amount > 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(t.icon, color: AppColors.accentGlow, size: 20),
      ),
      title: Text(
        t.merchant,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      subtitle: Text(
        '${t.category} · ${t.relativeTime()}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Text(
        '${isRefund ? '+' : '-'}\$${t.amount.abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: isRefund ? AppColors.success : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
      ),
    );
  }
}
