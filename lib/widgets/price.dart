import 'package:flutter/material.dart';
import '../data/products.dart';
import '../theme/tokens.dart';

class PriceText extends StatelessWidget {
  final int value;
  final double size;
  final Color? color;
  final String currency;

  const PriceText({
    super.key,
    required this.value,
    this.size = 16,
    this.color,
    this.currency = 'Rs',
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Daana.ink;
    return RichText(
      text: TextSpan(
        style: Daana.sans(size: size, color: c, letterSpacing: -0.01 * size),
        children: [
          TextSpan(
            text: '$currency ',
            style: Daana.sans(
              size: size * 0.7,
              color: Daana.ink50,
              letterSpacing: 0,
            ),
          ),
          TextSpan(
            text: Products.formatRs(value),
            style: Daana.sans(
              size: size,
              color: c,
              letterSpacing: -0.01 * size,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
