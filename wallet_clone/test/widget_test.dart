import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_clone/features/cards/data/card_factory.dart';

void main() {
  test('CardFactory generates the requested number of unique cards', () {
    final cards = CardFactory().generate(count: 500);
    expect(cards.length, 500);
    expect(cards.map((c) => c.id).toSet().length, 500);
    // Numbers are format-only groups of digits, never empty.
    expect(cards.every((c) => c.cardNumber.contains(' ')), isTrue);
  });
}
