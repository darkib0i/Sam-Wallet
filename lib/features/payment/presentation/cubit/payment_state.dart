part of 'payment_cubit.dart';

enum PaymentPhase { idle, detecting, processing, completed }

class PaymentState extends Equatable {
  final PaymentPhase phase;
  final CardTemplate? card;
  final DateTime? completedAt;

  const PaymentState({
    this.phase = PaymentPhase.idle,
    this.card,
    this.completedAt,
  });

  bool get isActive => phase != PaymentPhase.idle;

  PaymentState copyWith({
    PaymentPhase? phase,
    CardTemplate? card,
    DateTime? completedAt,
  }) {
    return PaymentState(
      phase: phase ?? this.phase,
      card: card ?? this.card,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [phase, card, completedAt];
}
