import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/calculator/presentation/pages/calculator_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/export/pages/amortization_schedule_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

part 'app_router.g.dart';

/// Named route paths for type-safe navigation.
class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/';
  static const calculator = '/calculator';
  static const history = '/history';
  static const settings = '/settings';
  static const amortizationSchedule = '/amortization-schedule';
}

/// Riverpod provider for the application's [GoRouter] instance.
///
/// The router is kept alive to preserve navigation state across the app.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      // Main shell with bottom NavigationBar.
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.calculator,
            name: 'calculator',
            builder: (context, state) => const CalculatorPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),

      // Routes outside the main shell (full-screen).
      GoRoute(
        path: AppRoutes.amortizationSchedule,
        name: 'amortizationSchedule',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AmortizationSchedulePage(
            amortizationMonths: extra?['months'] as List<dynamic>? ?? [],
            loanAmount: extra?['loanAmount'] as double? ?? 0,
            totalInterest: extra?['totalInterest'] as double? ?? 0,
            totalPayment: extra?['totalPayment'] as double? ?? 0,
          );
        },
      ),
    ],
  );
}

/// Main application shell with a Material 3 [NavigationBar] containing
/// four tabs: Dashboard, Calculator, History, Settings.
class _AppShell extends ConsumerWidget {
  /// Creates the [_AppShell].
  const _AppShell({required this.child});

  /// The child widget to display within the shell.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    // Determine the current tab index based on the route path.
    int currentIndex;
    if (location == AppRoutes.dashboard) {
      currentIndex = 0;
    } else if (location == AppRoutes.calculator) {
      currentIndex = 1;
    } else if (location == AppRoutes.history) {
      currentIndex = 2;
    } else if (location == AppRoutes.settings) {
      currentIndex = 3;
    } else {
      currentIndex = 0;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.dashboard);
              break;
            case 1:
              context.go(AppRoutes.calculator);
              break;
            case 2:
              context.go(AppRoutes.history);
              break;
            case 3:
              context.go(AppRoutes.settings);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
