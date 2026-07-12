import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/card_factory.dart';
import '../../domain/models/card_template.dart';

part 'cards_state.dart';

/// Owns the deck of demo cards, the active search query, and the currently
/// centred card in the carousel.
class CardsCubit extends Cubit<CardsState> {
  final CardFactory _factory;
  CardsCubit({CardFactory? factory})
      : _factory = factory ?? CardFactory(),
        super(const CardsState());

  /// Generate the deck (default 500) off the main concerns of the UI.
  void load({int count = 500}) {
    emit(state.copyWith(status: CardsStatus.loading));
    final cards = _factory.generate(count: count);
    emit(state.copyWith(
      status: CardsStatus.ready,
      allCards: cards,
      visibleCards: cards,
      selectedIndex: 0,
    ));
  }

  void search(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      emit(state.copyWith(
        query: '',
        visibleCards: state.allCards,
        selectedIndex: 0,
      ));
      return;
    }
    final filtered = state.allCards
        .where((c) => c.searchIndex.contains(query))
        .toList(growable: false);
    emit(state.copyWith(
      query: query,
      visibleCards: filtered,
      selectedIndex: 0,
    ));
  }

  void selectIndex(int index) {
    if (index == state.selectedIndex) return;
    emit(state.copyWith(selectedIndex: index));
  }
}
