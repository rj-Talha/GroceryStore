import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final AlignmentGeometry alignment;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Color? color;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.border,
    this.alignment = Alignment.center,
    this.gradient,
    this.boxShadow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius as BorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          alignment: alignment,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Daana.glass,
            gradient: gradient,
            borderRadius: borderRadius as BorderRadius,
            border: border ?? Border.all(color: Daana.hairlineSoft),
            boxShadow: boxShadow ?? Daana.softShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
