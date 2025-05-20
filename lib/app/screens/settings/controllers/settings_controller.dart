import 'dart:developer';

import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/constant.dart';

class SettingsController extends GetxController {
  var isAdLoaded = false.obs;

  shareApp() async {
    final text = Constants.remoteConfig?.getString("Ios_share_app_text") ?? "";
    if (text.isEmpty) {
      print("Share text is empty");
    } else {
      final result = await Share.share(text);
      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing my website!');
      }
    }
  }

  void rateApp() async {
    final url =
        'https://play.google.com/store/apps/details?id=com.example.mxplayer';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar("Error", "Could not open Play Store");
    }
  }

  void openTerms() {
    String? url = Constants.termsCondition; // Get the stored URL
    print("URL : $url");
    log(
      "----------------- ${Constants.remoteConfig?.getString('terms_conditions')}",
    );

    Get.toNamed(
      Routes.WEBVIEW,
      arguments: {'url': url, 'title': 'Terms & Conditions'},
    );
  }

  rateUs() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void openAbout() {
    String? url = Constants.aboutApp; // Get the stored URL

    Get.toNamed(
      Routes.WEBVIEW,
      arguments: {'url': url, 'title': 'About MX Player'},
    );
  }

  void logout() {
    // Perform logout logic
    Get.offAllNamed('/login');
  }
}
