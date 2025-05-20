import 'package:get/get.dart';
import 'package:hd_video_player/service/admobService.dart';

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  AdMobService adMobService = Get.find();
  @override
  void onInit() {
    super.onInit();
    adMobService.loadAppOpenAd();
  }

  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed(Routes.HOME);
    });
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
