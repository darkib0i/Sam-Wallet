import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_utils.dart';

/// Supported card networks. Each maps to a custom-painted brand mark so the
/// card always renders (no broken remote logos) and ships no real trademark art.
enum CardNetwork {
  visa,
  mastercard,
  amex,
  discover,
  diners,
  jcb,
  unionPay,
  rupay,
  maestro,
  crypto;

  String get label {
    switch (this) {
      case CardNetwork.visa:
        return 'VISA';
      case CardNetwork.mastercard:
        return 'Mastercard';
      case CardNetwork.amex:
        return 'AMEX';
      case CardNetwork.discover:
        return 'DISCOVER';
      case CardNetwork.diners:
        return 'Diners Club';
      case CardNetwork.jcb:
        return 'JCB';
      case CardNetwork.unionPay:
        return 'UnionPay';
      case CardNetwork.rupay:
        return 'RuPay';
      case CardNetwork.maestro:
        return 'Maestro';
      case CardNetwork.crypto:
        return 'Crypto';
    }
  }
}

/// An immutable, fully simulated card design. No value here corresponds to a
/// real account — numbers are format-only randoms.
class CardTemplate extends Equatable {
  const CardTemplate({
    required this.id,
    required this.bankName,
    required this.network,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.gradient,
  });

  final int id;
  final String bankName;
  final CardNetwork network;
  final String cardHolder;

  /// Grouped, format-only PAN, e.g. "4921 8830 5567 7792".
  final String cardNumber;
  final String expiry; // MM/YY
  final String cvv; // 3-4 digits
  final List<Color> gradient;

  /// Last 4 digits, the only part shown on the collapsed card.
  String get last4 => cardNumber.replaceAll(' ', '').substring(
        cardNumber.replaceAll(' ', '').length - 4,
      );

  Color get textColor => ColorUtils.contrastingText(gradient);
  Color get subTextColor => ColorUtils.secondaryText(gradient);

  LinearGradient get linearGradient => LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Case-insensitive match against bank + network for the search bar.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return bankName.toLowerCase().contains(q) ||
        network.label.toLowerCase().contains(q);
  }

  @override
  List<Object?> get props => [id];
}
