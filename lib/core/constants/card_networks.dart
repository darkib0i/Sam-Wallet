/// Catalogue of card "networks" used to seed the demo card factory.
///
/// Logos are fetched at runtime from the public simple-icons CDN (monochrome
/// vector marks). Nothing is bundled in the APK. These are used purely to make
/// the fictional demo cards look varied for UI benchmarking.
class CardNetwork {
  final String name;
  final String simpleIconsSlug; // slug on cdn.jsdelivr.net/npm/simple-icons
  final int digitGroups; // 4 => 16 digits, used for formatting variety

  const CardNetwork({
    required this.name,
    required this.simpleIconsSlug,
    this.digitGroups = 4,
  });

  /// Monochrome SVG logo URL (public CDN). Rendered white on the card.
  String get logoUrl =>
      'https://cdn.jsdelivr.net/npm/simple-icons@13/icons/$simpleIconsSlug.svg';

  static const List<CardNetwork> all = [
    CardNetwork(name: 'Visa', simpleIconsSlug: 'visa'),
    CardNetwork(name: 'Mastercard', simpleIconsSlug: 'mastercard'),
    CardNetwork(name: 'American Express', simpleIconsSlug: 'americanexpress'),
    CardNetwork(name: 'Discover', simpleIconsSlug: 'discover'),
    CardNetwork(name: 'JCB', simpleIconsSlug: 'jcb'),
    CardNetwork(name: 'Diners Club', simpleIconsSlug: 'dinersclub'),
    CardNetwork(name: 'Maestro', simpleIconsSlug: 'maestro'),
    CardNetwork(name: 'UnionPay', simpleIconsSlug: 'unionpay'),
    CardNetwork(name: 'Revolut', simpleIconsSlug: 'revolut'),
    CardNetwork(name: 'Binance', simpleIconsSlug: 'binance'),
    CardNetwork(name: 'PayPal', simpleIconsSlug: 'paypal'),
    CardNetwork(name: 'Wise', simpleIconsSlug: 'wise'),
    CardNetwork(name: 'Cash App', simpleIconsSlug: 'cashapp'),
    CardNetwork(name: 'Klarna', simpleIconsSlug: 'klarna'),
  ];
}

/// Fictional issuing "banks" — invented names, not real institutions.
class Issuers {
  Issuers._();

  static const List<String> banks = [
    'Aurora Bank',
    'Northwind Financial',
    'Solace Credit Union',
    'Meridian Trust',
    'Halcyon Bank',
    'Everpeak Savings',
    'Lumen Financial',
    'Cobalt Bank',
    'Vantage Credit',
    'Harborline Bank',
    'Sablewood Trust',
    'Zephyr Financial',
    'Quartz Bank',
    'Ironvale Credit Union',
    'Marisol Bank',
    'Nimbus Savings',
    'Argent Financial',
    'Willowmere Bank',
    'Crestfall Trust',
    'Novara Bank',
  ];

  static const List<String> productTiers = [
    'Everyday',
    'Signature',
    'Platinum',
    'Reserve',
    'Infinite',
    'Metal',
    'Cashback',
    'Travel',
    'Business',
    'Student',
  ];
}
