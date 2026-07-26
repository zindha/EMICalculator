import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:emi_calculator/core/constants/hive_constants.dart';
import 'package:emi_calculator/core/providers/currency_provider.dart';

void main() {
  group('CurrencyNotifier', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('currency_test_');
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

    ProviderContainer createContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    test('initial state defaults to INR when no currency is persisted', () {
      final container = createContainer();
      final state = container.read(currencyNotifierProvider);

      expect(state.currency, SupportedCurrencies.indianRupee);
      expect(state.displayLabel, contains('Indian Rupee'));
      expect(state.displayLabel, contains(SupportedCurrencies.indianRupee.symbol));
    });

    test('setCurrency updates state and persists to Hive', () async {
      final container = createContainer();
      final notifier = container.read(currencyNotifierProvider.notifier);

      await notifier.setCurrency(SupportedCurrencies.usDollar);

      final state = container.read(currencyNotifierProvider);
      expect(state.currency, SupportedCurrencies.usDollar);

      final box = Hive.box(HiveConstants.themeBox);
      expect(box.get(HiveConstants.currencyCodeKey), 'USD');
      expect(box.get(HiveConstants.currencySymbolKey), r'$');
    });

    test('previously persisted currency is loaded on startup', () {
      final box = Hive.box(HiveConstants.themeBox);
      box.put(HiveConstants.currencyCodeKey, 'EUR');

      final container = createContainer();
      final state = container.read(currencyNotifierProvider);

      expect(state.currency, SupportedCurrencies.euro);
    });

    test('invalid persisted code falls back to default currency', () {
      final box = Hive.box(HiveConstants.themeBox);
      box.put(HiveConstants.currencyCodeKey, 'XYZ');

      final container = createContainer();
      final state = container.read(currencyNotifierProvider);

      expect(state.currency, SupportedCurrencies.defaultCurrency);
    });

    test('currency change notifies listeners', () async {
      final container = createContainer();
      final states = <CurrencyState>[];

      final sub = container.listen(
        currencyNotifierProvider,
        (previous, next) => states.add(next),
      );
      addTearDown(sub.close);

      await container
          .read(currencyNotifierProvider.notifier)
          .setCurrency(SupportedCurrencies.pound);

      expect(states.length, 1);
      expect(states.first.currency, SupportedCurrencies.pound);
    });
  });

  group('SupportedCurrencies', () {
    test('defaultCurrency is Indian Rupee', () {
      expect(SupportedCurrencies.defaultCurrency, SupportedCurrencies.indianRupee);
    });

    test('all contains nine currencies', () {
      expect(SupportedCurrencies.all, hasLength(9));
    });

    test('fromCode returns matching currency case-insensitively', () {
      expect(SupportedCurrencies.fromCode('usd'), SupportedCurrencies.usDollar);
      expect(SupportedCurrencies.fromCode('JPY'), SupportedCurrencies.yen);
    });

    test('fromCode returns default for unknown code', () {
      expect(
        SupportedCurrencies.fromCode('ABC'),
        SupportedCurrencies.defaultCurrency,
      );
    });
  });
}
