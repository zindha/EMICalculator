import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:emi_calculator/core/constants/hive_constants.dart';
import 'package:emi_calculator/core/providers/currency_provider.dart';
import 'package:emi_calculator/core/theme/theme_provider.dart';
import 'package:emi_calculator/features/settings/presentation/pages/settings_page.dart';

/// Helper that creates a [ProviderContainer] pre-loaded with fresh notifier
/// instances that read from the already-open Hive box.
/// Call [container.dispose] in [addTearDown] for proper cleanup.
ProviderContainer createContainer() {
  final container = ProviderContainer(
    overrides: [
      currencyNotifierProvider.overrideWith(
        () => CurrencyNotifier(),
      ),
      themeNotifierProvider.overrideWith(
        () => ThemeNotifier(),
      ),
    ],
  );
  return container;
}

void main() {
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

  testWidgets('tapping Currency opens the picker with all supported currencies',
      (WidgetTester tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump();

    // Open the currency picker.
    await tester.ensureVisible(find.text('Currency'));
    await tester.tap(find.text('Currency'));
    await tester.pump();

    // The bottom sheet should display the supported currencies.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Select Currency'), findsOneWidget);
    expect(find.text('Indian Rupee'), findsOneWidget);
    expect(find.text('US Dollar'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
    expect(find.text('British Pound'), findsOneWidget);

    // Cleanly unmount.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('settings page uses default INR when nothing is persisted',
      (WidgetTester tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump();

    // Default currency is INR when nothing is persisted.
    expect(find.textContaining('Rupee'), findsOneWidget);

    // Cleanly unmount.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

/// Separate file tests USD persistence via Hive, since Hive writes
/// (box.put) hang inside testWidgets/FakeAsync and must run in
/// setUpAll which isn't test-scoped.
//
// USD persistence is covered by:
//   test('setCurrency updates state and persists to Hive')
//   test('previously persisted currency is loaded on startup')
// in test/core/providers/currency_provider_test.dart
