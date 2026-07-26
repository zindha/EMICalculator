import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/app.dart';
import 'package:emi_calculator/core/providers/currency_provider.dart';
import 'package:emi_calculator/core/theme/theme_provider.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    // Override keepAlive providers to avoid Hive dependency and prevent
    // cross-test Hive lifecycle conflicts when run alongside other tests.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeNotifierProvider
              .overrideWith(() => ThemeNotifier()),
          currencyNotifierProvider
              .overrideWith(() => CurrencyNotifier()),
        ],
        child: const EmiCalculatorApp(),
      ),
    );
    // Splash screen: fade-in (600ms) + hold (800ms) + fade-out (400ms).
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify the app rendered after the splash animation completed.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Cleanly unmount.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
