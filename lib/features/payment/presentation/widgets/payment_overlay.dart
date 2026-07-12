import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/payment_cubit.dart';

/// Full-screen overlay for the *simulated* payment journey.
///
/// Renders nothing when idle. During detecting/processing it shows a glowing
/// aurora circle that expands and pulses; on completion a checkmark rotates in
/// and a neutral "Test transaction complete — Demo mode" panel appears with a
/// timestamp (no approval language, no authorization code).
class PaymentOverlay extends StatefulWidget {
  final SoundService soundService;
  const PaymentOverlay({super.key, required this.soundService});

  @override
  State<PaymentOverlay> createState() => _PaymentOverlayState();
}

class _PaymentOverlayState extends State<PaymentOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _check;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _check.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listenWhen: (prev, next) => prev.phase != next.phase,
      listener: (context, state) {
        if (state.phase == PaymentPhase.completed) {
          _check.forward(from: 0);
          widget.soundService.playGenericSuccess();
        } else {
          _check.reset();
        }
      },
      builder: (context, state) {
        if (!state.isActive) return const SizedBox.shrink();
        final completed = state.phase == PaymentPhase.completed;

        return Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: Colors.black.withValues(alpha: 0.72),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _glowCircle(completed),
                    const SizedBox(height: 40),
                    _statusText(state),
                    const Spacer(),
                    if (completed) _completedPanel(context, state),
                    if (!completed)
                      TextButton(
                        onPressed: () =>
                            context.read<PaymentCubit>().dismiss(),
                        child: const Text(
                          'Cancel test',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _glowCircle(bool completed) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _check]),
      builder: (context, _) {
        final pulse = 0.85 + (_pulse.value * 0.25);
        final ringScale = completed ? 1.0 : pulse;
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding glow.
              Container(
                width: 180 * ringScale,
                height: 180 * ringScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.55),
                      AppColors.accentAlt.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.7, 1.0],
                  ),
                ),
              ),
              // Solid core.
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.auroraGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGlow,
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: completed
                    ? Transform.rotate(
                        // Checkmark rotates + scales into view.
                        angle: (1 - Curves.easeOutBack.transform(_check.value)) *
                            0.9,
                        child: Transform.scale(
                          scale: Curves.easeOutBack.transform(_check.value),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 64),
                        ),
                      )
                    : const Icon(Icons.contactless_rounded,
                        color: Colors.white, size: 54),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusText(PaymentState state) {
    final label = switch (state.phase) {
      PaymentPhase.detecting => 'Simulated field detected…',
      PaymentPhase.processing => 'Running test transaction…',
      PaymentPhase.completed => 'Test transaction complete',
      PaymentPhase.idle => '',
    };
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'DEMO MODE · no real payment',
          style: TextStyle(
            color: AppColors.demoBadge,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _completedPanel(BuildContext context, PaymentState state) {
    final card = state.card;
    final at = state.completedAt ?? DateTime.now();
    final ts =
        '${at.year}-${_pad2(at.month)}-${_pad2(at.day)} ${_pad2(at.hour)}:${_pad2(at.minute)}:${_pad2(at.second)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.science_rounded,
              color: AppColors.demoBadge, size: 28),
          const SizedBox(height: 10),
          const Text(
            'Test Transaction Complete — Demo Mode',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This did not contact any payment network and no money moved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          _kv('Card used', card == null
              ? '—'
              : '${card.issuerName} ${card.productTier} ···· ${card.last4}'),
          _kv('Recorded at', ts),
          _kv('Mode', 'UI/UX benchmark (simulation)'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => context.read<PaymentCubit>().dismiss(),
              child: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(k,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12.5)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');
}
