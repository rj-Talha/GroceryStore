import 'package:flutter/material.dart';

/// Line icons painted from SVG path data, mirroring the screens-shared.jsx set.
/// All icons render in a 24x24 grid with rounded line caps and 1.5px stroke.
class DaanaIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double stroke;

  const DaanaIcon(
    this.name, {
    super.key,
    this.size = 18,
    this.color = const Color(0xFF1A1814),
    this.stroke = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IconPainter(name: name, color: color, stroke: stroke),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  final String name;
  final Color color;
  final double stroke;
  _IconPainter({required this.name, required this.color, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final s = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(scale);

    void path(String d) => canvas.drawPath(_parse(d), s);
    void circle(double cx, double cy, double r) =>
        canvas.drawCircle(Offset(cx, cy), r, s);
    void rect(double x, double y, double w, double h, [double r = 0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          Radius.circular(r),
        ),
        s,
      );
    }

    switch (name) {
      case 'search':
        circle(11, 11, 7);
        path('M20 20 L16.5 16.5');
        break;
      case 'mic':
        rect(9, 3, 6, 12, 3);
        path('M5 11 a7 7 0 0 0 14 0 M12 18 v3');
        break;
      case 'cart':
        path('M3 4 h2 l2.6 12.3 a2 2 0 0 0 2 1.7 h7.8 a2 2 0 0 0 2 -1.6 L21 8 H6');
        circle(10, 21, 1.2);
        circle(18, 21, 1.2);
        break;
      case 'bag':
        path('M5 8 h14 l-1 12 a2 2 0 0 1 -2 2 H8 a2 2 0 0 1 -2 -2 L5 8 z M9 8 V6 a3 3 0 0 1 6 0 v2');
        break;
      case 'user':
        circle(12, 8, 4);
        path('M4 21 a8 8 0 0 1 16 0');
        break;
      case 'heart':
        path('M12 20 s-7 -4.5 -7 -10 a4 4 0 0 1 7 -2.6 A4 4 0 0 1 19 10 c0 5.5 -7 10 -7 10 z');
        break;
      case 'plus':
        path('M12 5 v14 M5 12 h14');
        break;
      case 'minus':
        path('M5 12 h14');
        break;
      case 'chevR':
        path('M9 6 L15 12 L9 18');
        break;
      case 'chevL':
        path('M15 6 L9 12 L15 18');
        break;
      case 'chevD':
        path('M6 9 L12 15 L18 9');
        break;
      case 'arrowR':
        path('M5 12 h14 M14 6 L20 12 L14 18');
        break;
      case 'arrowUp':
        path('M12 5 v14 M5 12 L12 5 L19 12');
        break;
      case 'close':
        path('M6 6 L18 18 M18 6 L6 18');
        break;
      case 'sparkle':
        path('M12 3 v6 M12 15 v6 M3 12 h6 M15 12 h6');
        // diagonals
        final faint = Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(_parse('M5.6 5.6 L9 9 M15 15 L18.4 18.4 M5.6 18.4 L9 15 M15 9 L18.4 5.6'), faint);
        break;
      case 'leaf':
        path('M5 19 c0 -9 7 -14 14 -14 c0 9 -5 14 -14 14 z M5 19 c4 -4 8 -7 11 -9');
        break;
      case 'clock':
        circle(12, 12, 9);
        path('M12 7 v5 L15 14');
        break;
      case 'pin':
        path('M12 21 s7 -7 7 -12 a7 7 0 1 0 -14 0 c0 5 7 12 7 12 z');
        circle(12, 9, 2.5);
        break;
      case 'filter':
        path('M4 6 h16 M7 12 h10 M10 18 h4');
        break;
      case 'grid':
        rect(4, 4, 7, 7, 1);
        rect(13, 4, 7, 7, 1);
        rect(4, 13, 7, 7, 1);
        rect(13, 13, 7, 7, 1);
        break;
      case 'home':
        path('M4 11 L12 4 L20 11 V20 a1 1 0 0 1 -1 1 H15 V15 H9 V21 H5 a1 1 0 0 1 -1 -1 V11 z');
        break;
      case 'chef':
        path('M7 14 a5 5 0 1 1 10 0 V20 H7 V14 z M9 14 V9 a3 3 0 0 1 6 0 V14');
        break;
      case 'book':
        path('M4 5 a2 2 0 0 1 2 -2 H18 V21 H6 a2 2 0 0 1 -2 -2 V5 z M4 19 a2 2 0 0 1 2 -2 H18');
        break;
      case 'truck':
        path('M3 7 H14 V16 H3 z M14 10 H18 L21 13 V16 H14');
        circle(7, 18, 2);
        circle(17, 18, 2);
        break;
      case 'check':
        path('M5 12 L10 17 L20 7');
        break;
      case 'info':
        circle(12, 12, 9);
        path('M12 8 v0.01 M12 11 v6');
        break;
      case 'star':
        path('M12 3 L14.6 8.5 L20.6 9.3 L16.2 13.5 L17.3 19.5 L12 16.8 L6.7 19.5 L7.8 13.5 L3.4 9.3 L9.4 8.5 L12 3 z');
        break;
      case 'flame':
        path('M12 3 c0 4 -5 5 -5 10 a5 5 0 0 0 10 0 c0 -3 -2 -4 -3 -6 c0 2 -1 3 -2 3 c0 -3 0 -5 0 -7 z');
        break;
      case 'waves':
        path('M3 12 c2 -3 4 -3 6 0 s4 3 6 0 s4 -3 6 0');
        break;
      case 'globe':
        circle(12, 12, 9);
        path('M3 12 h18 M12 3 a14 14 0 0 1 0 18 M12 3 a14 14 0 0 0 0 18');
        break;
    }
    canvas.restore();
  }

  Path _parse(String d) {
    final path = Path();
    final tokens = d.replaceAll(',', ' ').split(RegExp(r'(?=[a-zA-Z])'));
    double cx = 0, cy = 0;
    for (final tok in tokens) {
      final t = tok.trim();
      if (t.isEmpty) continue;
      final cmd = t[0];
      final nums = t
          .substring(1)
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .map(double.parse)
          .toList();
      switch (cmd) {
        case 'M':
          path.moveTo(nums[0], nums[1]);
          cx = nums[0];
          cy = nums[1];
          for (int i = 2; i + 1 < nums.length; i += 2) {
            path.lineTo(nums[i], nums[i + 1]);
            cx = nums[i];
            cy = nums[i + 1];
          }
          break;
        case 'm':
          path.moveTo(cx + nums[0], cy + nums[1]);
          cx += nums[0];
          cy += nums[1];
          break;
        case 'L':
          for (int i = 0; i + 1 < nums.length; i += 2) {
            path.lineTo(nums[i], nums[i + 1]);
            cx = nums[i];
            cy = nums[i + 1];
          }
          break;
        case 'l':
          for (int i = 0; i + 1 < nums.length; i += 2) {
            cx += nums[i];
            cy += nums[i + 1];
            path.lineTo(cx, cy);
          }
          break;
        case 'H':
          for (final n in nums) {
            path.lineTo(n, cy);
            cx = n;
          }
          break;
        case 'h':
          for (final n in nums) {
            cx += n;
            path.lineTo(cx, cy);
          }
          break;
        case 'V':
          for (final n in nums) {
            path.lineTo(cx, n);
            cy = n;
          }
          break;
        case 'v':
          for (final n in nums) {
            cy += n;
            path.lineTo(cx, cy);
          }
          break;
        case 'C':
          for (int i = 0; i + 5 < nums.length; i += 6) {
            path.cubicTo(
                nums[i], nums[i + 1], nums[i + 2], nums[i + 3], nums[i + 4], nums[i + 5]);
            cx = nums[i + 4];
            cy = nums[i + 5];
          }
          break;
        case 'c':
          for (int i = 0; i + 5 < nums.length; i += 6) {
            path.relativeCubicTo(
                nums[i], nums[i + 1], nums[i + 2], nums[i + 3], nums[i + 4], nums[i + 5]);
            cx += nums[i + 4];
            cy += nums[i + 5];
          }
          break;
        case 's':
          for (int i = 0; i + 3 < nums.length; i += 4) {
            path.relativeCubicTo(
                0, 0, nums[i], nums[i + 1], nums[i + 2], nums[i + 3]);
            cx += nums[i + 2];
            cy += nums[i + 3];
          }
          break;
        case 'A':
          for (int i = 0; i + 6 < nums.length; i += 7) {
            path.arcToPoint(
              Offset(nums[i + 5], nums[i + 6]),
              radius: Radius.elliptical(nums[i], nums[i + 1]),
              rotation: nums[i + 2],
              largeArc: nums[i + 3] != 0,
              clockwise: nums[i + 4] != 0,
            );
            cx = nums[i + 5];
            cy = nums[i + 6];
          }
          break;
        case 'a':
          for (int i = 0; i + 6 < nums.length; i += 7) {
            path.relativeArcToPoint(
              Offset(nums[i + 5], nums[i + 6]),
              radius: Radius.elliptical(nums[i], nums[i + 1]),
              rotation: nums[i + 2],
              largeArc: nums[i + 3] != 0,
              clockwise: nums[i + 4] != 0,
            );
            cx += nums[i + 5];
            cy += nums[i + 6];
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.name != name || old.color != color || old.stroke != stroke;
}
