import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  BannerAd? _bannerAd1;
  BannerAd? _bannerAd2;
  BannerAd? _bannerAd3;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  /// Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();
  }

  /// Load Banner Ad 1
  void loadBannerAd1() {
    _bannerAd1 = BannerAd(
      adUnitId: 'ca-app-pub-40/4468027928', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Banner Ad 1 Loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner Ad 1 failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd1!.load();
  }

  /// Load Banner Ad 2
  void loadBannerAd2() {
    _bannerAd2 = BannerAd(
      adUnitId: 'ca-app-pub-40/4862811416', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Banner Ad 2 Loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner Ad 2 failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd2!.load();
  }

  /// Load Banner Ad 3
  void loadBannerAd3() {
    _bannerAd3 = BannerAd(
      adUnitId: 'ca-app-pub-48340/8674063916', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Banner Ad 3 Loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner Ad 3 failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd3!.load();
  }

  /// Get Banner Ad 1 Widget
  Widget getBannerAdWidget1() {
    return _bannerAd1 != null
        ? SizedBox(
      height: _bannerAd1!.size.height.toDouble(),
      width: _bannerAd1!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd1!),
    )
        : SizedBox.shrink();
  }

  /// Get Banner Ad 2 Widget
  Widget getBannerAdWidget2() {
    return _bannerAd2 != null
        ? SizedBox(
      height: _bannerAd2!.size.height.toDouble(),
      width: _bannerAd2!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd2!),
    )
        : SizedBox.shrink();
  }

  /// Get Banner Ad 3 Widget
  Widget getBannerAdWidget3() {
    return _bannerAd3 != null
        ? SizedBox(
      height: _bannerAd3!.size.height.toDouble(),
      width: _bannerAd3!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd3!),
    )
        : SizedBox.shrink();
  }

  /// Load an Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-0/2295523671', // Test Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          print('Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial Ad failed to load: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  /// Show an Interstitial Ad
  void showInterstitialAd() {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
      loadInterstitialAd(); // Load another ad for next time
    } else {
      print("Interstitial Ad not loaded yet");
    }
  }
}
