import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/providers/premium_provider.dart';
import '../../core/services/ad_service.dart';

/// A non-intrusive banner ad that sits at the bottom of a page.
///
/// Uses a standard banner size (320×50 dp). The banner automatically hides
/// when the user has purchased the premium/remove-ads upgrade.
///
/// The banner automatically loads when the widget is inserted into the tree
/// and disposes the ad when removed. If AdMob fails to load the ad, a
/// zero-height [SizedBox.shrink] is shown so the layout remains stable.
class AdBanner extends ConsumerStatefulWidget {
  /// Creates an [AdBanner].
  const AdBanner({super.key});

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    if (!AdService.isInitialized) {
      debugPrint('[AdBanner] AdMob not initialized — skipping ad load');
      return;
    }

    BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdBanner] Failed to load ad: $error');
          ad.dispose();
          // Keep _loaded false so nothing is shown instead of a broken ad.
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    // Hide ads entirely if the user has purchased the premium upgrade.
    final premiumAsync = ref.watch(premiumNotifierProvider);
    final isPremium = premiumAsync.valueOrNull ?? false;

    if (isPremium) {
      return const SizedBox.shrink();
    }

    if (!_loaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final ad = _bannerAd!;
    return Container(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      child: AdWidget(ad: ad),
    );
  }
}
