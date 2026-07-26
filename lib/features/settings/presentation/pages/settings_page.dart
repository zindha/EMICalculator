import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/modern_card.dart';

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
        title: const Text('Settings'),
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
              ModernCard(
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
              ModernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive sizing: cap dot size on very wide screens
                      // while letting each chip expand evenly to fill the row.
                      final width = constraints.maxWidth;
                      final dotSize = width < 300
                          ? 28.0
                          : width > 600
                              ? 44.0
                              : 36.0;
                      final colorOptions = [
                        (AppColors.primary, 'Purple'),
                        (AppColors.secondary, 'Coral'),
                        (AppColors.tertiary, 'Mint'),
                        (AppColors.info, 'Blue'),
                        (AppColors.danger, 'Red'),
                        (AppColors.positive, 'Green'),
                      ];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: colorOptions.map((option) {
                          final (color, label) = option;
                          return Expanded(
                            child: _AccentColorDot(
                              color: color,
                              label: label,
                              isSelected: themeState.accentSeedColor == color,
                              size: dotSize,
                              onTap: () => ref
                                  .read(themeNotifierProvider.notifier)
                                  .setAccentColor(color),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Preferences ─────────────────────
              const _SectionTitle(title: 'Preferences'),
              const SizedBox(height: 12),
              ModernCard(
                child: _SettingsActionTile(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Currency',
                  subtitle: ref.watch(currencyNotifierProvider).displayLabel,
                  onTap: () => _showCurrencyPicker(context, ref),
                ),
              ),
              const SizedBox(height: 28),

              // ── About ─────────────────────────────
              const _SectionTitle(title: 'About'),
              const SizedBox(height: 12),
              ModernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── App Identity ──────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          cacheWidth: 160,
                          cacheHeight: 160,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.calculate_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppInfo.appName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version ${AppInfo.version}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Developed by',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppInfo.companyName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppInfo.companyDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      _SettingsActionTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy online',
                        onTap: () => _openPrivacyPolicy(context),
                      ),
                      const Divider(height: 1),
                      _SettingsActionTile(
                        icon: Icons.code_rounded,
                        title: 'Open Source Licenses',
                        subtitle: 'Licenses for the open source libraries we use',
                        onTap: () => _showLicensePage(context),
                      ),
                      const Divider(height: 1),
                      _SettingsActionTile(
                        icon: Icons.star_rate_rounded,
                        title: 'Rate App',
                        subtitle: 'Disabled until Play Store release',
                        onTap: () => NotificationService.show(
                          'Rate App will be enabled once the app is on the Play Store.',
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Text(
                          '${AppInfo.copyright}\nAll Rights Reserved.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
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
  /// If the URL cannot be launched, a Material dialog is shown with the policy
  /// text, a retry option, and the contact email so the policy is always
  /// accessible.
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppInfo.privacyPolicyUrl);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!context.mounted) return;
      if (!canLaunch) {
        _showPrivacyPolicyDialog(context);
        return;
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showPrivacyPolicyDialog(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showPrivacyPolicyDialog(context);
    }
  }

  /// Shows a fallback dialog containing the full privacy policy text.
  ///
  /// The dialog includes the contact email (only here, never on the About
  /// screen) and a retry button to attempt opening the external URL again.
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: SelectableText(
            'Dzynova Technologies respects your privacy.\n\n'
            'All loan data and calculations are stored locally on your device. '
            'We do not collect, transmit, or share any personal or financial '
            'information.\n\n'
            'For questions about this policy, contact us at:\n'
            '${AppInfo.contactEmail}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _openPrivacyPolicy(context);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Opens the Flutter license page for open source libraries used by the app.
  void _showLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppInfo.appName,
      applicationVersion: AppInfo.version,
      applicationLegalese: '${AppInfo.copyright}\nAll Rights Reserved.',
    );
  }

  /// Opens a bottom sheet with the supported currencies.
  ///
  /// The selected currency is persisted to Hive and the UI rebuilds
  /// immediately.
  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(currencyNotifierProvider).currency;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select Currency',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      key: const Key('currencyPickerListView'),
                      itemCount: SupportedCurrencies.all.length,
                      itemBuilder: (context, index) {
                        final option = SupportedCurrencies.all[index];
                        final isSelected = option.code == current.code;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            child: Text(
                              option.symbol,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                              ),
                            ),
                          ),
                          title: Text(option.name),
                          subtitle: Text('${option.code} - ${option.symbol}'),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(currencyNotifierProvider.notifier)
                                .setCurrency(option)
                                .then((_) {
                              NotificationService.show(
                                'Currency updated to ${option.name}',
                              );
                            });
                            Navigator.of(sheetContext).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A section title widget used throughout the settings page.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
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
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
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
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
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
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
