import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';

enum BtnVariant { primary, moss, ghost, quiet, soft, light }

enum BtnSize { sm, md, lg }

class Btn extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final BtnSize size;
  final String? icon;
  final String? iconRight;
  final bool full;
  final EdgeInsetsGeometry? padding;

  const Btn(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.md,
    this.icon,
    this.iconRight,
    this.full = false,
    this.padding,
  });

  @override
  State<Btn> createState() => _BtnState();
}

class _BtnState extends State<Btn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dims = switch (widget.size) {
      BtnSize.sm => (h: 36.0, px: 14.0, fs: 13.0),
      BtnSize.md => (h: 44.0, px: 18.0, fs: 14.0),
      BtnSize.lg => (h: 52.0, px: 24.0, fs: 15.0),
    };

    final style = switch (widget.variant) {
      BtnVariant.primary => _BtnStyle(
            gradient: const LinearGradient(
              colors: [Daana.mint, Daana.sage],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            foreground: Daana.mossDark,
            border: Colors.transparent,
          ),
      BtnVariant.moss => _BtnStyle(
            gradient: const LinearGradient(
              colors: [Daana.mossDark, Daana.moss],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            foreground: Daana.white,
            border: Colors.transparent,
          ),
      BtnVariant.ghost => _BtnStyle(
            gradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
            foreground: Daana.ink,
            border: Daana.hairline,
          ),
      BtnVariant.quiet => _BtnStyle(
            gradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
            foreground: Daana.ink,
            border: Colors.transparent,
          ),
      BtnVariant.soft => _BtnStyle(
            gradient: const LinearGradient(colors: [Daana.glass, Daana.glass]),
            foreground: Daana.ink,
            border: Colors.transparent,
          ),
      BtnVariant.light => _BtnStyle(
            gradient: const LinearGradient(colors: [Daana.bgAlt, Daana.bgAlt]),
            foreground: Daana.ink,
            border: Colors.transparent,
          ),
    };

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: _pressed ? 0.98 : 1.0,
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: widget.full ? double.infinity : null,
        height: dims.h,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: style.gradient,
              borderRadius: BorderRadius.circular(999),
              border: style.border != Colors.transparent ? Border.all(color: style.border) : null,
              boxShadow: widget.onPressed != null
                  ? [
                      BoxShadow(
                        color: style.gradient.colors.last.withAlpha(50),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: widget.onPressed,
                child: Container(
                  alignment: Alignment.center,
                  padding: widget.padding ?? EdgeInsets.symmetric(horizontal: dims.px),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        DaanaIcon(widget.icon!, size: dims.fs + 2, color: style.foreground),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: Daana.sans(
                            size: dims.fs,
                            color: style.foreground,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.iconRight != null) ...[
                        const SizedBox(width: 8),
                        DaanaIcon(widget.iconRight!, size: dims.fs + 2, color: style.foreground),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BtnStyle {
  final Gradient gradient;
  final Color foreground;
  final Color border;

  const _BtnStyle({required this.gradient, required this.foreground, required this.border});
}

class DChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final String? icon;

  const DChip(this.label, {super.key, this.active = false, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? Daana.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? Daana.ink : Daana.hairline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              DaanaIcon(icon!, size: 14, color: active ? Daana.bg : Daana.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Daana.sans(
                size: 13,
                color: active ? Daana.bg : Daana.ink,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
