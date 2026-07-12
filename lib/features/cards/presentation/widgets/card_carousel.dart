import 'package:flutter/material.dart';

import '../../domain/models/card_template.dart';
import 'wallet_card_widget.dart';

/// Centred card carousel with peeking neighbours (single hero card, adjacent
/// cards scaled down and dimmed at the edges).
///
/// Performance: the per-frame transforms are driven directly off the
/// [PageController] via an [AnimatedBuilder], so scrolling never calls
/// setState and never rebuilds the [PageView] or its (network-backed)
/// children. Each card sits behind a [RepaintBoundary].
class CardCarousel extends StatefulWidget {
  final List<CardTemplate> cards;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onTapCard;

  const CardCarousel({
    super.key,
    required this.cards,
    this.initialIndex = 0,
    this.onPageChanged,
    this.onTapCard,
  });

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _controller;
  late final AnimationController _tapPop;
  int _revealedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.86,
      initialPage: widget.initialIndex,
    );
    _tapPop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
      value: 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tapPop.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    setState(() => _revealedIndex = _revealedIndex == index ? -1 : index);
    _tapPop.forward(from: 0);
    widget.onTapCard?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.cards.length,
      onPageChanged: widget.onPageChanged,
      physics: const BouncingScrollPhysics(),
      padEnds: true,
      itemBuilder: (context, index) {
        final card = widget.cards[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(index),
          child: AnimatedBuilder(
            // Rebuilds only the transform as the user scrolls — cheap.
            animation: Listenable.merge([_controller, _tapPop]),
            builder: (context, child) {
              double page;
              if (_controller.hasClients &&
                  _controller.position.haveDimensions) {
                page = _controller.page ?? widget.initialIndex.toDouble();
              } else {
                page = widget.initialIndex.toDouble();
              }
              final delta = (index - page).abs().clamp(0.0, 1.0);
              // Neighbours: scale down + fade.
              final scale = 1 - (delta * 0.14);
              final opacity = 1 - (delta * 0.35);
              // Elastic pop on the just-tapped card.
              final isRevealed = _revealedIndex == index;
              final pop = (isRevealed && delta < 0.02)
                  ? Curves.elasticOut.transform(_tapPop.value) * 0.04
                  : 0.0;
              return Opacity(
                opacity: opacity.clamp(0.55, 1.0),
                child: Transform.scale(
                  scale: (scale + (delta < 0.02 ? pop : 0)).clamp(0.80, 1.05),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: WalletCardWidget(
                card: card,
                revealed: _revealedIndex == index,
              ),
            ),
          ),
        );
      },
    );
  }
}
