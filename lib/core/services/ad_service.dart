import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages AdMob lifecycle and provides ad unit IDs.
///
/// Uses Google's official test ad units during development. Before publishing
/// to the Play Store, replace [bannerAdUnitId] with your production AdMob ad
/// unit ID.
///
/// ## Test IDs Used
/// - Banner: ca-app-pub-3940256099942544/6300978111
///
/// See https://developers.google.com/admob/android/test-ads for details.
class AdService {
  AdService._();

  static bool _initialized = false;

  /// Test banner ad unit ID — replace with your production ID before release.
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this once before [runApp] to give AdMob a head start on loading
  /// the first ad. Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Enable test ads in debug mode via the test device list.
      final requestConfiguration = RequestConfiguration(
        testDeviceIds: <String>[],
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      await MobileAds.instance.initialize();
      _initialized = true;

      if (kDebugMode) {
        final version = await MobileAds.instance.getVersionString();
        debugPrint('[AdMob] Initialized v$version (test mode)');
      }
    } catch (e) {
      // Don't crash if ads fail to initialize — the app works without them.
      debugPrint('[AdMob] Initialization failed: $e');
    }
  }

  /// Whether the AdMob SDK has been initialized.
  static bool get isInitialized => _initialized;
}
