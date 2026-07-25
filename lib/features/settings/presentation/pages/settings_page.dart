import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/modern_glass_card.dart';

/// The Settings screen where users can customize their app experience.
///
/// Features include:
/// - Theme mode switching (Light, Dark, AMOLED)
/// - Accent color selection
/// - App information and version
class SettingsPage extends ConsumerWidget {
  /// Creates the [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Theme Mode ────────────────────────
            Text(
              'Appearance',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ModernGlassCard(
              glass: true,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.light_mode_rounded,
                    title: 'Light Mode',
                    subtitle: 'Warm white background',
                    isSelected: themeState.themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeNotifierProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Deep navy background',
                    isSelected: themeState.themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeNotifierProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.contrast_rounded,
                    title: 'AMOLED Mode',
                    subtitle: 'Pure black — saves battery',
                    isSelected: themeState.themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeNotifierProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Accent Color ──────────────────────
            Text(
              'Accent Color',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ModernGlassCard(
              glass: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _AccentColorDot(
                      color: const Color(0xFF6C63FF),
                      label: 'Purple',
                      isSelected: themeState.accentSeedColor.toARGB32() ==
                          const Color(0xFF6C63FF).toARGB32(),
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAccentColor(const Color(0xFF6C63FF)),
                    ),
                    _AccentColorDot(
                      color: const Color(0xFFFF6584),
                      label: 'Coral',
                      isSelected: themeState.accentSeedColor.toARGB32() ==
                          const Color(0xFFFF6584).toARGB32(),
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAccentColor(const Color(0xFFFF6584)),
                    ),
                    _AccentColorDot(
                      color: const Color(0xFF00C9A7),
                      label: 'Mint',
                      isSelected: themeState.accentSeedColor.toARGB32() ==
                          const Color(0xFF00C9A7).toARGB32(),
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAccentColor(const Color(0xFF00C9A7)),
                    ),
                    _AccentColorDot(
                      color: const Color(0xFF3498DB),
                      label: 'Blue',
                      isSelected: themeState.accentSeedColor.toARGB32() ==
                          const Color(0xFF3498DB).toARGB32(),
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAccentColor(const Color(0xFF3498DB)),
                    ),
                    _AccentColorDot(
                      color: const Color(0xFFE74C3C),
                      label: 'Red',
                      isSelected: themeState.accentSeedColor.toARGB32() ==
                          const Color(0xFFE74C3C).toARGB32(),
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAccentColor(const Color(0xFFE74C3C)),
                    ),
                    _AccentColorDot(
                      color: const Color(0xFF2ECC71),
                      label: 'Green',
                      isSelected: themeState.accentSeedColor.toARGB32() ==
                          const Color(0xFF2ECC71).toARGB32(),
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAccentColor(const Color(0xFF2ECC71)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── About ─────────────────────────────
            Text(
              'About',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ModernGlassCard(
              glass: true,
              child: Column(
                children: [
                  _SettingsInfoTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                  const Divider(height: 1),
                  _SettingsInfoTile(
                    icon: Icons.code_rounded,
                    title: 'Built with',
                    subtitle: 'Flutter • Riverpod • Hive',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A single setting option tile with radio-style selection.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
            )
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }
}

/// A non-interactive information tile.
class _SettingsInfoTile extends StatelessWidget {
  const _SettingsInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A circular color swatch for accent color selection.
class _AccentColorDot extends StatelessWidget {
  const _AccentColorDot({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
