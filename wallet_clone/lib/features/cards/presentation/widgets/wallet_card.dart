import 'package:flutter/material.dart';
import '../../../animations/shimmer.dart';
import '../../domain/card_template.dart';
import 'network_logo.dart';

/// The card face. Wrapped in a [RepaintBoundary] by callers so carousel
/// scrolling and the shimmer never repaint the rest of the tree.
class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.card,
    this.revealed = false,
  });

  final CardTemplate card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.586,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: card.linearGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: card.gradient.last.withValues(alpha: 0.45),
                blurRadius: 26,
                offset: const Offset(0, 14),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Stack(
            children: [
              _guilloche(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            card.bankName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: card.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        NetworkLogo(network: card.network, color: card.textColor),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CardChip(color: card.textColor),
                    const Spacer(),
                    _number(),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _field('CARD HOLDER', card.cardHolder),
                        ),
                        _field('EXPIRES', card.expiry),
                        const SizedBox(width: 16),
                        _field('CVV', revealed ? card.cvv : '•••'),
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

  Widget _number() {
    final text = revealed
        ? card.cardNumber
        : '••••  ••••  ••••  ${card.last4}';
    final style = TextStyle(
      color: card.textColor,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final child = Text(text, style: style);
    return revealed
        ? Shimmer(baseColor: card.textColor, child: child)
        : child;
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: card.subTextColor,
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
            color: card.textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Subtle diagonal guilloché texture that reads like engraved card stock.
  Widget _guilloche() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(painter: _GuillochePainter(card.textColor)),
      ),
    );
  }
}

class _GuillochePainter extends CustomPainter {
  _GuillochePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = -size.height; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
    // Soft sheen in the top-right corner.
    final sheen = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.14), Colors.transparent],
      ).createShader(
        Rect.fromCircle(center: Offset(size.width, 0), radius: size.width * 0.7),
      );
    canvas.drawRect(Offset.zero & size, sheen);
  }

  @override
  bool shouldRepaint(covariant _GuillochePainter oldDelegate) =>
      oldDelegate.color != color;
}
