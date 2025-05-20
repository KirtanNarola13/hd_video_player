import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../service/admobService.dart';
import '../../../utils/constant.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  var selectedIndex = 0.obs;
  var isAdLoaded = false.obs;

  // var isNativeAdLoaded = false.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final AdMobService adMobService = Get.find();

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false) {
      // adMobService.loadNativeAd();
      adMobService.loadInterstitialAd(
        onAdLoaded: () {
          isAdLoaded.value = true;
        },
        onAdFailed: (error) {
          isAdLoaded.value = false;
          print("⚠️ Interstitial Ad Failed to Load: $error");
        },
      );
    }
  }

  void showAdIfAvailable() {
    print("💡 Ad Instance: ${adMobService.interstitialAd}");

    if (isAdLoaded.value &&
        Constants.interstitialCount > Constants.getInterstitialCount!) {
      adMobService.showInterstitialAd(
        onAdClosed: () {
          isAdLoaded.value = false;
          _loadInterstitialAd(); // Load a new ad after showing the current one
        },
      );
      Constants.interstitialCount = 0;
    } else {
      print("⚠️ No Interstitial Ad Available");
      Constants.interstitialCount = Constants.interstitialCount! + 1;
      _loadInterstitialAd(); // Attempt to load a new ad
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("App Lifecycle State: $state");
    if (state == AppLifecycleState.resumed) {
      print("Resumed - Checking if App Open Ad should show");
      if ((Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)) {
        adMobService.showAppOpenAd(() {});
      } else {
        Constants.openAppCount = Constants.openAppCount + 1;
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    super.onClose();
  }
}
