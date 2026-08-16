import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// A "liquid glass" panel (Apple-style refraction, not just a flat blur) —
/// renders via Impeller, so it only works on iOS/Android, not web/desktop.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 10,
    this.thickness = 20,
    this.opacity = 0.25,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double thickness;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LiquidGlassLayer(
      settings: LiquidGlassSettings(
        thickness: thickness,
        blur: blur,
        glassColor: scheme.surface.withValues(alpha: opacity),
      ),
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
