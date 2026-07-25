import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/theme/app_colors.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Theme Mode ────────────────────────
              const _SectionTitle(title: 'Appearance'),
              const SizedBox(height: 12),
              ModernGlassCard(
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
                      isSelected: themeState.themeMode == ThemeMode.dark &&
                          !themeState.isAmoled,
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setThemeMode(ThemeMode.dark),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.contrast_rounded,
                      title: 'AMOLED Mode',
                      subtitle: 'Pure black — saves battery',
                      isSelected: themeState.isAmoled,
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .setAmoledMode(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Accent Color ──────────────────────
              const _SectionTitle(title: 'Accent Color'),
              const SizedBox(height: 12),
              ModernGlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // On very narrow screens, reduce dot size count to avoid overflow.
                      final width = constraints.maxWidth;
                      final dotSize = width < 300 ? 32.0 : 36.0;
                      return Wrap(
                        spacing: width < 300 ? 8 : 12,
                        runSpacing: width < 300 ? 8 : 12,
                        alignment: WrapAlignment.spaceEvenly,
                        children: [
                          _AccentColorDot(
                            color: AppColors.primary,
                            label: 'Purple',
                            isSelected: themeState.accentSeedColor ==
                                AppColors.primary,
                            size: dotSize,
                            onTap: () => ref
                                .read(themeNotifierProvider.notifier)
                                .setAccentColor(AppColors.primary),
                          ),
                          _AccentColorDot(
                            color: AppColors.secondary,
                            label: 'Coral',
                            isSelected: themeState.accentSeedColor ==
                                AppColors.secondary,
                            size: dotSize,
                            onTap: () => ref
                                .read(themeNotifierProvider.notifier)
                                .setAccentColor(AppColors.secondary),
                          ),
                          _AccentColorDot(
                            color: AppColors.tertiary,
                            label: 'Mint',
                            isSelected: themeState.accentSeedColor ==
                                AppColors.tertiary,
                            size: dotSize,
                            onTap: () => ref
                                .read(themeNotifierProvider.notifier)
                                .setAccentColor(AppColors.tertiary),
                          ),
                          _AccentColorDot(
                            color: AppColors.info,
                            label: 'Blue',
                            isSelected: themeState.accentSeedColor ==
                                AppColors.info,
                            size: dotSize,
                            onTap: () => ref
                                .read(themeNotifierProvider.notifier)
                                .setAccentColor(AppColors.info),
                          ),
                          _AccentColorDot(
                            color: AppColors.danger,
                            label: 'Red',
                            isSelected: themeState.accentSeedColor ==
                                AppColors.danger,
                            size: dotSize,
                            onTap: () => ref
                                .read(themeNotifierProvider.notifier)
                                .setAccentColor(AppColors.danger),
                          ),
                          _AccentColorDot(
                            color: AppColors.positive,
                            label: 'Green',
                            isSelected: themeState.accentSeedColor ==
                                AppColors.positive,
                            size: dotSize,
                            onTap: () => ref
                                .read(themeNotifierProvider.notifier)
                                .setAccentColor(AppColors.positive),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Preferences ─────────────────────
              const _SectionTitle(title: 'Preferences'),
              const SizedBox(height: 12),
              ModernGlassCard(
                child: Column(
                  children: [
                    _SettingsActionTile(
                      icon: Icons.currency_rupee_rounded,
                      title: 'Currency',
                      subtitle: 'Indian Rupee (₹)',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Currency picker coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsActionTile(
                      icon: Icons.star_rate_rounded,
                      title: 'Rate the App',
                      subtitle: 'Love the app? Leave a rating',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rate app action coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy online',
                      onTap: () => _openPrivacyPolicy(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── About ─────────────────────────────
              const _SectionTitle(title: 'About'),
              const SizedBox(height: 12),
              ModernGlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── App Identity ──────────────────────
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor
                                  .withValues(alpha: 0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            cacheWidth: 160,
                            cacheHeight: 160,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.calculate_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppInfo.appName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version ${AppInfo.version}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppInfo.companyDescription,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const _SettingsInfoTile(
                        icon: Icons.apartment_rounded,
                        title: 'Developer',
                        subtitle: AppInfo.companyName,
                      ),
                      const Divider(height: 1),
                      _SettingsActionTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: AppInfo.contactEmail,
                        onTap: () => _openContactEmail(context),
                      ),
                      const Divider(height: 1),
                      const _SettingsInfoTile(
                        icon: Icons.copyright_outlined,
                        title: 'Copyright',
                        subtitle:
                            '${AppInfo.copyright}\nAll Rights Reserved.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the privacy policy URL in the user's default browser.
  ///
  /// If the URL cannot be launched, a Material snackbar is shown so the
  /// failure is never silent.
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppInfo.privacyPolicyUrl);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!context.mounted) return;
      if (!canLaunch) {
        _showLaunchError(context, 'Could not open the privacy policy link.');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      _showLaunchError(context, 'Could not open the privacy policy link: $e');
    }
  }

  /// Opens the contact email client.
  Future<void> _openContactEmail(BuildContext context) async {
    final uri = Uri.parse('mailto:${AppInfo.contactEmail}');
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!context.mounted) return;
      if (!canLaunch) {
        _showLaunchError(context, 'Could not open an email app.');
        return;
      }
      await launchUrl(uri);
    } catch (e) {
      if (!context.mounted) return;
      _showLaunchError(context, 'Could not open an email app: $e');
    }
  }

  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// A section title widget used throughout the settings page.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: Theme.of(context).colorScheme.onSurface,
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
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
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

/// A single action-only settings tile without radio-style selection.
class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
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
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

/// A circular color swatch for accent color selection.
class _AccentColorDot extends StatelessWidget {
  const _AccentColorDot({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size + 20,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
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
