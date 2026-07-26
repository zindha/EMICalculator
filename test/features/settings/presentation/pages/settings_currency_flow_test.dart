import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:emi_calculator/core/constants/hive_constants.dart';
import 'package:emi_calculator/core/providers/currency_provider.dart';
import 'package:emi_calculator/features/settings/presentation/pages/settings_page.dart';

void main() {
  group('Settings currency picker flow', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('settings_flow_test_');
      Hive.init(tempDir.path);
      await Hive.openBox(HiveConstants.themeBox);
    });

    tearDownAll(() async {
      await Hive.close();
      tempDir.deleteSync(recursive: true);
    });

    tearDown(() async {
      final box = Hive.box(HiveConstants.themeBox);
      await box.clear();
    });

    /// Creates a [ProviderScope] that overrides [currencyNotifierProvider]
    /// with a new notifier instance (which reads from the already-open Hive
    /// box).  The standard `ProviderScope` widget manages disposal
    /// automatically when the tree is rebuilt, avoiding keepAlive lifecycle
    /// races.
    Widget buildScope() {
      return ProviderScope(
        overrides: [
          currencyNotifierProvider.overrideWith(
            () => CurrencyNotifier(),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      );
    }

    testWidgets(
        'tapping Currency opens the picker with all supported currencies',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildScope());
      await tester.pumpAndSettle();

      // Open the currency picker.
      await tester.ensureVisible(find.text('Currency'));
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      // The bottom sheet should display the supported currencies.
      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.text('Indian Rupee'), findsOneWidget);
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('Euro'), findsOneWidget);
      expect(find.text('British Pound'), findsOneWidget);

      // Cleanly unmount to let bottom sheet animations complete.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('changing currency via provider updates the settings tile',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildScope());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      await container
          .read(currencyNotifierProvider.notifier)
          .setCurrency(SupportedCurrencies.usDollar);
      await tester.pumpAndSettle();

      expect(find.textContaining('US Dollar'), findsOneWidget);
      expect(find.textContaining('Indian Rupee'), findsNothing);

      // Cleanly unmount.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('selected currency is persisted across rebuilds',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildScope());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      await container
          .read(currencyNotifierProvider.notifier)
          .setCurrency(SupportedCurrencies.euro);
      await tester.pumpAndSettle();

      // Pump a new ProviderScope (simulating app restart) — the Hive-backed
      // notifier should load the persisted currency.
      await tester.pumpWidget(buildScope());
      await tester.pumpAndSettle();

      expect(find.textContaining('Euro'), findsOneWidget);

      // Cleanly unmount.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
