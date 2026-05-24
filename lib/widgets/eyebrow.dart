import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Small caps section label in mono — "EYEBROW".
class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const Eyebrow(this.text, {super.key, this.color, this.size = 10.5});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Daana.mono(
        size: size,
        color: color ?? Daana.ink50,
        letterSpacing: 1.7,
      ),
    );
  }
}
