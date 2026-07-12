import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Immutable description of a single fictional demo card.
///
/// All values are procedurally generated. There is no real card data anywhere
/// in this app: [cardNumber] and [cvv] are random and formatted only to make
/// the UI look plausible for benchmarking.
class CardTemplate extends Equatable {
  final String id;
  final String cardNetwork; // Visa, Mastercard, ...
  final String logoUrl; // CDN vector logo
  final String issuerName; // fictional bank
  final String productTier; // Platinum, Travel, ...
  final String cardHolderName;
  final String cardNumber; // formatted, e.g. "4921 8830 1174 2255"
  final String expiry; // MM/YY
  final String cvv; // 3-4 digits (fake)

  // Gradient background.
  final Color gradientStart;
  final Color gradientEnd;

  // Contrasting foreground chosen from luminance.
  final Color foreground;
  final Color foregroundSecondary;

  const CardTemplate({
    required this.id,
    required this.cardNetwork,
    required this.logoUrl,
    required this.issuerName,
    required this.productTier,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.gradientStart,
    required this.gradientEnd,
    required this.foreground,
    required this.foregroundSecondary,
  });

  /// Last 4 digits for the collapsed / masked display.
  String get last4 => cardNumber.replaceAll(' ', '').substring(
        cardNumber.replaceAll(' ', '').length - 4,
      );

  String get maskedNumber {
    final groups = cardNumber.split(' ');
    if (groups.length < 2) return '•••• $last4';
    return '•••• •••• •••• ${groups.last}';
  }

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );

  /// Combined search haystack.
  String get searchIndex =>
      '$issuerName $cardNetwork $productTier $cardHolderName'.toLowerCase();

  @override
  List<Object?> get props => [id];
}
