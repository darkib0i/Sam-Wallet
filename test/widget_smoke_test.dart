import 'package:aurora_wallet/features/cards/data/card_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardFactory', () {
    test('generates the requested number of cards', () {
      final cards = CardFactory().generate(count: 500);
      expect(cards.length, 500);
    });

    test('is deterministic for a fixed seed', () {
      final a = CardFactory(seed: 42).generate(count: 20);
      final b = CardFactory(seed: 42).generate(count: 20);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].cardNumber, b[i].cardNumber);
        expect(a[i].cardHolderName, b[i].cardHolderName);
      }
    });

    test('card numbers are 16 digits in 4 groups', () {
      final card = CardFactory().generate(count: 1).first;
      final groups = card.cardNumber.split(' ');
      expect(groups.length, 4);
      expect(card.cardNumber.replaceAll(' ', '').length, 16);
    });

    test('search index is lowercase and contains issuer + network', () {
      final card = CardFactory().generate(count: 1).first;
      expect(card.searchIndex, card.searchIndex.toLowerCase());
      expect(card.searchIndex.contains(card.cardNetwork.toLowerCase()), isTrue);
    });
  });
}
