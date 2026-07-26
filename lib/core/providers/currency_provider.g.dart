// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencyNotifierHash() => r'6dff555cc9cc024e4c323af9c690367e67e8e47b';

/// {@template currency_notifier}
/// Riverpod [Notifier] that reads the user's selected currency from Hive
/// and persists changes.
/// {@endtemplate}
///
/// Copied from [CurrencyNotifier].
@ProviderFor(CurrencyNotifier)
final currencyNotifierProvider =
    NotifierProvider<CurrencyNotifier, CurrencyState>.internal(
  CurrencyNotifier.new,
  name: r'currencyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrencyNotifier = Notifier<CurrencyState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
