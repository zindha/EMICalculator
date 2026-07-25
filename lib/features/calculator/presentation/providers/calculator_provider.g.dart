// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$emiCalculatorServiceHash() =>
    r'030ae33b49e925f091d7df87e508b80c403578ee';

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
    r'dabcadf1181f31c2edb58738739a5957d44264e4';

/// Notifier that manages the user's current loan input state.
///
/// Provides mutation methods for each input field and auto-recalculates
/// the result whenever any input changes.
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
String _$emiResultNotifierHash() => r'f8b4e8a7e0383fee9e0ba3df17bf0b36e0dc5e71';

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
