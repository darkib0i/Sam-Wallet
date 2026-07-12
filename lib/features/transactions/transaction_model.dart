import 'dart:math';

import 'package:flutter/material.dart';

/// A single fake transaction row for the "Recent activity" sheet.
class FakeTransaction {
  final String merchant;
  final String category;
  final IconData icon;
  final double amount; // negative = spend, positive = refund
  final DateTime timestamp;

  const FakeTransaction({
    required this.merchant,
    required this.category,
    required this.icon,
    required this.amount,
    required this.timestamp,
  });

  /// Human-friendly relative time ("2 mins ago", "Yesterday", ...).
  String relativeTime([DateTime? now]) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class TransactionFactory {
  final Random _rng;
  TransactionFactory([int? seed]) : _rng = Random(seed);

  static const _merchants = <List<dynamic>>[
    ['Blue Bottle Coffee', 'Food & Drink', Icons.local_cafe_rounded],
    ['Metro Transit', 'Transport', Icons.directions_subway_rounded],
    ['Northwind Grocer', 'Groceries', Icons.shopping_basket_rounded],
    ['Streamly', 'Subscriptions', Icons.play_circle_fill_rounded],
    ['Aurora Pharmacy', 'Health', Icons.medical_services_rounded],
    ['Vertex Fitness', 'Wellness', Icons.fitness_center_rounded],
    ['PageTurner Books', 'Shopping', Icons.menu_book_rounded],
    ['Solace Airlines', 'Travel', Icons.flight_takeoff_rounded],
    ['Cobalt Fuel', 'Transport', Icons.local_gas_station_rounded],
    ['Meridian Electric', 'Utilities', Icons.bolt_rounded],
    ['Harbor Diner', 'Food & Drink', Icons.restaurant_rounded],
    ['Nimbus Cloud', 'Subscriptions', Icons.cloud_rounded],
    ['Quartz Hardware', 'Shopping', Icons.handyman_rounded],
    ['Willowmere Spa', 'Wellness', Icons.spa_rounded],
  ];

  List<FakeTransaction> generate({int count = 12, DateTime? now}) {
    final ref = now ?? DateTime.now();
    final list = <FakeTransaction>[];
    var cursor = ref;
    for (var i = 0; i < count; i++) {
      final m = _merchants[_rng.nextInt(_merchants.length)];
      // Step backwards in time by an increasing, randomised amount.
      final stepMinutes = 2 + _rng.nextInt(60 * 30); // up to ~30h steps
      cursor = cursor.subtract(Duration(minutes: stepMinutes * (i == 0 ? 0 : 1)));
      final isRefund = _rng.nextInt(12) == 0;
      final amount = (isRefund ? 1 : -1) *
          (1.5 + _rng.nextDouble() * 180).toDouble();
      list.add(FakeTransaction(
        merchant: m[0] as String,
        category: m[1] as String,
        icon: m[2] as IconData,
        amount: double.parse(amount.toStringAsFixed(2)),
        timestamp: cursor,
      ));
    }
    return list;
  }
}
