import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(decoration: const BoxDecoration(gradient: Daana.bgGradient)),
        Positioned(
          top: -70,
          left: -70,
          child: _GlowCircle(size: 220, color: Daana.sage.withAlpha(80)),
        ),
        Positioned(
          top: 80,
          right: -80,
          child: _GlowCircle(size: 260, color: Daana.mint.withAlpha(90)),
        ),
        Positioned(
          bottom: -40,
          left: -40,
          child: _GlowCircle(size: 240, color: Daana.olive.withAlpha(70)),
        ),
        Positioned(
          bottom: 100,
          right: -50,
          child: _LeafBlur(size: 180, rotation: -0.16),
        ),
        Positioned(
          top: 160,
          left: 20,
          child: _LeafBlur(size: 120, rotation: 0.18),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

class _LeafBlur extends StatelessWidget {
  final double size;
  final double rotation;

  const _LeafBlur({required this.size, required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Opacity(
        opacity: 0.14,
        child: Container(
          width: size,
          height: size * 0.55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            gradient: LinearGradient(
              colors: [Daana.sage.withAlpha(70), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
