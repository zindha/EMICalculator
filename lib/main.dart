import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/hive_service.dart';

/// Entry point for the EMI Calculator application.
///
/// Initializes Hive for offline persistence, wraps the app in a [ProviderScope]
/// for Riverpod state management, and launches the [EmiCalculatorApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive storage for offline-first data persistence.
    await Hive.initFlutter();
    await HiveService.registerAdapters();
    await HiveService.openBoxes();
  } catch (e) {
    // Log initialization errors but continue — the app can still run
    // without Hive persistence enabled.
    debugPrint('Hive initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: EmiCalculatorApp(),
    ),
  );
}
