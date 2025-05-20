import 'package:get/get.dart';

class WebViewController extends GetxController {
  late String url;
  late String title;
  var isAdLoaded = false.obs;
  @override
  void onInit() {
    super.onInit();
    // Get arguments from navigation
    url = Get.arguments?['url']?.toString() ?? 'https://www.google.com';
    if (!Uri.parse(url).isAbsolute) {
      url = 'https://www.google.com'; // Fallback to a safe URL
    }

    title = Get.arguments['title'] ?? 'WebView';
  }
}
