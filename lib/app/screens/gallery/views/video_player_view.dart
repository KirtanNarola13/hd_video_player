import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constant.dart';
import '../controller/video_player_controller.dart';

class VideoPlayerView extends GetView<VideoController> {
  final String assetPath;
  final String title;
  const VideoPlayerView({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final VideoController controller = Get.put(VideoController());

    controller.loadVideo(assetPath);

    return Obx(() {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CupertinoPageScaffold(
                backgroundColor: CupertinoColors.black,
                navigationBar: CupertinoNavigationBar(
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.back,
                      size: 26,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  middle: const Text(
                    "Video Player",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.clear,
                      size: 26,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                child: Center(
                  child:
                      controller.isLoading.value
                          ? const CupertinoActivityIndicator()
                          : controller.chewieController.value == null
                          ? const Text(
                            "No video loaded",
                            style: TextStyle(color: CupertinoColors.systemGrey),
                          )
                          : AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Chewie(
                              controller: controller.chewieController.value!,
                            ),
                          ),
                ),
              ),
            ),
            if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
              if (!controller.isAdLoaded.value) AdBannerWidget(),
          ],
        ),
      );
    });
  }
}
