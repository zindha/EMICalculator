import 'package:flutter/material.dart';

/// A premium Material 3 card with clean, modern aesthetics.
///
/// Features:
/// - Optional primary color tint on the top edge
/// - Configurable padding, margin, and border radius
///
/// Usage:
/// ```dart
/// ModernCard(
///   child: Text('Your content'),
///   tintColor: Theme.of(context).colorScheme.primary,
/// )
/// ```
class ModernCard extends StatelessWidget {
  /// Creates a [ModernCard].
  const ModernCard({
    super.key,
    required this.child,
    this.tintColor,
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

    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation ?? 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant
              .withValues(alpha: isDark ? 0.15 : 0.3),
          width: 1,
        ),
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
                color: tintColor,
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: card,
      );
    }

    return card;
  }
}
