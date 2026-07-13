part of 'cards_cubit.dart';

class CardsState extends Equatable {
  const CardsState({
    this.all = const [],
    this.query = '',
    this.selectedIndex = 0,
    this.revealedId,
  });

  final List<CardTemplate> all;
  final String query;
  final int selectedIndex;

  /// Id of the card currently showing its full number / CVV (tap-to-reveal).
  final int? revealedId;

  List<CardTemplate> get filtered =>
      all.where((c) => c.matches(query)).toList(growable: false);

  CardsState copyWith({
    List<CardTemplate>? all,
    String? query,
    int? selectedIndex,
    int? revealedId,
    bool clearReveal = false,
  }) {
    return CardsState(
      all: all ?? this.all,
      query: query ?? this.query,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      revealedId: clearReveal ? null : (revealedId ?? this.revealedId),
    );
  }

  @override
  List<Object?> get props => [all, query, selectedIndex, revealedId];
}
