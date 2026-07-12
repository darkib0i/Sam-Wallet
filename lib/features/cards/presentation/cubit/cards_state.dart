part of 'cards_cubit.dart';

enum CardsStatus { initial, loading, ready }

class CardsState extends Equatable {
  final CardsStatus status;
  final List<CardTemplate> allCards;
  final List<CardTemplate> visibleCards;
  final String query;
  final int selectedIndex;

  const CardsState({
    this.status = CardsStatus.initial,
    this.allCards = const [],
    this.visibleCards = const [],
    this.query = '',
    this.selectedIndex = 0,
  });

  CardTemplate? get selectedCard =>
      visibleCards.isEmpty ? null : visibleCards[selectedIndex.clamp(0, visibleCards.length - 1)];

  CardsState copyWith({
    CardsStatus? status,
    List<CardTemplate>? allCards,
    List<CardTemplate>? visibleCards,
    String? query,
    int? selectedIndex,
  }) {
    return CardsState(
      status: status ?? this.status,
      allCards: allCards ?? this.allCards,
      visibleCards: visibleCards ?? this.visibleCards,
      query: query ?? this.query,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props =>
      [status, allCards, visibleCards, query, selectedIndex];
}
