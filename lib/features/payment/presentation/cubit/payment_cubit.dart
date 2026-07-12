import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cards/domain/models/card_template.dart';

part 'payment_state.dart';

/// Drives the *simulated* payment journey.
///
/// There is no networking, no NFC, no authorization. This is a scripted UI
/// sequence used to complete the user-research journey: idle -> detecting ->
/// processing -> completed. The terminal state is deliberately labelled as a
/// finished test, never as an approved payment.
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentState());

  /// Called when the "field detected" test trigger fires.
  Future<void> runSimulation(CardTemplate card) async {
    if (state.phase != PaymentPhase.idle) return;

    emit(PaymentState(phase: PaymentPhase.detecting, card: card));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (state.phase == PaymentPhase.idle) return; // cancelled

    emit(state.copyWith(phase: PaymentPhase.processing));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (state.phase == PaymentPhase.idle) return; // cancelled

    emit(state.copyWith(
      phase: PaymentPhase.completed,
      completedAt: DateTime.now(),
    ));
  }

  void dismiss() => emit(const PaymentState());
}
