import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/transaction_factory.dart';
import '../../domain/transaction.dart';

/// Persistent draggable sheet listing fake, time-stamped recent activity.
class TransactionsSheet extends StatefulWidget {
  const TransactionsSheet({super.key});

  @override
  State<TransactionsSheet> createState() => _TransactionsSheetState();
}

class _TransactionsSheetState extends State<TransactionsSheet> {
  late final List<WalletTransaction> _txns =
      TransactionFactory().generate(count: 14);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.14,
      minChildSize: 0.14,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.14, 0.82],
      builder: (context, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: BackdropFilterSheet(
            child: ListView.builder(
              controller: controller,
              padding: EdgeInsets.zero,
              itemCount: _txns.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return const _SheetHeader();
                return _TxnRow(txn: _txns[index - 1]);
              },
            ),
          ),
        );
      },
    );
  }
}

/// Frosted-glass style container (approximates One UI's blurred bottom sheet).
class BackdropFilterSheet extends StatelessWidget {
  const BackdropFilterSheet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: child,
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent activity',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text('Demo data',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});
  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.surfaceHigh,
        child: Text(
          txn.merchant.characters.first,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(txn.merchant,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      subtitle: Text('${txn.category} · ${txn.relativeTime()}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Text(
        txn.signedAmount,
        style: TextStyle(
          color: txn.isCredit ? AppColors.success : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
