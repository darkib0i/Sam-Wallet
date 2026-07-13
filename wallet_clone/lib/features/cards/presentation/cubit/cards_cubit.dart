import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/card_factory.dart';
import '../../domain/card_template.dart';

part 'cards_state.dart';

/// Owns the generated card catalogue, the active carousel index, the search
/// query, and which card (if any) is revealed.
class CardsCubit extends Cubit<CardsState> {
  CardsCubit({CardFactory? factory})
      : _factory = factory ?? CardFactory(),
        super(const CardsState());

  final CardFactory _factory;

  void load({int count = 500}) {
    emit(state.copyWith(all: _factory.generate(count: count)));
  }

  void search(String query) {
    emit(state.copyWith(query: query, selectedIndex: 0, clearReveal: true));
  }

  void selectIndex(int index) {
    emit(state.copyWith(selectedIndex: index, clearReveal: true));
  }

  void toggleReveal(int cardId) {
    if (state.revealedId == cardId) {
      emit(state.copyWith(clearReveal: true));
    } else {
      emit(state.copyWith(revealedId: cardId));
    }
  }
}
