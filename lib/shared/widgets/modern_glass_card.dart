import 'package:flutter/material.dart';

/// A premium Material 3 card with clean, modern aesthetics.
///
/// Features:
/// - Soft, layered shadows for depth
/// - Optional primary color tint on the top edge
/// - Configurable padding, margin, and border radius
///
/// Usage:
/// ```dart
/// ModernGlassCard(
///   child: Text('Your content'),
///   tintColor: Theme.of(context).colorScheme.primary,
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

  /// Legacy parameter — ignored. Kept for API compatibility.
  final bool glass;

  /// Custom border radius. Defaults to 16px.
  final double? borderRadius;

  /// Custom elevation. Defaults to 0 (shadows handled by decoration).
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
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? 16.0;
    final cardColor = theme.colorScheme.surfaceContainerLow;

    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: cardColor,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.3),
          width: 1,
        ),
        boxShadow: [
          // Soft ambient shadow
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          // Tight contact shadow
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top tint accent line
            if (tintColor != null)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tintColor!,
                      tintColor!.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
