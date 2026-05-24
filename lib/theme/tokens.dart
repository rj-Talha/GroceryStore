import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Daana — design tokens.
/// Warm cream paper, deep ink, single moss accent. Bilingual EN/UR.
class Daana {
  static const Color bg = Color(0xFFF6F3EC);
  static const Color bgAlt = Color(0xFFEFEBE0);
  static const Color card = Color(0xFFFBF9F3);

  static const Color ink = Color(0xFF1A1814);
  static Color ink70 = ink.withOpacity(0.7);
  static Color ink50 = ink.withOpacity(0.5);
  static Color ink30 = ink.withOpacity(0.3);
  static Color ink15 = ink.withOpacity(0.15);
  static Color ink08 = ink.withOpacity(0.08);

  static const Color moss = Color(0xFF3D5A3A);
  static const Color mossInk = Color(0xFF283D26);

  static const Color saffron = Color(0xFFB8703A);
  static const Color goldHighlight = Color(0xFFC8B583);

  static Color hairline = ink.withOpacity(0.12);
  static Color hairlineSoft = ink.withOpacity(0.06);

  // ── Type ──────────────────────────────────────────────────
  static TextStyle serif({
    double size = 16,
    Color? color,
    FontStyle? style,
    double height = 1.0,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.instrumentSerif(
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
      GoogleFonts.inter(
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
