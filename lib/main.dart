import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw our own replica status bar; hide the system one so the mock matches
  // the reference screenshot exactly (time, icons and all).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'sans-serif',
      ),
      home: const WalletHomePage(),
    );
  }
}

class WalletHomePage extends StatelessWidget {
  const WalletHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // The reference image is 1080 px wide. Everything is positioned in
          // reference pixels and scaled by k so the layout is identical on any
          // Pixel-class device.
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;
          final double k = w / 1080.0;
          px(double v) => v * k;

          return Stack(
            children: [
              // ---- Status bar (replica) ----
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: px(96),
                child: _StatusBar(k: k),
              ),

              // ---- Header ----
              Positioned(
                left: px(64),
                top: px(150),
                child: Text(
                  'Samsung Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: px(48),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Positioned(
                left: px(636),
                top: px(150),
                child: Icon(Icons.add, color: Colors.white, size: px(58)),
              ),
              Positioned(
                left: px(740),
                top: px(156),
                child: Transform.rotate(
                  angle: -0.15,
                  child: Icon(Icons.campaign_outlined,
                      color: Colors.white, size: px(56)),
                ),
              ),
              // red unread dot on the megaphone
              Positioned(
                left: px(792),
                top: px(150),
                child: Container(
                  width: px(18),
                  height: px(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: px(844),
                top: px(154),
                child: Icon(Icons.more_vert, color: Colors.white, size: px(54)),
              ),

              // ---- Membership banner ----
              Positioned(
                left: px(52),
                right: px(52),
                top: px(262),
                child: _Banner(k: k),
              ),

              // ---- Vouchers / Memberships tabs ----
              Positioned(
                left: 0,
                right: 0,
                top: px(510),
                child: _TabRow(k: k),
              ),

              // ---- Card carousel ----
              Positioned(
                left: 0,
                right: 0,
                top: px(598),
                height: px(482),
                child: _CardCarousel(k: k),
              ),

              // ---- PIN pill ----
              Positioned(
                left: 0,
                right: 0,
                top: px(1575),
                child: Center(child: _PinPill(k: k)),
              ),

              // ---- Bottom navigation ----
              Positioned(
                left: px(64),
                right: px(64),
                top: px(1840),
                child: _BottomNav(k: k),
              ),

              // ---- Home indicator ----
              Positioned(
                left: 0,
                right: 0,
                bottom: px(30),
                child: Center(
                  child: Container(
                    width: px(330),
                    height: px(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A5A5C),
                      borderRadius: BorderRadius.circular(px(6)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status bar replica
// ---------------------------------------------------------------------------
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Padding(
      padding: EdgeInsets.only(left: px(64), right: px(52), top: px(30)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '10:42',
            style: TextStyle(
              color: Colors.white,
              fontSize: px(40),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: px(14)),
          Icon(Icons.fingerprint, color: Colors.white, size: px(34)),
          SizedBox(width: px(12)),
          Icon(Icons.warning_amber_rounded,
              color: Colors.white, size: px(30)),
          SizedBox(width: px(12)),
          Icon(Icons.download_rounded, color: Colors.white, size: px(30)),
          SizedBox(width: px(10)),
          Container(
            width: px(10),
            height: px(10),
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const Spacer(),
          Icon(Icons.volume_off, color: Colors.white, size: px(34)),
          SizedBox(width: px(14)),
          Icon(Icons.wifi, color: Colors.white, size: px(34)),
          SizedBox(width: px(6)),
          Padding(
            padding: EdgeInsets.only(bottom: px(12)),
            child: Text('R',
                style: TextStyle(color: Colors.white, fontSize: px(20))),
          ),
          SizedBox(width: px(6)),
          Icon(Icons.signal_cellular_alt, color: Colors.white, size: px(34)),
          SizedBox(width: px(14)),
          // battery pill with "4"
          Container(
            padding: EdgeInsets.symmetric(horizontal: px(10), vertical: px(4)),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              borderRadius: BorderRadius.circular(px(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.priority_high, color: Colors.white, size: px(22)),
                Text('4',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: px(26),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Membership banner
// ---------------------------------------------------------------------------
class _Banner extends StatelessWidget {
  const _Banner({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Container(
      padding: EdgeInsets.fromLTRB(px(40), px(34), px(28), px(34)),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(px(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: px(110),
            height: px(90),
            child: CustomPaint(painter: _WalletIconPainter()),
          ),
          SizedBox(width: px(28)),
          Expanded(
            child: Text(
              'Add your membership cards to get and use points.',
              style: TextStyle(
                color: const Color(0xFFEDEDEF),
                fontSize: px(35),
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: px(20)),
          Container(
            width: px(58),
            height: px(58),
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, color: const Color(0xFFD8D8DA), size: px(34)),
          ),
        ],
      ),
    );
  }
}

class _WalletIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.12, w, h * 0.8), Radius.circular(h * 0.22));
    // body
    canvas.drawRRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6A04A), Color(0xFFE07C2E)],
          ).createShader(r.outerRect));
    // flap
    final flap = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.05, w * 0.86, h * 0.42),
        Radius.circular(h * 0.16));
    canvas.drawRRect(flap, Paint()..color = const Color(0xFFF7B267));
    // clasp
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.66, h * 0.42, w * 0.22, h * 0.24),
            Radius.circular(h * 0.08)),
        Paint()..color = const Color(0xFFB8611F));
    canvas.drawCircle(Offset(w * 0.77, h * 0.54), h * 0.05,
        Paint()..color = const Color(0xFFF7B267));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Tab row : Vouchers | Memberships
// ---------------------------------------------------------------------------
class _TabRow extends StatelessWidget {
  const _TabRow({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: px(58),
          height: px(58),
          child: CustomPaint(painter: _TagIconPainter()),
        ),
        SizedBox(width: px(20)),
        Text('Vouchers',
            style: TextStyle(
                color: Colors.white,
                fontSize: px(42),
                fontWeight: FontWeight.w700)),
        SizedBox(width: px(34)),
        Container(width: px(2), height: px(46), color: const Color(0xFF3A3A3C)),
        SizedBox(width: px(34)),
        SizedBox(
          width: px(58),
          height: px(58),
          child: CustomPaint(painter: _BarcodeIconPainter()),
        ),
        SizedBox(width: px(20)),
        Text('Memberships',
            style: TextStyle(
                color: Colors.white,
                fontSize: px(42),
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TagIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.10, h * 0.30)
      ..lineTo(w * 0.55, h * 0.30)
      ..lineTo(w * 0.92, h * 0.66)
      ..lineTo(w * 0.47, h * 0.66)
      ..close();
    // rounded tag
    final rp = Paint()
      ..color = const Color(0xFFC79A5B)
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, rp);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.5, h * 0.4),
            Radius.circular(h * 0.12)),
        rp);
    // hole
    canvas.drawCircle(Offset(w * 0.24, h * 0.44), h * 0.055,
        Paint()..color = const Color(0xFF000000));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarcodeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.84, h * 0.44),
        Radius.circular(h * 0.14));
    canvas.drawRRect(r, Paint()..color = const Color(0xFFE39BB0));
    final bar = Paint()..color = const Color(0xFF7A2A3E);
    final xs = [0.24, 0.34, 0.40, 0.52, 0.62, 0.72];
    final ws = [0.03, 0.05, 0.03, 0.06, 0.03, 0.05];
    for (var i = 0; i < xs.length; i++) {
      canvas.drawRect(
          Rect.fromLTWH(w * xs[i], h * 0.36, w * ws[i], h * 0.28), bar);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Card carousel
// ---------------------------------------------------------------------------
class _CardCarousel extends StatelessWidget {
  const _CardCarousel({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // peeking card to the left
        Positioned(
          left: px(-830),
          top: px(24),
          child: Container(
            width: px(896),
            height: px(462),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(px(30)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF223A6A), Color(0xFF101B33)],
              ),
            ),
          ),
        ),
        // peeking card to the right
        Positioned(
          left: px(1024),
          top: px(24),
          child: Container(
            width: px(896),
            height: px(462),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(px(30)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF223A6A), Color(0xFF101B33)],
              ),
            ),
          ),
        ),
        // main FAB card
        Positioned(
          left: px(92),
          top: 0,
          child: _FabCard(k: k),
        ),
      ],
    );
  }
}

class _FabCard extends StatelessWidget {
  const _FabCard({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Container(
      width: px(896),
      height: px(482),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(px(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: px(30),
            offset: Offset(0, px(10)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(px(30)),
        child: Stack(
          children: [
            // gradient + waves
            Positioned.fill(child: CustomPaint(painter: _CardWavePainter())),
            // debit
            Positioned(
              left: px(76),
              top: px(60),
              child: Text('debit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: px(46),
                      fontWeight: FontWeight.w400)),
            ),
            // platinum
            Positioned(
              left: px(40),
              top: px(212),
              child: Text('platinum',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: px(42),
                      fontWeight: FontWeight.w400)),
            ),
            // masked number
            Positioned(
              left: px(38),
              top: px(372),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _dots(px),
                  SizedBox(width: px(20)),
                  Text('3363',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: px(58),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5)),
                ],
              ),
            ),
            // FAB logo (top-right)
            Positioned(
              right: px(40),
              top: px(44),
              child: _FabLogo(k: k),
            ),
            // contactless
            Positioned(
              right: px(52),
              top: px(196),
              child: SizedBox(
                width: px(70),
                height: px(70),
                child: CustomPaint(painter: _ContactlessPainter()),
              ),
            ),
            // mastercard
            Positioned(
              right: px(60),
              bottom: px(48),
              child: SizedBox(
                width: px(180),
                height: px(120),
                child: CustomPaint(painter: _MastercardPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dots(double Function(double) px) {
    return Row(
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(right: px(10)),
          child: Container(
            width: px(16),
            height: px(16),
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _CardWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // base navy gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF223B6E), Color(0xFF13243F)],
        ).createShader(rect),
    );

    // draw concentric arcs emanating from a point off the right edge to make
    // the flowing "sound wave" pattern that fans across the card.
    final center = Offset(w * 1.02, h * 0.46);
    for (int i = 0; i < 26; i++) {
      final radius = h * (0.10 + i * 0.085);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.012
        ..color = const Color(0xFF6E8DBE).withValues(alpha: 0.32);
      canvas.drawCircle(center, radius, paint);
    }

    // subtle diagonal seam on the right third
    final seam = Path()
      ..moveTo(w * 0.66, 0)
      ..lineTo(w * 0.56, h);
    canvas.drawPath(
        seam,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.006
          ..color = const Color(0xFF9FB6DB).withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FabLogo extends StatelessWidget {
  const _FabLogo({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Arabic name
        Text(
          'بنك أبوظبي الأول',
          textDirection: TextDirection.rtl,
          style: TextStyle(
              color: Colors.white,
              fontSize: px(22),
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: px(4)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FAB',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: px(66),
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1)),
            SizedBox(width: px(4)),
            Padding(
              padding: EdgeInsets.only(top: px(4)),
              child: SizedBox(
                width: px(34),
                height: px(46),
                child: CustomPaint(painter: _FabFlagPainter()),
              ),
            ),
          ],
        ),
        SizedBox(height: px(2)),
        Text('First Abu Dhabi Bank',
            style: TextStyle(
                color: Colors.white,
                fontSize: px(20),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FabFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(w, h * 0.12)
      ..lineTo(w * 0.42, h * 0.5)
      ..lineTo(w, h * 0.88)
      ..lineTo(0, h)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFE1261C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ContactlessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    final center = Offset(-w * 0.15, h * 0.5);
    for (int i = 0; i < 4; i++) {
      paint.strokeWidth = h * 0.06;
      final radius = w * (0.35 + i * 0.22);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -0.6,
        1.2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MastercardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = h * 0.44;
    final left = Offset(w * 0.36, h * 0.5);
    final right = Offset(w * 0.64, h * 0.5);

    // red circle
    canvas.drawCircle(left, r, Paint()..color = const Color(0xFFEB001B));
    // amber circle
    canvas.drawCircle(right, r, Paint()..color = const Color(0xFFF79E1B));
    // overlap -> orange
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: left, radius: r)));
    canvas.drawCircle(right, r, Paint()..color = const Color(0xFFFF5F00));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// PIN pill
// ---------------------------------------------------------------------------
class _PinPill extends StatelessWidget {
  const _PinPill({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: px(64), vertical: px(24)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2C),
        borderRadius: BorderRadius.circular(px(50)),
      ),
      child: Text('PIN',
          style: TextStyle(
              color: Colors.white,
              fontSize: px(40),
              fontWeight: FontWeight.w600,
              letterSpacing: 1)),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation
// ---------------------------------------------------------------------------
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.k});
  final double k;

  @override
  Widget build(BuildContext context) {
    px(double v) => v * k;
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('Quick access',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: px(44),
                      fontWeight: FontWeight.w700)),
              SizedBox(height: px(14)),
              Container(
                width: px(250),
                height: px(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(px(4)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text('All',
                style: TextStyle(
                    color: const Color(0xFF9A9A9C),
                    fontSize: px(44),
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}
