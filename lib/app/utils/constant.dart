import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hd_video_player/app/screens/home/controller/home_controller.dart';

import '../../service/admobService.dart';

class Constants {
  static FirebaseRemoteConfig? remoteConfig;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static int openAppCount = 0;
  static int interstitialCount = 0;

  /// Configs
  static String? get termsCondition =>
      remoteConfig?.getString('terms_conditions');
  static String? get aboutApp => remoteConfig?.getString('about_app');
  static int? get getInterstitialCount =>
      remoteConfig?.getInt('Interstial_Ads_Count');
}

class AdBannerWidget extends StatefulWidget {
  bool isInitialAdShow = true;
  AdBannerWidget({Key? key, this.isInitialAdShow = true}) : super(key: key);
  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  HomeController homeController = Get.find();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            print("============= Ad Loaded =============");
            _isAdLoaded = true;
            if (widget.isInitialAdShow) {
              Future.delayed(const Duration(seconds: 1), () {
                homeController.showAdIfAvailable();
              });
            }
            // calculatorsController.isAdLoaded.value = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            print("============= Ad Loaded Failed =============");
            _isAdLoaded = false;
            // calculatorsController.isAdLoaded.value = false;
          });
          print('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          width: _bannerAd!.size.width.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
        : SizedBox.shrink();
  }
}
