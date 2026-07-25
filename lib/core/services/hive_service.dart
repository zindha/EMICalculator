import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../constants/hive_constants.dart';

/// Service responsible for Hive initialization, adapter registration,
/// and box management.
///
/// All Hive operations throughout the app should go through this service
/// or use box references obtained from it.
class HiveService {
  const HiveService._();

  /// Registers all custom Hive type adapters.
  ///
  /// Must be called after `Hive.initFlutter()` and before opening any boxes.
  static Future<void> registerAdapters() async {
    // Register adapters for custom Freezed models here as they are created.
    // Example:
    // Hive.registerAdapter(EmiCalculationAdapter());
  }

  /// Opens all required Hive boxes for the application.
  ///
  /// Returns a map of box names to opened [Box] instances for convenience.
  static Future<Map<String, Box>> openBoxes() async {
    final boxes = <String, Box>{};

    try {
      boxes[HiveConstants.themeBox] = await Hive.openBox(
        HiveConstants.themeBox,
      );
      boxes[HiveConstants.loanHistoryBox] = await Hive.openBox(
        HiveConstants.loanHistoryBox,
      );
      boxes[HiveConstants.savedOffersBox] = await Hive.openBox(
        HiveConstants.savedOffersBox,
      );
    } catch (e) {
      // Re-throw to allow callers to handle initialization failures.
      rethrow;
    }

    return boxes;
  }

  /// Retrieves an already-opened Hive box by [boxName].
  ///
  /// Throws a [HiveError] if the box has not been opened yet.
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Deletes all data from every app box (for testing or reset).
  static Future<void> clearAllBoxes() async {
    final boxNames = [
      HiveConstants.themeBox,
      HiveConstants.loanHistoryBox,
      HiveConstants.savedOffersBox,
    ];

    for (final name in boxNames) {
      try {
        await Hive.box(name).clear();
      } catch (e) {
        debugPrint('Failed to clear box "$name": $e');
      }
    }
  }
}
