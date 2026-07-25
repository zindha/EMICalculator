import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/hive_constants.dart';

part 'theme_provider.g.dart';

/// Represents the current theme state including the [ThemeMode],
/// AMOLED flag, and accent seed color.
class ThemeState {
  /// Creates a [ThemeState].
  const ThemeState({
    required this.themeMode,
    required this.accentSeedColor,
    this.isAmoled = false,
  });

  /// The current theme mode (light or dark).
  final ThemeMode themeMode;

  /// Whether AMOLED (pure black) mode is active.
  /// When true, [themeMode] will be [ThemeMode.dark] with an AMOLED
  /// color palette instead of the standard dark theme.
  final bool isAmoled;

  /// The user-selected accent seed color for the color scheme.
  final Color accentSeedColor;

  /// Returns a copy of this state with the given fields replaced.
  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentSeedColor,
    bool? isAmoled,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentSeedColor: accentSeedColor ?? this.accentSeedColor,
      isAmoled: isAmoled ?? this.isAmoled,
    );
  }

  /// Default theme state (light mode, brand purple seed).
  static const defaultState = ThemeState(
    themeMode: ThemeMode.light,
    accentSeedColor: Color(0xFF6C63FF),
    isAmoled: false,
  );
}

/// Riverpod [Notifier] that manages the application theme mode and
/// accent color, persisting user preferences to Hive.
///
/// State is kept alive across navigation to preserve the user's theme
/// preference without re-reading from Hive on every screen.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  /// Converts a [Color] to its 32-bit ARGB int representation
  /// for Hive serialization.
  static int _colorToInt(Color c) {
    return ((c.a * 255).round() << 24) | ((c.r * 255).round() << 16) | ((c.g * 255).round() << 8) | (c.b * 255).round();
  }

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
        defaultValue: _colorToInt(const Color(0xFF6C63FF)),
      ) as int;
      final isAmoled = themeBox.get(
        HiveConstants.isAmoledKey,
        defaultValue: false,
      ) as bool;

      return ThemeState(
        themeMode: ThemeMode.values[themeModeIndex.clamp(0, 1)],
        accentSeedColor: Color(accentColorInt),
        isAmoled: isAmoled,
      );
    } catch (e) {
      // Fall back to defaults if Hive is unavailable.
      return ThemeState.defaultState;
    }
  }

  /// Sets the [ThemeMode] to [mode] and persists it to Hive.
  /// Setting light or dark also clears the AMOLED flag.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode, isAmoled: false);
    _persistThemeMode(mode);
    _persistAmoled(false);
  }

  /// Enables or disables AMOLED (pure black) mode.
  /// When enabled, the dark AMOLED theme is used.
  void setAmoledMode(bool enabled) {
    state = state.copyWith(
      themeMode: ThemeMode.dark,
      isAmoled: enabled,
    );
    _persistThemeMode(ThemeMode.dark);
    _persistAmoled(enabled);
  }

  /// Cycles through Light → Dark → AMOLED → Light.
  void toggleThemeMode() {
    if (state.isAmoled) {
      setThemeMode(ThemeMode.light);
    } else if (state.themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setAmoledMode(true);
    }
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
      themeBox.put(HiveConstants.accentColorKey, _colorToInt(color));
    } catch (e) {
      debugPrint('Failed to persist accent color: $e');
    }
  }

  /// Persists the [isAmoled] flag to the Hive theme box.
  void _persistAmoled(bool isAmoled) {
    try {
      final themeBox = Hive.box(HiveConstants.themeBox);
      themeBox.put(HiveConstants.isAmoledKey, isAmoled);
    } catch (e) {
      debugPrint('Failed to persist AMOLED mode: $e');
    }
  }
}
