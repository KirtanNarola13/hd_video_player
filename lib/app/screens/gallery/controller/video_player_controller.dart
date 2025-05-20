import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  Rxn<ChewieController> chewieController = Rxn<ChewieController>();
  RxBool isLoading = false.obs;
  RxBool isAdLoaded = false.obs;
  RxBool isFullScreen = false.obs;

  void loadVideo(String filePath) {
    print("======== Loading Video: $filePath ========");
    isLoading.value = true;

    final videoPlayerController = VideoPlayerController.file(File(filePath));

    videoPlayerController
        .initialize()
        .then((_) {
          videoPlayerController.addListener(() {
            if (videoPlayerController.value.position >=
                videoPlayerController.value.duration) {
              onVideoComplete(); // ✅ Trigger action when video stops
            }
          });
          chewieController.value = ChewieController(
            videoPlayerController: videoPlayerController,
            autoPlay: true,
            looping: false,

            allowFullScreen: true,
            autoInitialize: true,
            allowMuting: true,
            allowPlaybackSpeedChanging: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: CupertinoColors.systemBlue,
              bufferedColor: CupertinoColors.systemGrey,
            ),
            draggableProgressBar: true,
            zoomAndPan: true,
            allowedScreenSleep: false,

            overlay: GestureDetector(
              onHorizontalDragUpdate: (details) {
                _seekVideo(details.primaryDelta!);
              },
              onVerticalDragUpdate: (details) {
                _adjustVolumeBrightness(details.primaryDelta!);
              },
            ),
          );

          isLoading.value = false;
          print("======== Video Loaded Successfully ========");
        })
        .catchError((error) {
          isLoading.value = false;
          print("======== Error Loading Video: $error ========");
        });
  }

  void onVideoComplete() {
    print("🎬 Video Stopped - Taking Action!");

    // ✅ Example Actions:
    // Show an Ad
    if (isAdLoaded.value) {
      print("📢 Showing Interstitial Ad...");
    }

    // Navigate to another screen
    // Get.to(() => NextScreen());

    // Log analytics
    // FirebaseAnalytics.instance.logEvent(name: "video_completed");

    // Any other action you want...
  }

  void _seekVideo(double delta) {
    final controller = chewieController.value!.videoPlayerController;
    final currentPosition = controller.value.position;
    final newPosition =
        currentPosition + Duration(seconds: delta > 0 ? 10 : -10);
    controller.seekTo(newPosition);
  }

  void _adjustVolumeBrightness(double delta) {
    if (delta > 0) {
      print("Increasing Volume");
    } else {
      print("Decreasing Brightness");
    }
  }

  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
  }

  @override
  void onClose() {
    chewieController.value?.dispose();
    super.onClose();
  }
}
