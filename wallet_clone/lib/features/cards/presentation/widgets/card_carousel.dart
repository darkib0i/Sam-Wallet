import 'package:flutter/material.dart';
import '../../../animations/spring_tap.dart';
import '../../domain/card_template.dart';
import 'wallet_card.dart';

/// Horizontal coverflow: the centred card is full-size while neighbours scale
/// down and fade, matching the Samsung Wallet carousel feel.
class CardCarousel extends StatefulWidget {
  const CardCarousel({
    super.key,
    required this.cards,
    required this.revealedId,
    required this.onPageChanged,
    required this.onCardTapped,
  });

  final List<CardTemplate> cards;
  final int? revealedId;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<CardTemplate> onCardTapped;

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  late final PageController _controller =
      PageController(viewportFraction: 0.82);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('No cards match your search',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.cards.length,
        onPageChanged: widget.onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final delta = (_page - index).abs().clamp(0.0, 1.0);
          final scale = 1 - delta * 0.16;
          final opacity = 1 - delta * 0.4;
          final card = widget.cards[index];
          return Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SpringTap(
                    onTap: () => widget.onCardTapped(card),
                    child: WalletCard(
                      card: card,
                      revealed: widget.revealedId == card.id,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
