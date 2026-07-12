import 'package:flutter/material.dart';

import '../../domain/models/card_template.dart';
import 'network_logo.dart';
import 'shimmer_reveal.dart';

/// The visual card. Wrapped in a [RepaintBoundary] for carousel performance.
///
/// When [revealed] is true it shows the full (fake) number and CVV with a
/// shimmer sweep; otherwise it shows a masked number.
class WalletCardWidget extends StatelessWidget {
  final CardTemplate card;
  final bool revealed;

  const WalletCardWidget({
    super.key,
    required this.card,
    this.revealed = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = card.foreground;
    final fg2 = card.foregroundSecondary;

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.586, // ISO/IEC 7810 ID-1 ratio
        child: Container(
          decoration: BoxDecoration(
            gradient: card.gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: card.gradientEnd.withValues(alpha: 0.55),
                blurRadius: 24,
                spreadRadius: -6,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle sheen.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: issuer + tier / logo.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.issuerName,
                                style: TextStyle(
                                  color: fg,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card.productTier.toUpperCase(),
                                style: TextStyle(
                                  color: fg2,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NetworkLogo(
                          url: card.logoUrl,
                          networkName: card.cardNetwork,
                          color: fg,
                        ),
                      ],
                    ),
                    const Spacer(),
                    _ChipGraphic(color: fg),
                    const SizedBox(height: 14),
                    // Card number.
                    ShimmerReveal(
                      active: revealed,
                      baseColor: fg,
                      child: Text(
                        revealed ? card.cardNumber : card.maskedNumber,
                        style: TextStyle(
                          color: fg,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                          // Default FontFeature ctor is const; the named
                          // tabularFigures() factory is not.
                          fontFeatures: const [FontFeature('tnum')],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Bottom row: holder / expiry / cvv.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _Field(
                            label: 'CARD HOLDER',
                            value: card.cardHolderName,
                            fg: fg,
                            fg2: fg2,
                          ),
                        ),
                        _Field(
                          label: 'EXPIRES',
                          value: card.expiry,
                          fg: fg,
                          fg2: fg2,
                        ),
                        const SizedBox(width: 18),
                        SizedBox(
                          width: 46,
                          child: ShimmerReveal(
                            active: revealed,
                            baseColor: fg,
                            child: _Field(
                              label: 'CVV',
                              value: revealed ? card.cvv : '•••',
                              fg: fg,
                              fg2: fg2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final Color fg;
  final Color fg2;
  const _Field({
    required this.label,
    required this.value,
    required this.fg,
    required this.fg2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: fg2,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: fg,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChipGraphic extends StatelessWidget {
  final Color color;
  const _ChipGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 26,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
