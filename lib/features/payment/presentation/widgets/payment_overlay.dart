import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/payment_cubit.dart';

/// Full-screen overlay for the simulated ("test payment") journey.
///
/// Renders nothing when idle. Detecting/processing shows a pulsing contactless
/// ring; completion shows a smooth success check. A persistent "TEST PAYMENT"
/// chip is shown throughout — this is a UI benchmark, not a real transaction,
/// and that stays legible at every phase.
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
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
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
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.1,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.22),
                    Colors.black.withValues(alpha: 0.86),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const _TestPaymentChip(),
                      const Spacer(),
                      _hero(completed),
                      const SizedBox(height: 34),
                      _title(state),
                      if (completed) ...[
                        const SizedBox(height: 24),
                        _receiptCard(context, state),
                      ],
                      const Spacer(),
                      if (completed)
                        _doneButton(context)
                      else
                        _cancelButton(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- Hero animation -----------------------------------------------------

  Widget _hero(bool completed) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _check]),
      builder: (context, _) {
        return SizedBox(
          width: 168,
          height: 168,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!completed) ...[
                _ring(1.0 + _pulse.value * 0.35, 0.28),
                _ring(0.78 + _pulse.value * 0.22, 0.5),
              ] else
                _ring(1.15, 0.18),
              // Core disc.
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: completed
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.success, Color(0xFF2BB673)],
                        )
                      : AppColors.auroraGradient,
                  boxShadow: [
                    BoxShadow(
                      color: (completed
                              ? AppColors.success
                              : AppColors.accentGlow)
                          .withValues(alpha: 0.55),
                      blurRadius: 46,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: completed
                    ? Transform.scale(
                        scale: Curves.easeOutBack.transform(_check.value),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 66),
                      )
                    : const Icon(Icons.contactless_rounded,
                        color: Colors.white, size: 52),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ring(double scale, double alpha) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accentGlow.withValues(alpha: alpha),
            width: 2,
          ),
        ),
      ),
    );
  }

  // ---- Text ---------------------------------------------------------------

  Widget _title(PaymentState state) {
    final label = switch (state.phase) {
      PaymentPhase.detecting => 'Reading card…',
      PaymentPhase.processing => 'Processing…',
      PaymentPhase.completed => 'Test payment complete',
      PaymentPhase.idle => '',
    };
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Simulation · no real payment and no money moved',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---- Receipt card -------------------------------------------------------

  Widget _receiptCard(BuildContext context, PaymentState state) {
    final card = state.card;
    final at = state.completedAt ?? DateTime.now();
    final ts =
        '${at.year}-${_pad2(at.month)}-${_pad2(at.day)}  ${_pad2(at.hour)}:${_pad2(at.minute)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 30,
                decoration: BoxDecoration(
                  gradient: card == null
                      ? AppColors.auroraGradient
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [card.gradientStart, card.gradientEnd],
                        ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card == null
                      ? '—'
                      : '${card.issuerName} · ${card.cardNetwork}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                card == null ? '' : '···· ${card.last4}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          _row('Status', 'Test payment · simulated'),
          _row('Time', ts),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(v,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---- Buttons ------------------------------------------------------------

  Widget _doneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => context.read<PaymentCubit>().dismiss(),
        child: const Text('Done',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<PaymentCubit>().dismiss(),
      child: const Text('Cancel',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
    );
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');
}

/// Persistent chip that keeps the simulation nature legible at every phase.
class _TestPaymentChip extends StatelessWidget {
  const _TestPaymentChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.demoBadge.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.demoBadge.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_rounded, color: AppColors.demoBadge, size: 15),
          SizedBox(width: 7),
          Text(
            'TEST PAYMENT',
            style: TextStyle(
              color: AppColors.demoBadge,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
