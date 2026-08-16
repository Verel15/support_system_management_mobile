import 'package:flutter/material.dart';

/// Fixed brand palette (login, onboarding, ...) — deliberately not pulled
/// from [ColorScheme] since it's a constant brand look, independent of the
/// app's seeded Material theme.
class BrandColors {
  BrandColors._();

  static const backgroundStart = Color(0xFFE3F6EF);
  static const backgroundEnd = Color(0xFFD6ECFB);
  static const brandStart = Color(0xFF22C55E);
  static const brandEnd = Color(0xFF0EA5E9);
  static const navy = Color(0xFF0F172A);
  static const teal = Color(0xFF0D9488);
  static const muted = Color(0xFF64748B);
  static const fieldIcon = Color(0xFF94A3B8);
}
