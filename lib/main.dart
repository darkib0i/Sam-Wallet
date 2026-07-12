import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/sound_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/demo_watermark.dart';
import 'features/cards/presentation/cubit/cards_cubit.dart';
import 'features/cards/presentation/pages/wallet_home_page.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/payment/presentation/widgets/payment_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Light (white) status bar icons over the dark theme; transparent bars.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const AuroraWalletApp());
}

class AuroraWalletApp extends StatefulWidget {
  const AuroraWalletApp({super.key});

  @override
  State<AuroraWalletApp> createState() => _AuroraWalletAppState();
}

class _AuroraWalletAppState extends State<AuroraWalletApp> {
  // Created once; reused across rebuilds so we don't leak AudioPlayer instances.
  final SoundService _soundService = SoundService();

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Wallet (Demo)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        // Wrap EVERYTHING in the persistent, non-dismissible demo watermark.
        return DemoWatermark(child: child ?? const SizedBox.shrink());
      },
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CardsCubit()),
          BlocProvider(create: (_) => PaymentCubit()),
        ],
        child: Stack(
          children: [
            const WalletHomePage(),
            // Simulated payment overlay sits above the whole app.
            PaymentOverlay(soundService: _soundService),
          ],
        ),
      ),
    );
  }
}
