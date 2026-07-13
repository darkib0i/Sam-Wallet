import 'package:flutter/material.dart';
import '../../domain/card_template.dart';

/// Renders a network brand mark. These are stylized in-app representations
/// (drawn/typeset locally) so cards always render offline and no real
/// trademark artwork is bundled or hotlinked.
class NetworkLogo extends StatelessWidget {
  const NetworkLogo({super.key, required this.network, required this.color});

  final CardNetwork network;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (network) {
      case CardNetwork.mastercard:
      case CardNetwork.maestro:
        return _MastercardMark(
          size: 40,
          faded: network == CardNetwork.maestro,
        );
      case CardNetwork.visa:
        return _Wordmark('VISA',
            color: color, italic: true, weight: FontWeight.w800, size: 26);
      case CardNetwork.amex:
        return _AmexMark(color: color);
      default:
        return _Wordmark(network.label.toUpperCase(),
            color: color, weight: FontWeight.w700, size: 15);
    }
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark(this.text,
      {required this.color,
      this.italic = false,
      required this.weight,
      required this.size});

  final String text;
  final Color color;
  final bool italic;
  final FontWeight weight;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        fontWeight: weight,
        fontSize: size,
        letterSpacing: 1,
        height: 1,
      ),
    );
  }
}

/// The interlocking two-circle Mastercard-style mark.
class _MastercardMark extends StatelessWidget {
  const _MastercardMark({required this.size, this.faded = false});

  final double size;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final red = faded ? const Color(0xFF3A6AC0) : const Color(0xFFEB001B);
    final yellow = faded ? const Color(0xFF7BB0E8) : const Color(0xFFF79E1B);
    return SizedBox(
      width: size,
      height: size * 0.62,
      child: Stack(
        children: [
          Positioned(left: 0, child: _circle(red)),
          Positioned(right: 0, child: _circle(yellow.withValues(alpha: 0.9))),
        ],
      ),
    );
  }

  Widget _circle(Color c) => Container(
        width: size * 0.42,
        height: size * 0.42,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _AmexMark extends StatelessWidget {
  const _AmexMark({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E77BC),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'AMEX',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// EMV chip + contactless glyph shown on the face of every card for realism.
class CardChip extends StatelessWidget {
  const CardChip({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE7C56B), Color(0xFFB8912F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomPaint(painter: _ChipPainter()),
        ),
        const SizedBox(width: 10),
        Icon(Icons.wifi_rounded, size: 22, color: color.withValues(alpha: 0.85)),
      ],
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height * 0.35),
        Offset(size.width, size.height * 0.35), p);
    canvas.drawLine(Offset(0, size.height * 0.65),
        Offset(size.width, size.height * 0.65), p);
    canvas.drawLine(Offset(size.width * 0.35, 0),
        Offset(size.width * 0.35, size.height), p);
    canvas.drawLine(Offset(size.width * 0.65, 0),
        Offset(size.width * 0.65, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
