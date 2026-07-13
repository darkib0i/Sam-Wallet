import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/payment_cubit.dart';

/// Full-screen SIMULATED payment animation.
///
/// By design this is deliberately NOT a pixel-clone of a real Samsung Pay
/// approval: a permanent "DEMO — NOT A REAL PAYMENT" watermark is painted over
/// everything, the result is labelled "Testing mode", there is no success
/// chime, and the reference is a mock string — never a bank authorization code.
/// This keeps it useful for UI/animation benchmarking while being impossible to
/// mistake for a genuine completed transaction.
class PaymentOverlay extends StatefulWidget {
  const PaymentOverlay({
    super.key,
    required this.phase,
    required this.reference,
    required this.onDismiss,
  });

  final PaymentPhase phase;
  final String? reference;
  final VoidCallback onDismiss;

  @override
  State<PaymentOverlay> createState() => _PaymentOverlayState();
}

class _PaymentOverlayState extends State<PaymentOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  late final AnimationController _approve = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(covariant PaymentOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase == PaymentPhase.approved &&
        oldWidget.phase != PaymentPhase.approved) {
      HapticFeedback.mediumImpact();
      _approve.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _approve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approved = widget.phase == PaymentPhase.approved;
    return Positioned.fill(
      child: Stack(
        children: [
          // Dim + subtle blue glow backdrop.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [Color(0xFF08213F), Color(0xEE000000)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Center(
            child: approved ? _buildApproved() : _buildScanning(),
          ),
          // Persistent, unmissable simulation watermark.
          const Positioned.fill(
            child: IgnorePointer(child: _DemoWatermark()),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _pill('SIMULATION · TESTING MODE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanning() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            return SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    _ring((_pulse.value + i / 3) % 1),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.glow, AppColors.samsungBlueDeep],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glow.withValues(alpha: 0.6),
                          blurRadius: 34,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.wifi_rounded,
                        color: Colors.white, size: 40),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        const Text('Simulating tap…',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _ring(double t) {
    final size = 96 + t * 104;
    return Opacity(
      opacity: (1 - t) * 0.5,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glow, width: 2),
        ),
      ),
    );
  }

  Widget _buildApproved() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: CurvedAnimation(parent: _approve, curve: Curves.elasticOut),
          child: RotationTransition(
            turns: Tween<double>(begin: -0.15, end: 0).animate(
              CurvedAnimation(parent: _approve, curve: Curves.easeOut),
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.16),
                border: Border.all(color: AppColors.success, width: 3),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 64),
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Text('Demo approved',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Testing mode — no funds moved',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Mock ref: ${widget.reference ?? '------'}',
            style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                letterSpacing: 1)),
        const SizedBox(height: 34),
        TextButton(
          onPressed: widget.onDismiss,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.warning,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Diagonal repeating "DEMO — NOT A REAL PAYMENT" wash across the whole screen.
class _DemoWatermark extends StatelessWidget {
  const _DemoWatermark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WatermarkPainter(), child: const SizedBox.expand());
  }
}

class _WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const text = 'DEMO · NOT A REAL PAYMENT   ';
    final tp = TextPainter(
      text: const TextSpan(
        text: text,
        style: TextStyle(
          color: Color(0x18FFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.5);
    canvas.translate(-size.width, -size.height);
    for (double y = 0; y < size.height * 2; y += 46) {
      for (double x = 0; x < size.width * 2; x += tp.width) {
        tp.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
