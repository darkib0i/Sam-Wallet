import 'package:equatable/equatable.dart';

/// A fully fake transaction row for the "Recent activity" sheet.
class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.merchant,
    required this.category,
    required this.amount,
    required this.currency,
    required this.when,
    required this.isCredit,
  });

  final String merchant;
  final String category;
  final double amount;
  final String currency;
  final DateTime when;
  final bool isCredit;

  /// Human "2 mins ago" / "Yesterday" style relative label.
  String relativeTime([DateTime? now]) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(when);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }

  String get signedAmount =>
      '${isCredit ? '+' : '-'}$currency ${amount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [merchant, amount, when];
}
