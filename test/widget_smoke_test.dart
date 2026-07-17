import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aurora_wallet/main.dart';

void main() {
  testWidgets('renders the wallet home screen', (tester) async {
    await tester.pumpWidget(const WalletApp());

    expect(find.text('Samsung Wallet'), findsOneWidget);
    expect(find.text('Vouchers'), findsOneWidget);
    expect(find.text('Memberships'), findsOneWidget);
    expect(find.text('3363'), findsOneWidget);
    expect(find.text('PIN'), findsOneWidget);
    expect(find.text('Quick access'), findsOneWidget);
  });
}
