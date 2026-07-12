import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loads a monochrome network logo (SVG) from the public CDN and tints it to
/// [color]. Falls back to a stylised text chip if the logo can't be fetched
/// (e.g. offline), so the card never renders broken.
class NetworkLogo extends StatelessWidget {
  final String url;
  final String networkName;
  final Color color;
  final double height;

  const NetworkLogo({
    super.key,
    required this.url,
    required this.networkName,
    required this.color,
    this.height = 26,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => _fallback(),
      // If the network fetch fails, SvgPicture shows the placeholder, so the
      // fallback chip covers both loading and error states.
    );
  }

  Widget _fallback() {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        networkName.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: height * 0.42,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
