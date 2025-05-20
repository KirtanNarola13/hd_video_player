// main.dart
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hd_video_player/service/admobService.dart';

import 'app/routes/app_pages.dart';
import 'app/utils/constant.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding before async calls

  await MobileAds.instance.initialize(); // Await for proper initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  /// Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  await loadFireConfig(); // Ensuring Remote Config is loaded before app starts

  Get.put(AdMobService());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      title: "HD Video Player",
      theme: ThemeData(fontFamily: 'font'),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

Future<void> loadFireConfig() async {
  Constants.remoteConfig = FirebaseRemoteConfig.instance;

  await Constants.remoteConfig?.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 0),
      minimumFetchInterval: const Duration(
        seconds: 0,
      ), // Avoids excessive fetching
    ),
  );

  try {
    await Constants.remoteConfig?.fetchAndActivate().timeout(
      const Duration(seconds: 10),
    );
  } catch (err) {
    debugPrint('Error fetching Remote Config: $err'); // Improved error handling
  }
}
