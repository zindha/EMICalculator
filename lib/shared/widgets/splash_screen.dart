import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_info.dart';

/// A premium splash screen that displays the app icon and name,
/// then fades out after a brief delay to reveal the main app.
///
/// Uses a two-phase animation:
/// 1. Icon and text fade in with a subtle scale effect (0–600ms)
/// 2. Entire splash fades out (600–1200ms), then calls [onComplete]
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  /// Called when the splash animation finishes and the splash
  /// should be removed from the widget tree.
  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _exitController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _exitAnimation;

  @override
  void initState() {
    super.initState();

    // Phase 1: Fade in the content (0 → 600ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    // Phase 1b: Subtle scale from 0.92 → 1.0 (0 → 600ms)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Phase 2: Fade out the entire splash (after a hold).
    // Starts at 1.0 (fully visible) and reverses to 0.0 for the exit.
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _exitAnimation = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Start the entrance animations simultaneously
    _fadeController.forward();
    _scaleController.forward();

    // Hold the splash for a moment
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Start the exit fade-out (reverse from 1.0 → 0.0)
    await _exitController.reverse();

    if (!mounted) return;

    // Notify that the splash is done
    widget.onComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _exitAnimation,
      child: ColoredBox(
        color: isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFFFF8F0),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── App Icon ───────────────────────────
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        cacheWidth: 192,
                        cacheHeight: 192,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.calculate_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── App Name ───────────────────────────
                  Text(
                    AppInfo.appName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Tagline ────────────────────────────
                  Text(
                    AppInfo.tagline,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Loading Indicator ──────────────────
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
