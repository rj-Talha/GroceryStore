import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';

enum BtnVariant { primary, moss, ghost, quiet, soft, light }

enum BtnSize { sm, md, lg }

class Btn extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dims = switch (size) {
      BtnSize.sm => (h: 32.0, px: 12.0, fs: 13.0),
      BtnSize.md => (h: 40.0, px: 16.0, fs: 14.0),
      BtnSize.lg => (h: 48.0, px: 22.0, fs: 15.0),
    };

    final colors = switch (variant) {
      BtnVariant.primary => (bg: Daana.ink, fg: Daana.bg, border: Colors.transparent),
      BtnVariant.moss => (bg: Daana.moss, fg: Daana.bg, border: Colors.transparent),
      BtnVariant.ghost => (bg: Colors.transparent, fg: Daana.ink, border: Daana.hairline),
      BtnVariant.quiet => (bg: Colors.transparent, fg: Daana.ink, border: Colors.transparent),
      BtnVariant.soft => (bg: Daana.ink08, fg: Daana.ink, border: Colors.transparent),
      BtnVariant.light => (bg: Daana.bg, fg: Daana.ink, border: Colors.transparent),
    };

    final child = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          DaanaIcon(icon!, size: dims.fs + 2, color: colors.fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Daana.sans(
              size: dims.fs,
              color: colors.fg,
              weight: FontWeight.w500,
              letterSpacing: -0.005 * dims.fs,
            ),
          ),
        ),
        if (iconRight != null) ...[
          const SizedBox(width: 8),
          DaanaIcon(iconRight!, size: dims.fs + 2, color: colors.fg),
        ],
      ],
    );

    return SizedBox(
      width: full ? double.infinity : null,
      height: dims.h,
      child: Material(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: colors.border != Colors.transparent
                  ? Border.all(color: colors.border, width: 1)
                  : null,
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: dims.px),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
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
