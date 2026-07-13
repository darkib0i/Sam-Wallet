import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/cards/presentation/cubit/cards_cubit.dart';
import 'features/cards/presentation/pages/wallet_home_page.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const WalletCloneApp());
}

class WalletCloneApp extends StatelessWidget {
  const WalletCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CardsCubit()..load(count: 500)),
        BlocProvider(create: (_) => PaymentCubit()),
      ],
      child: MaterialApp(
        title: 'Wallet Clone (Demo)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const WalletHomePage(),
      ),
    );
  }
}
