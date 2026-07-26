// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$emiCalculatorServiceHash() =>
    r'1bc9a7c842b384d620dd1d44850d4dcbec6e9f81';

/// Riverpod provider that always exposes the current [EmiCalculation] state.
///
/// This is a simple provider (value provider) that returns the default
/// calculation. The actual input state is managed by the [calculatorInputProvider]
/// notifier below.
///
/// Copied from [emiCalculatorService].
@ProviderFor(emiCalculatorService)
final emiCalculatorServiceProvider = Provider<EmiCalculatorService>.internal(
  emiCalculatorService,
  name: r'emiCalculatorServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emiCalculatorServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EmiCalculatorServiceRef = ProviderRef<EmiCalculatorService>;
String _$calculatorInputNotifierHash() =>
    r'4f411145da32a067d0a1e1cf0f2a615a79928ead';

/// Notifier that manages the user's current loan input state.
///
/// Provides mutation methods for each input field and auto-recalculates
/// the result whenever any input changes. Also supports in-session undo,
/// redo and reset operations.
///
/// Copied from [CalculatorInputNotifier].
@ProviderFor(CalculatorInputNotifier)
final calculatorInputNotifierProvider =
    NotifierProvider<CalculatorInputNotifier, EmiCalculation>.internal(
  CalculatorInputNotifier.new,
  name: r'calculatorInputNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calculatorInputNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalculatorInputNotifier = Notifier<EmiCalculation>;
String _$emiResultNotifierHash() => r'fe7f5eb5222b6b26bf17ed7803bf0450cd4b9bf7';

/// Riverpod provider that computes the full [EmiCalculationResult] based on
/// the current [EmiCalculation] input state.
///
/// This is a derived provider that automatically recalculates whenever the
/// input changes.
///
/// Copied from [EmiResultNotifier].
@ProviderFor(EmiResultNotifier)
final emiResultNotifierProvider =
    NotifierProvider<EmiResultNotifier, EmiCalculationResult?>.internal(
  EmiResultNotifier.new,
  name: r'emiResultNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emiResultNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmiResultNotifier = Notifier<EmiCalculationResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
