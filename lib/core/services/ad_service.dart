import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdService {
  // TEST IDs - REPLACE WITH REAL IDs IN PRODUCTION
  // Android Test ID: ca-app-pub-3940256099942544/6300978111
  // iOS Test ID: ca-app-pub-3940256099942544/2934735716
  
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // Production IDs
    return Platform.isAndroid 
        ? 'ca-app-pub-4860232288978751/5100757128' 
        : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadRewardedAd(); // Preload Rewarded Ad
  }

  BannerAd createBannerAd({required Function() onLoaded, Function(LoadAdError)? onFail, AdSize size = AdSize.banner}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
           debugPrint('Ad Loaded');
           onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad Failed to Load: $error');
          ad.dispose();
          if (onFail != null) onFail(error);
        },
      ),
    );
  }
  // Rewarded Ad ID
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
      }
    }
    // Production IDs
    return Platform.isAndroid 
        ? 'ca-app-pub-4860232288978751/5992549856' 
        : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
  }

  RewardedAd? _rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({required Function() onUserEarnedReward, Function()? onDismissed}) {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      loadRewardedAd(); // Try loading for next time
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Preload next one
        if (onDismissed != null) onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onUserEarnedReward();
    });
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService());
