import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:hive/hive.dart';

/// Manages in-app purchases for the premium/remove-ads product.
///
/// Uses Google Play's non-consumable one-time purchase model so that the
/// purchase is permanent and survives app reinstalls (tied to the user's
/// Google account).
///
/// ## Test IDs (during development)
/// - Product: `android.test.purchased`
///
/// Replace [removeAdsProductId] with your real product ID from Google Play
/// Console before publishing.
class PurchaseService {
  PurchaseService._();

  static final InAppPurchase _iap = InAppPurchase.instance;

  /// Whether a purchase flow is currently in progress.
  static bool _purchaseInProgress = false;

  /// Stream subscription for purchase updates.
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Notifies listeners when the premium status changes (purchased/restored).
  static final premiumStatus = ValueNotifier<bool>(false);

  /// The one-time purchase product ID for removing ads.
  ///
  /// Replace with your real product ID from Google Play Console before
  /// publishing. During development, use `android.test.purchased`.
  static const String removeAdsProductId = 'android.test.purchased';

  /// Whether a purchase is currently in progress (prevents double-taps).
  static bool get isPurchaseInProgress => _purchaseInProgress;

  /// Initializes the purchase service and starts listening for purchase
  /// updates. Call this once during app startup.
  static void init() {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) {
        debugPrint('[Purchase] Stream error: $error');
      },
      onDone: () {
        debugPrint('[Purchase] Stream closed');
      },
    );

    if (kDebugMode) {
      debugPrint('[Purchase] Service initialized');
    }
  }

  /// Cleans up the purchase stream subscription. Call during app disposal.
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Fetches product details for the remove-ads product.
  ///
  /// Returns the list of product details, typically containing one item.
  static Future<List<ProductDetails>> getProducts() async {
    final response = await _iap.queryProductDetails(
      {removeAdsProductId},
    );

    if (response.error != null) {
      debugPrint('[Purchase] Failed to load products: ${response.error}');
      return [];
    }

    return response.productDetails;
  }

  /// Initiates a one-time purchase of the remove-ads product.
  ///
  /// Sets [_purchaseInProgress] to prevent concurrent purchases.
  /// The result arrives asynchronously via [premiumStatus] when the
  /// purchase stream fires.
  static Future<void> purchase(ProductDetails product) async {
    if (_purchaseInProgress) {
      debugPrint('[Purchase] Already in progress');
      return;
    }

    _purchaseInProgress = true;

    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
        ),
      );
    } catch (e) {
      debugPrint('[Purchase] Purchase failed: $e');
      _purchaseInProgress = false;
    }
  }

  /// Restores any previous purchases (e.g., after reinstalling the app).
  ///
  /// The result arrives asynchronously via [premiumStatus].
  static Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      if (kDebugMode) {
        debugPrint('[Purchase] Restore initiated');
      }
    } catch (e) {
      debugPrint('[Purchase] Restore failed: $e');
    }
  }

  /// Handles purchase updates from the purchase stream.
  static void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  /// Processes a single purchase details object.
  static void _handlePurchase(PurchaseDetails purchase) {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      _purchaseInProgress = false;

      // Persist the purchase locally via Hive.
      _persistPurchase(true);

      // Notify listeners (PremiumNotifier, AdBanner, etc.)
      premiumStatus.value = true;

      // Mark the purchase as consumed/acknowledged.
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }

      if (kDebugMode) {
        debugPrint('[Purchase] Success: ${purchase.productID}');
      }
    } else if (purchase.status == PurchaseStatus.error) {
      _purchaseInProgress = false;

      if (kDebugMode) {
        debugPrint('[Purchase] Error: ${purchase.error?.message}');
      }
    } else if (purchase.status == PurchaseStatus.pending) {
      // Waiting for user to complete payment in the Play Store dialog.
      if (kDebugMode) {
        debugPrint('[Purchase] Pending');
      }
    }
  }

  /// Persists the premium status to Hive so the app remembers it across
  /// restarts without needing to query Google Play every time.
  static Future<void> _persistPurchase(bool isPremium) async {
    try {
      // Use the already-opened box if available (opened by HiveService).
      final box = Hive.box('premiumBox');
      await box.put('isPremium', isPremium);
    } catch (e) {
      // Fall back to opening the box directly if not yet opened.
      try {
        final box = await Hive.openBox('premiumBox');
        await box.put('isPremium', isPremium);
      } catch (e2) {
        debugPrint('[Purchase] Failed to persist: $e2');
      }
    }
  }

  /// Checks whether the user has an active premium subscription by reading
  /// the locally persisted status.
  ///
  /// On app startup, the purchase stream's restore flow will update this.
  static Future<bool> isPremium() async {
    try {
      final box = Hive.box('premiumBox');
      return box.get('isPremium', defaultValue: false) as bool;
    } catch (e) {
      // Fall back to opening the box directly if not yet opened.
      try {
        final box = await Hive.openBox('premiumBox');
        return box.get('isPremium', defaultValue: false) as bool;
      } catch (e2) {
        debugPrint('[Purchase] Failed to read premium status: $e2');
        return false;
      }
    }
  }
}
