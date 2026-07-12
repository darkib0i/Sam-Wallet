import 'package:flutter/material.dart';

import '../../domain/models/card_template.dart';
import 'wallet_card_widget.dart';

/// Coverflow-style carousel: a [PageView] whose neighbours scale down, with a
/// bouncy spring scale + tap-to-reveal on the centred card.
class CardCarousel extends StatefulWidget {
  final List<CardTemplate> cards;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  const CardCarousel({
    super.key,
    required this.cards,
    this.initialIndex = 0,
    this.onPageChanged,
  });

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _controller;
  late final AnimationController _bounce;
  late final Animation<double> _spring;
  double _page = 0;
  int _revealedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.82,
      initialPage: widget.initialIndex,
    )..addListener(_onScroll);
    _page = widget.initialIndex.toDouble();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    // elasticOut gives the bouncy overshoot-and-settle "pop".
    _spring = CurvedAnimation(parent: _bounce, curve: Curves.elasticOut);
  }

  void _onScroll() {
    setState(() => _page = _controller.page ?? _page);
  }

  @override
  void didUpdateWidget(covariant CardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards.length != widget.cards.length) {
      _revealedIndex = -1;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
        _page = 0;
      }
    }
  }

  void _handleTap(int index) {
    setState(() {
      _revealedIndex = _revealedIndex == index ? -1 : index;
    });
    _bounce
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.cards.length,
      onPageChanged: widget.onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final delta = index - _page;
        // Neighbours scale down (coverflow); centre card is full size.
        final baseScale = (1 - (delta.abs() * 0.16)).clamp(0.80, 1.0);
        final revealed = _revealedIndex == index;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(index),
          child: AnimatedBuilder(
            animation: _spring,
            builder: (context, child) {
              final isCentre = delta.abs() < 0.5;
              // Small elastic pop overlaid on the coverflow scale.
              final pop = (isCentre && revealed) ? (_spring.value * 0.05) : 0.0;
              return Transform.scale(
                scale: baseScale + pop,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 24 * (1 - baseScale) + 8,
                    horizontal: 6,
                  ),
                  child: child,
                ),
              );
            },
            child: WalletCardWidget(
              card: widget.cards[index],
              revealed: revealed,
            ),
          ),
        );
      },
    );
  }
}
