import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'shared/widgets/splash_screen.dart';

/// Root widget of the EMI Calculator application.
///
/// Uses GoRouter for declarative routing and Riverpod-driven dynamic theming
/// with support for Light, Dark, and AMOLED modes. Shows a splash screen
/// on first launch with a fade-out transition.
class EmiCalculatorApp extends ConsumerStatefulWidget {
  /// Creates the [EmiCalculatorApp].
  const EmiCalculatorApp({super.key});

  @override
  ConsumerState<EmiCalculatorApp> createState() => _EmiCalculatorAppState();
}

class _EmiCalculatorAppState extends ConsumerState<EmiCalculatorApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
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

      // Splash screen overlay via builder.
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            // Splash overlay — sits on top of the router's content.
            if (!_splashDone)
              SplashScreen(
                onComplete: () {
                  if (mounted) {
                    setState(() => _splashDone = true);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}
