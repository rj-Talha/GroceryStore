import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class DaanaWordmark extends StatelessWidget {
  final double size;
  final Color? color;
  final String? sub;
  const DaanaWordmark({super.key, this.size = 28, this.color, this.sub});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Daana.ink;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'daana',
              style: Daana.serif(size: size, color: c),
            ),
            TextSpan(
              text: '.',
              style: Daana.serif(size: size, color: Daana.moss),
            ),
          ]),
        ),
        if (sub != null) ...[
          const SizedBox(width: 8),
          Text(
            sub!.toUpperCase(),
            style: Daana.mono(
              size: size * 0.32,
              color: Daana.ink50,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ],
    );
  }
}
