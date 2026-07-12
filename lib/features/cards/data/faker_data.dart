import 'dart:math';

/// Tiny self-contained fake-data generator.
///
/// Avoids an external `faker` dependency and keeps generation fully
/// deterministic when seeded, which is useful for reproducible UX test runs.
class Faker {
  final Random _rng;
  Faker([int? seed]) : _rng = Random(seed);

  static const _firstNames = [
    'Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Jamie', 'Avery',
    'Sam', 'Quinn', 'Rowan', 'Elliot', 'Harper', 'Micah', 'Noa', 'Sasha',
    'Devon', 'Reese', 'Kai', 'Emerson', 'Blake', 'Finley', 'Marlowe', 'Sage',
    'Indira', 'Mateo', 'Yara', 'Nikolai', 'Freya', 'Omar', 'Lucia', 'Hana',
  ];

  static const _lastNames = [
    'Reyes', 'Nakamura', 'Okafor', 'Petrova', 'Andersen', 'Silva', 'Kaur',
    'Delgado', 'Novak', 'Haddad', 'Rossi', 'Bergström', 'Costa', 'Ivanov',
    'Fernández', 'Kowalski', 'Adeyemi', 'Larsen', 'Moreau', 'Yamamoto',
    'Schneider', 'Mbeki', 'Cohen', 'Ferrari', 'Nguyen', 'Abbas', 'Fontaine',
  ];

  int nextInt(int max) => _rng.nextInt(max);
  double nextDouble() => _rng.nextDouble();

  T pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  String fullName() =>
      '${pick(_firstNames)} ${pick(_lastNames)}'.toUpperCase();

  /// A formatted, entirely random 16-digit card number in 4x4 groups.
  String cardNumber() {
    final b = StringBuffer();
    for (var g = 0; g < 4; g++) {
      if (g > 0) b.write(' ');
      for (var d = 0; d < 4; d++) {
        b.write(_rng.nextInt(10));
      }
    }
    return b.toString();
  }

  String cvv({bool fourDigits = false}) {
    final len = fourDigits ? 4 : 3;
    final b = StringBuffer();
    for (var i = 0; i < len; i++) {
      b.write(_rng.nextInt(10));
    }
    return b.toString();
  }

  String expiry() {
    final month = (1 + _rng.nextInt(12)).toString().padLeft(2, '0');
    final year = (26 + _rng.nextInt(7)).toString(); // 26..32
    return '$month/$year';
  }
}
