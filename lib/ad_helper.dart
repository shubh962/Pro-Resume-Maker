import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ================================================================
// AD UNIT IDs — Test IDs
// Real IDs baad mein replace karna
// ================================================================
class AdHelper {
  // --- BANNER ---
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2427221337462218/4913006780';
      // return 'ca-app-pub-7888485986891070/7568460525'; // REAL
    }
    return '';
  }

  // --- INTERSTITIAL ---
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2427221337462218/6937908047';
      // return 'ca-app-pub-XXXXXX/XXXXXX'; // REAL
    }
    return '';
  }

  // --- REWARDED ---
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2427221337462218/2188480953';
      // return 'ca-app-pub-XXXXXX/XXXXXX'; // REAL
    }
    return '';
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}

// ================================================================
// BANNER AD MANAGER
// ================================================================
class BannerAdManager {
  BannerAd? _bannerAd;
  bool isLoaded = false;

  void load(Function onLoaded) {
    if (!AdHelper.isMobile) return;

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isLoaded = false;
        },
      ),
    )..load();
  }

  BannerAd? get ad => _bannerAd;

  void dispose() {
    _bannerAd?.dispose();
  }
}

// ================================================================
// INTERSTITIAL AD MANAGER
// Smart frequency control — not every time
// ================================================================
class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _isLoaded = false;

  // Frequency control
  int _actionCount = 0;          // Kitni baar action hua
  int _nextShowAt = 0;           // Kitne pe dikhana hai
  final Random _random = Random();

  InterstitialAdManager() {
    _setNextShowAt(); // Initial threshold set karo
  }

  // Next show threshold — 2 se 4 ke beech random
  void _setNextShowAt() {
    _nextShowAt = _actionCount + _random.nextInt(3) + 2; // 2, 3, ya 4
  }

  void load() {
    if (!AdHelper.isMobile) return;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isLoaded = false;
              _setNextShowAt(); // Next threshold reset
              load(); // Reload
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isLoaded = false;
              load();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _isLoaded = false;
        },
      ),
    );
  }

  // Har action pe call karo — automatically decide karega show karna hai ya nahi
  void tryShow() {
    if (!AdHelper.isMobile) return;

    _actionCount++;

    // Sirf tab dikhao jab counter threshold pe pahunche
    if (_actionCount >= _nextShowAt && _isLoaded && _ad != null) {
      _ad!.show();
      _isLoaded = false;
    }
  }

  bool get isLoaded => _isLoaded;
}

// ================================================================
// REWARDED AD MANAGER
// ================================================================
class RewardedAdManager {
  RewardedAd? _ad;
  bool _isLoaded = false;

  void load() {
    if (!AdHelper.isMobile) return;

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
        },
        onAdFailedToLoad: (_) {
          _isLoaded = false;
        },
      ),
    );
  }

  void show({
    required VoidCallback onRewarded,
    required VoidCallback onNotLoaded,
  }) {
    if (!_isLoaded || _ad == null) {
      onNotLoaded();
      return;
    }

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isLoaded = false;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isLoaded = false;
        load();
        onNotLoaded();
      },
    );

    _ad!.show(
      onUserEarnedReward: (_, reward) {
        onRewarded();
      },
    );
  }

  bool get isLoaded => _isLoaded;
}