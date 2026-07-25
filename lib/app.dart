import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

/// Root widget of the EMI Calculator application.
///
/// Uses GoRouter for declarative routing and Riverpod-driven dynamic theming
/// with support for Light, Dark, and AMOLED modes.
class EmiCalculatorApp extends ConsumerWidget {
  /// Creates the [EmiCalculatorApp].
  const EmiCalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider for reactive theme changes.
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'EMI Calculator',
      debugShowCheckedModeBanner: false,

      // Dynamic theme based on user preference.
      theme: AppTheme.buildLightTheme(themeState.accentSeedColor),
      darkTheme: themeState.themeMode == ThemeMode.system
          ? AppTheme.buildAmoledTheme(themeState.accentSeedColor)
          : AppTheme.buildDarkTheme(themeState.accentSeedColor),
      themeMode: themeState.themeMode == ThemeMode.system
          ? ThemeMode.dark
          : themeState.themeMode,

      // GoRouter configuration.
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
