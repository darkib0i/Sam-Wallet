import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/card_template.dart';
import 'network_logo.dart';
import 'shimmer_reveal.dart';

/// The visual card, wrapped in a [RepaintBoundary] for carousel performance.
///
/// Layout mirrors a typical premium bank card: card type + issuer up top, a
/// contactless glyph, product tier, the (masked) number bottom-left, and the
/// network logo bottom-right. Tapping reveals the full (fake) number + CVV with
/// a shimmer sweep.
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
        aspectRatio: 1.586, // ISO/IEC 7810 ID-1
        child: Container(
          decoration: BoxDecoration(
            gradient: card.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: -8,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Flowing guilloché line pattern (premium card texture).
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CardLinesPainter(color: fg.withValues(alpha: 0.14)),
                  ),
                ),
                // Curved metallic sheen band sweeping down the right side.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SheenBandPainter(color: fg),
                  ),
                ),
                // Diagonal sheen.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.10),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'debit',
                            style: TextStyle(
                              color: fg,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              card.issuerName,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        card.productTier.toLowerCase(),
                        style: TextStyle(
                          color: fg2,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Contactless glyph aligned right.
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.contactless_rounded,
                            color: fg.withValues(alpha: 0.9), size: 26),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ShimmerReveal(
                              active: revealed,
                              baseColor: fg,
                              child: Text(
                                revealed ? card.cardNumber : card.maskedNumber,
                                style: TextStyle(
                                  color: fg,
                                  fontSize: revealed ? 16 : 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: revealed ? 1.4 : 2.0,
                                  fontFeatures: const [FontFeature('tnum')],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          NetworkLogo(
                            url: card.logoUrl,
                            networkName: card.cardNetwork,
                            color: fg,
                            height: 30,
                          ),
                        ],
                      ),
                      if (revealed) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MiniField(label: 'VALID', value: card.expiry, fg: fg, fg2: fg2),
                            const SizedBox(width: 22),
                            ShimmerReveal(
                              active: revealed,
                              baseColor: fg,
                              child: _MiniField(
                                  label: 'CVV', value: card.cvv, fg: fg, fg2: fg2),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final String value;
  final Color fg;
  final Color fg2;
  const _MiniField({
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
        Text(label,
            style: TextStyle(
                color: fg2,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Paints a set of smooth, concentric flowing curves for a guilloché-style
/// card texture. Cheap: a handful of quadratic paths, no per-pixel work.
class _CardLinesPainter extends CustomPainter {
  final Color color;
  const _CardLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;

    final origin = Offset(size.width * 0.16, size.height * 0.5);
    for (int i = 0; i < 14; i++) {
      final r = 30.0 + i * 26.0;
      final path = Path();
      for (double a = -math.pi * 0.62; a <= math.pi * 0.62; a += 0.08) {
        final wobble = math.sin(a * 3 + i * 0.5) * 6;
        final x = origin.dx + (r + wobble) * math.cos(a);
        final y = origin.dy + (r + wobble) * math.sin(a);
        if (a == -math.pi * 0.62) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CardLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Draws a soft curved highlight band sweeping down the right side of the card,
/// giving a subtle metallic/foil sheen like premium bank cards.
class _SheenBandPainter extends CustomPainter {
  final Color color;
  const _SheenBandPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.62, 0)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.5,
        size.width * 0.72,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.16),
          color.withValues(alpha: 0.04),
          color.withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);

    // Thin bright edge along the curve.
    final edge = Path()
      ..moveTo(size.width * 0.62, 0)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.5,
        size.width * 0.72,
        size.height,
      );
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = color.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _SheenBandPainter oldDelegate) =>
      oldDelegate.color != color;
}
