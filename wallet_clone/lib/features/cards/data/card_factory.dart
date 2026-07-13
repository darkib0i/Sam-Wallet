import 'dart:math';
import 'package:faker/faker.dart' hide Color;
import 'package:flutter/material.dart';
import '../domain/card_template.dart';

/// Factory that programmatically generates a large catalogue of unique,
/// fully-simulated card designs. Deterministic (seeded) so the gallery is
/// stable across rebuilds.
class CardFactory {
  CardFactory({int seed = 7}) : _rng = Random(seed), _faker = Faker(seed: seed);

  final Random _rng;
  final Faker _faker;

  static const List<String> _banks = [
    'FAB', 'Emirates NBD', 'Al Ansari Exchange', 'ADCB', 'Mashreq Neo',
    'Revolut', 'Monzo', 'N26', 'Wise', 'Chase', 'Barclays', 'HSBC',
    'Citi', 'Amex Bank', 'Standard Chartered', 'DBS', 'OCBC', 'Maybank',
    'ICICI', 'HDFC', 'SBI', 'Kotak', 'Binance', 'Coinbase', 'Crypto.com',
    'Deutsche Bank', 'BNP Paribas', 'Santander', 'ING', 'UBS', 'Nubank',
    'Capital One', 'Wells Fargo', 'US Bank', 'PNC', 'TD Bank', 'RBC',
    'Scotiabank', 'CommBank', 'Westpac', 'ANZ', 'NAB', 'Qatar National Bank',
    'Riyad Bank', 'Al Rajhi', 'Bank Muscat', 'Kuwait Finance House',
  ];

  /// Curated gradient palettes tuned to read like premium metal / plastic cards.
  static const List<List<Color>> _palettes = [
    [Color(0xFF0F2F6B), Color(0xFF2F8FF0)], // Samsung blue
    [Color(0xFF111318), Color(0xFF2B2F3A)], // graphite black
    [Color(0xFF3A1C71), Color(0xFFD76D77)], // royal violet
    [Color(0xFF0F2027), Color(0xFF2C5364)], // deep teal
    [Color(0xFF41295A), Color(0xFF2F0743)], // plum
    [Color(0xFFED213A), Color(0xFF93291E)], // ruby
    [Color(0xFFF7971E), Color(0xFFFFD200)], // gold
    [Color(0xFF1D976C), Color(0xFF93F9B9)], // emerald
    [Color(0xFF232526), Color(0xFF414345)], // titanium
    [Color(0xFFDA22FF), Color(0xFF9733EE)], // magenta
    [Color(0xFF16222A), Color(0xFF3A6073)], // slate
    [Color(0xFFB79891), Color(0xFF94716B)], // rose gold
    [Color(0xFFF0C27B), Color(0xFF4B1248)], // sunset
    [Color(0xFF0B486B), Color(0xFFF56217)], // ocean/amber
    [Color(0xFF485563), Color(0xFF29323C)], // steel
    [Color(0xFF614385), Color(0xFF516395)], // indigo
  ];

  /// Networks weighted toward the common ones for a realistic distribution.
  static const List<CardNetwork> _weightedNetworks = [
    CardNetwork.visa, CardNetwork.visa, CardNetwork.visa,
    CardNetwork.mastercard, CardNetwork.mastercard, CardNetwork.mastercard,
    CardNetwork.amex, CardNetwork.amex,
    CardNetwork.discover,
    CardNetwork.diners,
    CardNetwork.jcb,
    CardNetwork.unionPay,
    CardNetwork.rupay,
    CardNetwork.maestro,
    CardNetwork.crypto,
  ];

  List<CardTemplate> generate({int count = 500}) {
    return List.generate(count, (i) => _buildOne(i));
  }

  CardTemplate _buildOne(int id) {
    final network = _weightedNetworks[_rng.nextInt(_weightedNetworks.length)];
    final bank = _banks[_rng.nextInt(_banks.length)];
    final palette = _palettes[_rng.nextInt(_palettes.length)];

    return CardTemplate(
      id: id,
      bankName: bank,
      network: network,
      cardHolder: _faker.person.name().toUpperCase(),
      cardNumber: _formatNumber(network),
      expiry: _expiry(),
      cvv: (100 + _rng.nextInt(network == CardNetwork.amex ? 9000 : 900))
          .toString(),
      gradient: palette,
    );
  }

  /// Builds a format-only PAN. Amex uses a 15-digit 4-6-5 grouping; others 16.
  String _formatNumber(CardNetwork network) {
    String digits(int n) =>
        List.generate(n, (_) => _rng.nextInt(10)).join();
    if (network == CardNetwork.amex) {
      return '3${digits(3)} ${digits(6)} ${digits(5)}';
    }
    final prefix = switch (network) {
      CardNetwork.visa => '4',
      CardNetwork.mastercard => '5',
      CardNetwork.discover => '6',
      CardNetwork.unionPay => '62',
      _ => '${_rng.nextInt(4) + 3}',
    };
    final body = (prefix + digits(16)).substring(0, 16);
    return '${body.substring(0, 4)} ${body.substring(4, 8)} '
        '${body.substring(8, 12)} ${body.substring(12, 16)}';
  }

  String _expiry() {
    final month = (1 + _rng.nextInt(12)).toString().padLeft(2, '0');
    final year = (27 + _rng.nextInt(6)).toString();
    return '$month/$year';
  }
}
