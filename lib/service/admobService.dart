import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app/utils/constant.dart';

class AdMobService extends GetxController {
  InterstitialAd? interstitialAd;
  AppOpenAd? appOpenAd;
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;
  RxBool isAppOpenAdLoaded = false.obs;

  /// 🔹 Get Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return Constants.remoteConfig?.getString("android_banner") ?? "";
    } else if (Platform.isIOS) {
      return Constants.remoteConfig?.getString("ios_banner") ?? "";
    }
    throw UnsupportedError("Unsupported platform");
  }

  /// 🔹 Get Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return Constants.remoteConfig?.getString("android_interstitial") ?? "";
    } else if (Platform.isIOS) {
      return Constants.remoteConfig?.getString("ios_interstitial") ?? "";
    }
    throw UnsupportedError("Unsupported platform");
  }

  /// 🔹 Get App Open Ad Unit ID
  static String get openAppAdUnitId {
    if (Platform.isAndroid) {
      return Constants.remoteConfig?.getString("android_app_open") ?? "";
    } else if (Platform.isIOS) {
      return Constants.remoteConfig?.getString("ios_app_open") ?? "";
    }
    throw UnsupportedError("Unsupported platform");
  }

  /// 🔹 Get Native Ad Unit ID
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return Constants.remoteConfig?.getString("android_native") ?? "";
    } else if (Platform.isIOS) {
      return Constants.remoteConfig?.getString("ios_native_ad") ?? "";
    }
    throw UnsupportedError("Unsupported platform");
  }

  void loadInterstitialAd({
    Function()? onAdLoaded,
    Function(String)? onAdFailed,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          onAdLoaded?.call();
          print("✅ Interstitial Ad Loaded!");
        },
        onAdFailedToLoad: (error) {
          interstitialAd = null;
          onAdFailed?.call(error.message);
          print("❌ Interstitial Ad Failed: ${error.message}");
        },
      ),
    );
  }

  void showInterstitialAd({Function()? onAdClosed}) {
    if (interstitialAd != null) {
      print("🎯 Showing Interstitial Ad...");
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print("✅ Ad Closed");
          interstitialAd = null;
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print("⚠️ Ad Show Failed: ${error.message}");
          interstitialAd = null;
        },
      );
      interstitialAd!.show();
    } else {
      print("⚠️ No Interstitial Ad Available to Show");
    }
  }

  void disposeInterstitialAd() {
    interstitialAd?.dispose();
    interstitialAd = null;
  }

  // /// 🚀 Load Interstitial Ad
  // void loadInterstitialAd() {
  //   if (interstitialAd != null) {
  //     print("⚠️ Interstitial Ad already loaded, skipping...");
  //     return;
  //   }
  //
  //   InterstitialAd.load(
  //     adUnitId: AdMobService.interstitialAdUnitId,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (InterstitialAd ad) {
  //         print("✅ Interstitial Ad Loaded Successfully");
  //         interstitialAd = ad;
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         print("❌ Interstitial Ad Failed to Load: $error");
  //         interstitialAd = null;
  //       },
  //     ),
  //   );
  // }
  //
  // /// 🚀 Show Interstitial Ad
  // void showInterstitialAd(Function() mainAction) {
  //   if (interstitialAd == null) {
  //     print("🔴 No interstitial ad available, loading a new one...");
  //     loadInterstitialAd();
  //     mainAction();
  //     return;
  //   }
  //
  //   InterstitialAd? tempAd = interstitialAd;
  //   interstitialAd = null; // Prevent duplicate ads
  //
  //   tempAd?.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdDismissedFullScreenContent: (ad) {
  //       print("✅ Interstitial Ad Dismissed.");
  //       ad.dispose();
  //       interstitialAd = null;
  //       loadInterstitialAd(); // Load next ad
  //       mainAction(); // Proceed with the main action
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       print("❌ Ad Failed to Show: $error");
  //       ad.dispose();
  //       interstitialAd = null;
  //       loadInterstitialAd();
  //       mainAction();
  //     },
  //   );
  //
  //   tempAd?.show();
  // }

  /// 🚀 Load Native Ad
  /// Loads a native ad.
  void loadNativeAd() {
    debugPrint('========== START: Loading Native Ad ==========');

    nativeAd = NativeAd(
      adUnitId: AdMobService.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('========== SUCCESS: Native Ad Loaded ==========');
          debugPrint('========== Ad Details: $ad ==========');
          isNativeAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('========== ERROR: Native Ad Failed to Load ==========');
          debugPrint('========== Ad Object: $ad ==========');
          debugPrint('========== Error Details: $error ==========');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      // Styling
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.purple,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.cyan,
          backgroundColor: Colors.red,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.red,
          backgroundColor: Colors.cyan,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.brown,
          backgroundColor: Colors.amber,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    );

    debugPrint('========== CALLING: nativeAd.load() ==========');
    nativeAd?.load();
    debugPrint('========== END: Native Ad Load Function ==========');
  }

  Widget getNativeAdWidget() {
    if (!isNativeAdLoaded || nativeAd == null) {
      return SizedBox.shrink(); // Return an empty widget if not loaded
    }
    return Container(
      height: 100, // Adjust based on your layout
      child: AdWidget(ad: nativeAd!),
    );
  }

  loadAppOpenAd() {
    print("*************LOAD APP OPEN***************");
    if (appOpenAd == null) {
      AppOpenAd.load(
        adUnitId: AdMobService.openAppAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            appOpenAd = ad;
            isAppOpenAdLoaded.value = true;
            print("*************LOAD APP OPEN SUCCESS***************");
          },
          onAdFailedToLoad: (error) {
            print('AppOpenAd failed to load: $error');
            // Handle the error.
          },
        ),
      );
    }
  }

  showAppOpenAd(Function() mainAction) {
    print("*************SHOW APP OPEN***************");
    if (appOpenAd != null) {
      appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          mainAction();
          loadAppOpenAd();
          Constants.openAppCount = 0;
        },
      );
      appOpenAd?.show();
      appOpenAd = null;
    } else {
      mainAction();
      loadAppOpenAd();
    }
  }
}
