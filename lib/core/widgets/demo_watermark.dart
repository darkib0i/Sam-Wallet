import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A persistent, non-dismissible overlay that marks the entire app as a
/// testing/demo build.
///
/// This wraps the whole widget tree (see [main]) so the badge is visible on
/// every screen, including the payment simulation. It is intentionally
/// impossible to dismiss from within the app — it makes clear to anyone looking
/// at the screen that nothing here represents a real payment or real card data.
class DemoWatermark extends StatelessWidget {
  final Widget child;
  const DemoWatermark({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          // Top badge.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _DemoPill(),
                ),
              ),
            ),
          ),
          // Faint diagonal repeating watermark so it also shows in screenshots.
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DiagonalWatermarkPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoPill extends StatelessWidget {
  const _DemoPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.demoBadge.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '🔬  DEMO — FOR TESTING ONLY',
        style: TextStyle(
          color: Color(0xFF201700),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DiagonalWatermarkPainter extends CustomPainter {
  const _DiagonalWatermarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const text = 'DEMO • NOT A REAL PAYMENT • ';
    final tp = TextPainter(
      text: TextSpan(
        text: text * 3,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.035),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 2);

    canvas.save();
    canvas.translate(-size.width * 0.25, size.height * 0.2);
    canvas.rotate(-0.5);
    for (double y = 0; y < size.height * 1.5; y += 90) {
      tp.paint(canvas, Offset(0, y));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
