part of 'payment_cubit.dart';

enum PaymentPhase { idle, scanning, approved }

class PaymentState extends Equatable {
  const PaymentState({
    this.phase = PaymentPhase.idle,
    this.reference,
  });

  final PaymentPhase phase;
  final String? reference;

  bool get isActive => phase != PaymentPhase.idle;

  PaymentState copyWith({PaymentPhase? phase, String? reference}) {
    return PaymentState(
      phase: phase ?? this.phase,
      reference: reference ?? this.reference,
    );
  }

  @override
  List<Object?> get props => [phase, reference];
}
