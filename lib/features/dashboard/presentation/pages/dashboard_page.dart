import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modern_glass_card.dart';

/// The Dashboard screen — the first screen users see after launching the app.
///
/// Contains quick action buttons (New Calculation, Compare, Prepayment) and
/// a summary of recent loan calculations.
class DashboardPage extends ConsumerWidget {
  /// Creates the [DashboardPage].
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppInfo.appName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              AppInfo.tagline,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Quick Actions ─────────────────────
              Text(
                'Quick Actions',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // Responsive column count: 2 for very small, 4 when space allows.
                  int crossAxisCount;
                  if (width >= 600) {
                    crossAxisCount = 4;
                  } else if (width >= 320) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = 2;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _QuickActionCard(
                        icon: Icons.calculate_rounded,
                        label: 'New\nCalculation',
                        color: theme.colorScheme.primary,
                        onTap: () => context.go(AppRoutes.calculator),
                      ),
                      _QuickActionCard(
                        icon: Icons.compare_arrows_rounded,
                        label: 'Compare\nLoans',
                        color: AppColors.secondary,
                        onTap: () => context.go(AppRoutes.comparison),
                      ),
                      _QuickActionCard(
                        icon: Icons.savings_rounded,
                        label: 'Prepayment\nPlanner',
                        color: AppColors.tertiary,
                        onTap: () => context.go(AppRoutes.prepayment),
                      ),
                      _QuickActionCard(
                        icon: Icons.trending_down_rounded,
                        label: 'What If\nSimulator',
                        color: AppColors.info,
                        onTap: () => context.go(AppRoutes.whatIf),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Recent Calculations ───────────────
              Text(
                'Recent Calculations',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ModernGlassCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 26,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No calculations yet',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start by calculating your first EMI',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => context.go(AppRoutes.calculator),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('New Calculation'),
                        ),
                      ],
                    ),
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

/// A quick action card displayed on the dashboard.
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant
                  .withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
