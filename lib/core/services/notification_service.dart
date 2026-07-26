import 'package:flutter/material.dart';

/// {@template notification_service}
/// Centralized notification manager for the application.
///
/// This service wraps [ScaffoldMessengerState] so that notifications messages
/// never queue up.  A new message immediately replaces any currently visible
/// Snackbar, duplicated messages are collapsed, and the UI is never blocked by
/// a long chain of transient notifications.
///
/// {@endtemplate}
class NotificationService {
  const NotificationService._();

  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// The [GlobalKey] used by [MaterialApp] / [MaterialApp.router] to
  /// provide a [ScaffoldMessengerState] from anywhere in the app.
  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

  static String? _lastMessage;
  static DateTime? _lastShownAt;
  static const _debounceDuration = Duration(milliseconds: 250);

  /// Shows a non-blocking floating Snackbar with [message].
  ///
  /// If [isError] is true, the Snackbar uses an error color and is always
  /// shown even if it duplicates a recent message.
  /// [duration] defaults to 2 seconds.
  ///
  /// Replaces any currently visible Snackbar and suppresses duplicate messages
  /// that arrive within the debounce window.
  static void show(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final now = DateTime.now();
    final isDuplicate = _lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < _debounceDuration;

    // Error messages should always be shown; normal messages are debounced
    // to avoid spamming the user.
    if (!isError && isDuplicate) {
      return;
    }

    _lastMessage = message;
    _lastShownAt = now;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: isError ? Colors.red.shade800 : null,
      ),
    );
  }

  /// Hides all currently displayed Snackbars immediately.
  static void hide() {
    _scaffoldMessengerKey.currentState?.clearSnackBars();
  }
}
