import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/transaction_factory.dart';

part 'payment_state.dart';

/// Drives the SIMULATED payment overlay. This never contacts a payment network
/// and never claims a real transaction occurred — every result is a demo.
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit({TransactionFactory? factory})
      : _factory = factory ?? TransactionFactory(),
        super(const PaymentState());

  final TransactionFactory _factory;

  /// Called when the "NFC field detected" test trigger fires. Runs the demo
  /// animation, then shows a clearly-labelled demo confirmation.
  Future<void> simulateTap() async {
    if (state.phase != PaymentPhase.idle) return;

    emit(state.copyWith(phase: PaymentPhase.scanning));
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    emit(state.copyWith(
      phase: PaymentPhase.approved,
      reference: _factory.demoReference(),
    ));
  }

  void dismiss() => emit(const PaymentState());
}
