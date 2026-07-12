import 'package:flutter/material.dart';

import '../../../core/constants/card_networks.dart';
import '../../../core/utils/color_utils.dart';
import '../domain/models/card_template.dart';
import 'faker_data.dart';

/// Factory that procedurally builds the deck of fictional demo cards.
///
/// Deterministic when given a [seed] so a UX test session can be reproduced
/// exactly. Produces [count] visually distinct cards by cycling networks,
/// issuers, tiers and a curated set of gradient base colours.
class CardFactory {
  final Faker _faker;
  CardFactory({int seed = 20240101}) : _faker = Faker(seed);

  /// Curated base hues for card gradients (wide, pleasant spread).
  static const List<Color> _baseColors = [
    Color(0xFF1F2A44), Color(0xFF3A1C71), Color(0xFF0F5C5B),
    Color(0xFF7B2D26), Color(0xFF14213D), Color(0xFF5A189A),
    Color(0xFF264653), Color(0xFF6A040F), Color(0xFF283618),
    Color(0xFF3D0066), Color(0xFF01497C), Color(0xFF9D4EDD),
    Color(0xFF212121), Color(0xFFB08968), Color(0xFF006466),
    Color(0xFF370617), Color(0xFF1B4332), Color(0xFF3C096C),
    Color(0xFF52050A), Color(0xFF03045E), Color(0xFF344E41),
    Color(0xFF432818), Color(0xFF10002B), Color(0xFF0B525B),
    Color(0xFFC9A227), Color(0xFF8D99AE), Color(0xFF2B2D42),
  ];

  /// Build [count] cards. Defaults to 500 as specified.
  List<CardTemplate> generate({int count = 500}) {
    final cards = <CardTemplate>[];
    for (var i = 0; i < count; i++) {
      cards.add(_buildOne(i));
    }
    return cards;
  }

  CardTemplate _buildOne(int index) {
    final network = CardNetwork.all[index % CardNetwork.all.length];
    final issuer = Issuers.banks[index % Issuers.banks.length];
    final tier = Issuers.productTiers[(index ~/ 7) % Issuers.productTiers.length];

    // Gradient: base colour + a deterministically derived second stop.
    final base = _baseColors[index % _baseColors.length];
    final variant = _faker.nextDouble();
    final start = variant > 0.5 ? ColorUtils.lighten(base, 0.06) : base;
    final end = ColorUtils.darken(base, 0.22 + _faker.nextDouble() * 0.1);

    // Contrast is computed from the visual midpoint of the gradient.
    final mid = ColorUtils.lerp(start, end, 0.5);
    final fg = ColorUtils.contrastingText(mid);
    final fgSecondary = ColorUtils.secondaryForeground(mid);

    final fourDigitCvv = network.name == 'American Express';

    return CardTemplate(
      id: 'card_$index',
      cardNetwork: network.name,
      logoUrl: network.logoUrl,
      issuerName: issuer,
      productTier: tier,
      cardHolderName: _faker.fullName(),
      cardNumber: _faker.cardNumber(),
      expiry: _faker.expiry(),
      cvv: _faker.cvv(fourDigits: fourDigitCvv),
      gradientStart: start,
      gradientEnd: end,
      foreground: fg,
      foregroundSecondary: fgSecondary,
    );
  }
}
