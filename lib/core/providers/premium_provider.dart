import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/purchase_service.dart';

/// Riverpod provider that tracks whether the user has purchased the
/// premium/remove-ads upgrade.
///
/// On app launch, it checks the locally persisted Hive value. After a
/// successful purchase or restore, [PurchaseService.premiumStatus] fires
/// and the provider updates reactively so the UI rebuilds without ads.
class PremiumNotifier extends StateNotifier<AsyncValue<bool>> {
  PremiumNotifier() : super(const AsyncValue<bool>.data(false)) {
    _loadInitialState();
    _listenToPurchaseService();
  }

  /// Listens to purchase status changes from [PurchaseService].
  void _listenToPurchaseService() {
    PurchaseService.premiumStatus.addListener(_onPremiumStatusChanged);
  }

  void _onPremiumStatusChanged() {
    final isPremium = PurchaseService.premiumStatus.value;
    state = AsyncValue<bool>.data(isPremium);
  }

  /// Loads the persisted premium status from Hive.
  Future<void> _loadInitialState() async {
    try {
      final isPremium = await PurchaseService.isPremium();
      state = AsyncValue<bool>.data(isPremium);
      PurchaseService.premiumStatus.value = isPremium;
    } catch (e) {
      state = const AsyncValue<bool>.data(false);
    }
  }

  @override
  void dispose() {
    PurchaseService.premiumStatus.removeListener(_onPremiumStatusChanged);
    super.dispose();
  }

  /// Manually refreshes the premium status from Hive.
  Future<void> refresh() async {
    final isPremium = await PurchaseService.isPremium();
    state = AsyncValue<bool>.data(isPremium);
    PurchaseService.premiumStatus.value = isPremium;
  }
}

/// Provider for the premium/remove-ads purchase state.
final premiumNotifierProvider =
    StateNotifierProvider<PremiumNotifier, AsyncValue<bool>>((ref) {
  return PremiumNotifier();
});
