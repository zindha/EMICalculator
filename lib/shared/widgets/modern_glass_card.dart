import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A reusable Material 3 card with glassmorphism aesthetics.
///
/// Features:
/// - Subtle elevation with custom border radius
/// - Optional primary color tint on the top edge
/// - Glassmorphism effect (semi-transparent background + blur overlay)
/// - Configurable padding, margin, and elevation
///
/// Usage:
/// ```dart
/// ModernGlassCard(
///   child: Text('Your content'),
///   tintColor: Theme.of(context).colorScheme.primary,
///   glass: true,
/// )
/// ```
class ModernGlassCard extends StatelessWidget {
  /// Creates a [ModernGlassCard].
  const ModernGlassCard({
    super.key,
    required this.child,
    this.tintColor,
    this.glass = false,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  /// The child widget placed inside the card.
  final Widget child;

  /// Optional primary color tint applied as a top border accent.
  final Color? tintColor;

  /// Whether to apply the glassmorphism effect.
  ///
  /// When true, applies a semi-transparent background with a blur overlay.
  final bool glass;

  /// Custom border radius. Defaults to 16px.
  final double? borderRadius;

  /// Custom elevation. Defaults to 2.
  final double? elevation;

  /// Inner padding for the card content. Defaults to 20px.
  final EdgeInsetsGeometry? padding;

  /// Outer margin for the card. Defaults to 0.
  final EdgeInsetsGeometry? margin;

  /// Fixed width for the card. If null, card wraps its child.
  final double? width;

  /// Fixed height for the card. If null, card wraps its child.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? 16.0;
    final cardElevation = elevation ?? 2;

    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        elevation: cardElevation,
        borderRadius: BorderRadius.circular(radius),
        color: glass
            ? theme.colorScheme.surface.withValues(alpha: 0.7)
            : theme.cardColor,
        surfaceTintColor: tintColor?.withValues(alpha: 0.1),
        shadowColor: theme.shadowColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // Glassmorphism overlay
            color: glass
                ? (theme.brightness == Brightness.light
                    ? AppColors.glassLight
                    : AppColors.glassDark)
                : null,
            // Top tint accent line
            border: tintColor != null
                ? Border(
                    top: BorderSide(
                      color: tintColor!,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: glass
                  ? (theme.brightness == Brightness.light
                      ? _glassLightFilter
                      : _glassDarkFilter)
                  : _noFilter,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Light-mode glassmorphism blur filter.
  static const _glassLightFilter =
      ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 0.7, 0,
  ]);

  /// Dark-mode glassmorphism blur filter.
  static const _glassDarkFilter =
      ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 0.15, 0,
  ]);

  /// No-op filter for non-glass cards.
  static const _noFilter = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}
