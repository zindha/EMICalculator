import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/hive_constants.dart';

part 'theme_provider.g.dart';

/// Represents the current theme state including the [ThemeMode] and
/// accent seed color.
class ThemeState {
  /// Creates a [ThemeState].
  const ThemeState({
    required this.themeMode,
    required this.accentSeedColor,
  });

  /// The current theme mode (light, dark, or system/AMOLED).
  final ThemeMode themeMode;

  /// The user-selected accent seed color for the color scheme.
  final Color accentSeedColor;

  /// Returns a copy of this state with the given fields replaced.
  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentSeedColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentSeedColor: accentSeedColor ?? this.accentSeedColor,
    );
  }

  /// Default theme state (light mode, brand purple seed).
  static const defaultState = ThemeState(
    themeMode: ThemeMode.light,
    accentSeedColor: Color(0xFF6C63FF),
  );
}

/// Riverpod [Notifier] that manages the application theme mode and
/// accent color, persisting user preferences to Hive.
///
/// State is kept alive across navigation to preserve the user's theme
/// preference without re-reading from Hive on every screen.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    // Attempt to load persisted theme preferences from Hive.
    try {
      final themeBox = Hive.box(HiveConstants.themeBox);
      final themeModeIndex = themeBox.get(
        HiveConstants.themeModeKey,
        defaultValue: ThemeMode.light.index,
      ) as int;
      final accentColorInt = themeBox.get(
        HiveConstants.accentColorKey,
        defaultValue: const Color(0xFF6C63FF).toARGB32(),
      ) as int;

      return ThemeState(
        themeMode: ThemeMode.values[themeModeIndex],
        accentSeedColor: Color(accentColorInt),
      );
    } catch (e) {
      // Fall back to defaults if Hive is unavailable.
      return ThemeState.defaultState;
    }
  }

  /// Sets the [ThemeMode] to [mode] and persists it to Hive.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _persistThemeMode(mode);
  }

  /// Cycles through Light → Dark → AMOLED → Light.
  void toggleThemeMode() {
    final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final currentIndex = modes.indexOf(state.themeMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];
    setThemeMode(nextMode);
  }

  /// Sets the accent seed color to [color] and persists it to Hive.
  void setAccentColor(Color color) {
    state = state.copyWith(accentSeedColor: color);
    _persistAccentColor(color);
  }

  /// Persists the [mode] to the Hive theme box.
  void _persistThemeMode(ThemeMode mode) {
    try {
      final themeBox = Hive.box(HiveConstants.themeBox);
      themeBox.put(HiveConstants.themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Failed to persist theme mode: $e');
    }
  }

  /// Persists the [color] to the Hive theme box.
  void _persistAccentColor(Color color) {
    try {
      final themeBox = Hive.box(HiveConstants.themeBox);
      themeBox.put(HiveConstants.accentColorKey, color.toARGB32());
    } catch (e) {
      debugPrint('Failed to persist accent color: $e');
    }
  }
}
