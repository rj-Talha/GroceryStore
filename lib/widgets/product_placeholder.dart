import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Diagonally-striped SVG-style placeholder with a small monospace label.
/// "No AI-drawn produce" — principle 03.
class ProductPlaceholder extends StatelessWidget {
  final String label;
  final String tone;
  final double radius;
  final bool square;

  const ProductPlaceholder({
    super.key,
    this.label = '',
    this.tone = 'a',
    this.radius = 12,
    this.square = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = _tones[tone] ?? _tones['a']!;
    return AspectRatio(
      aspectRatio: square ? 1.0 : 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: t.bg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _StripePainter(t.stripe)),
              if (label.isNotEmpty)
                Center(
                  child: Text(
                    label.toUpperCase(),
                    style: Daana.mono(
                      size: 10,
                      color: t.ink,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tone {
  final Color bg;
  final Color stripe;
  final Color ink;
  const _Tone(this.bg, this.stripe, this.ink);
}

const Map<String, _Tone> _tones = {
  'a': _Tone(Color(0xFFE8E2D2), Color(0xFFD9D0BC), Color(0x8C1A1814)),
  'b': _Tone(Color(0xFFDDE2D5), Color(0xFFCBD3C0), Color(0xB3283D26)),
  'c': _Tone(Color(0xFFEBDFD0), Color(0xFFDECBB4), Color(0xB3784B1E)),
  'd': _Tone(Color(0xFFE0DED7), Color(0xFFCFCCC2), Color(0x8C1A1814)),
  'e': _Tone(Color(0xFFD8DBD3), Color(0xFFC5C9BD), Color(0x991A1814)),
};

class _StripePainter extends CustomPainter {
  final Color stripe;
  _StripePainter(this.stripe);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripe.withOpacity(0.55)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.785398); // 45deg
    final extent = (size.width + size.height);
    for (double x = -extent; x < extent; x += 14) {
      canvas.drawLine(Offset(x, -extent), Offset(x, extent), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.stripe != stripe;
}
