import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Daana — premium grocery design tokens.
class Daana {
  static const Color bg = Color(0xFFEAFBF1);
  static const Color bgAlt = Color(0xFFF4FFF8);
  static const Color card = Color(0xE6FFFFFF);
  static const Color glass = Color(0xDEFFFFFF);

  static const Color ink = Color(0xFF1E352B);
  static const Color ink80 = Color(0xCC1E352B);
  static const Color ink70 = Color(0xB31E352B);
  static const Color ink60 = Color(0x991E352B);
  static const Color ink50 = Color(0x801E352B);
  static const Color ink40 = Color(0x661E352B);
  static const Color ink30 = Color(0x4D1E352B);
  static const Color ink20 = Color(0x331E352B);
  static const Color ink15 = Color(0x271E352B);
  static const Color ink08 = Color(0x141E352B);
  static const Color white = Color(0xFFFFFFFF);

  static const Color moss = Color(0xFF2E5B41);
  static const Color mossDark = Color(0xFF17402C);
  static const Color mossInk = Color(0xFF395A4A);
  static const Color sage = Color(0xFF7EBF92);
  static const Color mint = Color(0xFFB8E5C8);
  static const Color olive = Color(0xFF9DBB9C);
  static const Color saffron = Color(0xFFD18D3F);

  static const Gradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEAFBF1), Color(0xFFDDF7EA), Color(0xFFF6FFF8), Color(0xFFEEFDF4)],
    stops: [0.0, 0.35, 0.71, 1.0],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FEF7)],
  );

  static Color hairline = const Color(0xFF1E352B).withAlpha(30);
  static Color hairlineSoft = const Color(0xFF1E352B).withAlpha(18);

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0A2D1E).withAlpha(22),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: const Color(0xFF61C485).withAlpha(60),
          blurRadius: 32,
          offset: const Offset(0, 10),
        ),
      ];

  // ── Type ──────────────────────────────────────────────────
  static TextStyle serif({
    double size = 16,
    Color? color,
    FontStyle? style,
    double height = 1.0,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: size,
          color: color ?? ink,
          fontStyle: style ?? FontStyle.normal,
          height: height,
          letterSpacing: -0.02 * size,
          fontWeight: weight,
        ),
      );

  static TextStyle sans({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: size,
          color: color ?? ink,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing ?? -0.005 * size,
        ),
      );

  static TextStyle mono({
    double size = 10.5,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 1.6,
  }) =>
      GoogleFonts.jetBrainsMono(
        textStyle: TextStyle(
          fontSize: size,
          color: color ?? ink70,
          fontWeight: weight,
          letterSpacing: letterSpacing,
        ),
      );

  static TextStyle urdu({
    double size = 18,
    Color? color,
    double height = 1.9,
  }) =>
      GoogleFonts.notoNastaliqUrdu(
        textStyle: TextStyle(
          fontSize: size,
          color: color ?? ink,
          height: height,
        ),
      );
}
