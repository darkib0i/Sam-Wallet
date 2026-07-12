import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps [child] in a brief shimmer sweep used when secure details (full number
/// / CVV) "reveal" into view. When [active] is false the child renders plainly.
class ShimmerReveal extends StatelessWidget {
  final bool active;
  final Widget child;
  final Color baseColor;

  const ShimmerReveal({
    super.key,
    required this.active,
    required this.child,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1600),
      baseColor: baseColor.withValues(alpha: 0.55),
      highlightColor: baseColor,
      child: child,
    );
  }
}
