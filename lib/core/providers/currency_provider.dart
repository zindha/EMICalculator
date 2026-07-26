import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/hive_constants.dart';

part 'currency_provider.g.dart';

/// Describes a supported currency.
class CurrencyOption {
  /// Creates a [CurrencyOption].
  const CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
  });

  /// ISO-4217 currency code, e.g. `INR`.
  final String code;

  /// Human readable name, e.g. `Indian Rupee`.
  final String name;

  /// Display symbol, e.g. ``.
  final String symbol;

  /// Locale used for formatting, e.g. `en_IN`.
  final String locale;
}

/// All currencies supported by the app.
class SupportedCurrencies {
  const SupportedCurrencies._();

  /// Default currency (INR).
  static const CurrencyOption defaultCurrency = indianRupee;

  /// Indian Rupee.
  static const CurrencyOption indianRupee = CurrencyOption(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    locale: 'en_IN',
  );

  /// US Dollar.
  static const CurrencyOption usDollar = CurrencyOption(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    locale: 'en_US',
  );

  /// Euro.
  static const CurrencyOption euro = CurrencyOption(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    locale: 'en_IE',
  );

  /// British Pound.
  static const CurrencyOption pound = CurrencyOption(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    locale: 'en_GB',
  );

  /// Japanese Yen.
  static const CurrencyOption yen = CurrencyOption(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    locale: 'ja_JP',
  );

  /// Australian Dollar.
  static const CurrencyOption australianDollar = CurrencyOption(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    locale: 'en_AU',
  );

  /// Canadian Dollar.
  static const CurrencyOption canadianDollar = CurrencyOption(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    locale: 'en_CA',
  );

  /// Singapore Dollar.
  static const CurrencyOption singaporeDollar = CurrencyOption(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: 'S\$',
    locale: 'en_SG',
  );

  /// Emirati Dirham.
  static const CurrencyOption dirham = CurrencyOption(
    code: 'AED',
    name: 'Emirati Dirham',
    symbol: 'د.إ',
    locale: 'ar_AE',
  );

  /// All supported options in display order.
  static const List<CurrencyOption> all = [
    indianRupee,
    usDollar,
    euro,
    pound,
    yen,
    australianDollar,
    canadianDollar,
    singaporeDollar,
    dirham,
  ];

  /// Returns the [CurrencyOption] matching [code], or [defaultCurrency]
  /// if not found.
  static CurrencyOption fromCode(String code) {
    return all.firstWhere(
      (c) => c.code == code.toUpperCase(),
      orElse: () => defaultCurrency,
    );
  }
}

/// {@template currency_state}
/// Immutable state representing the currently selected currency.
/// {@endtemplate}
class CurrencyState {
  /// Creates a [CurrencyState].
  const CurrencyState({required this.currency});

  /// The currently selected currency.
  final CurrencyOption currency;

  /// A label suitable for UI subtitles, e.g. `Indian Rupee (₹)`.
  String get displayLabel => '${currency.name} (${currency.symbol})';
}

/// {@template currency_notifier}
/// Riverpod [Notifier] that reads the user's selected currency from Hive
/// and persists changes.
/// {@endtemplate}
@Riverpod(keepAlive: true)
class CurrencyNotifier extends _$CurrencyNotifier {
  @override
  CurrencyState build() {
    try {
      final themeBox = Hive.box(HiveConstants.themeBox);
      final code = themeBox.get(
        HiveConstants.currencyCodeKey,
        defaultValue: SupportedCurrencies.defaultCurrency.code,
      ) as String;
      return CurrencyState(currency: SupportedCurrencies.fromCode(code));
    } catch (e) {
      debugPrint('Failed to load currency from Hive: $e');
      return const CurrencyState(
        currency: SupportedCurrencies.defaultCurrency,
      );
    }
  }

  /// Sets the active currency to [option] and persists it to Hive.
  Future<void> setCurrency(CurrencyOption option) async {
    state = CurrencyState(currency: option);
    try {
      final themeBox = Hive.box(HiveConstants.themeBox);
      await themeBox.put(HiveConstants.currencyCodeKey, option.code);
      await themeBox.put(HiveConstants.currencySymbolKey, option.symbol);
    } catch (e) {
      debugPrint('Failed to persist currency: $e');
    }
  }
}
