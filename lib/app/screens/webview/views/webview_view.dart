import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../../utils/constant.dart';
import '../controllers/webview_controller.dart';

class WebViewView extends GetView<WebViewController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.title), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(controller.url)),
              ),
            ),
          ),
          if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
            if (!controller.isAdLoaded.value) AdBannerWidget(),
        ],
      ),
    );
  }
}
