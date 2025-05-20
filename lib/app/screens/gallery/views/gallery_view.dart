import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_video_player/app/screens/gallery/views/video_player_view.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/constant.dart';
import '../controller/gallery_controller.dart';
import '../models/gallery_model.dart';

class GalleryVideoView extends StatelessWidget {
  final AssetPathEntity album;

  GalleryVideoView({required this.album});

  final GalleryController controller = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    controller.setAlbum(album);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(album.name),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isGridView.value ? Icons.grid_on : Icons.list,
              ),
            ),
            onPressed: () => controller.toggleView(),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTING),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.videos.isEmpty) {
                return Center(child: Text("No videos found in this folder"));
              }
              return Obx(
                () =>
                    controller.isGridView.value
                        ? _buildGridView(screenWidth, screenHeight)
                        : _buildListView(screenWidth),
              );
            }),
          ),
          if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
            if (!controller.isAdLoaded.value)
              AdBannerWidget(isInitialAdShow: false),
        ],
      ),
    );
  }

  Widget _buildGridView(double screenWidth, double screenHeight) {
    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.02),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 3 : 2,
        crossAxisSpacing: screenWidth * 0.02,
        mainAxisSpacing: screenHeight * 0.02,
      ),
      itemCount: controller.videos.length,
      itemBuilder:
          (context, index) =>
              _buildVideoCard(controller.videos[index], screenWidth),
    );
  }

  Widget _buildListView(double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.02),
      itemCount: controller.videos.length,
      itemBuilder:
          (context, index) =>
              _buildVideoCard(controller.videos[index], screenWidth),
    );
  }

  Widget _buildVideoCard(VideoModel video, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        File? file = await video.asset.file;
        if (file != null && file.existsSync()) {
          Get.to(
            () => VideoPlayerView(
              assetPath: file.path,
              title: video.title.isNotEmpty ? video.title : "Untitled Video",
            ),
          );
        } else {
          print("❌ File not found at ${file?.path}");
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<Uint8List?>(
                future: video.asset.thumbnailData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    );
                  }
                  return Container(color: Colors.grey);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title.isNotEmpty ? video.title : "Untitled Video",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  Text(
                    _formatDuration(video.asset.videoDuration),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
