import 'dart:math';
import '../domain/transaction.dart';

/// Generates randomized, time-stamped fake transactions.
class TransactionFactory {
  TransactionFactory({int? seed}) : _rng = Random(seed);

  final Random _rng;

  static const _merchants = <List<String>>[
    ['Carrefour', 'Groceries'],
    ['Starbucks', 'Coffee'],
    ['Uber', 'Transport'],
    ['Netflix', 'Subscription'],
    ['Apple', 'App Store'],
    ['Shell', 'Fuel'],
    ['Amazon', 'Shopping'],
    ['Talabat', 'Food delivery'],
    ['Spotify', 'Subscription'],
    ['IKEA', 'Home'],
    ['Noon', 'Shopping'],
    ['Emirates', 'Travel'],
    ['Steam', 'Games'],
    ['McDonald\'s', 'Fast food'],
    ['Salik', 'Toll'],
  ];

  List<WalletTransaction> generate({int count = 12}) {
    final now = DateTime.now();
    var cursor = now;
    return List.generate(count, (i) {
      final m = _merchants[_rng.nextInt(_merchants.length)];
      // Walk backwards in time so the list is chronological.
      cursor = cursor.subtract(Duration(
        minutes: 2 + _rng.nextInt(i == 0 ? 8 : 2200),
      ));
      final credit = _rng.nextInt(6) == 0;
      return WalletTransaction(
        merchant: m[0],
        category: m[1],
        amount: (_rng.nextInt(48000) + 200) / 100,
        currency: 'AED',
        when: cursor,
        isCredit: credit,
      );
    });
  }

  /// Six-character alphanumeric reference for the demo confirmation sheet.
  /// Clearly a mock reference — not a bank authorization code.
  String demoReference() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_rng.nextInt(chars.length)]).join();
  }
}
