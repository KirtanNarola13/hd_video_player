import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_video_player/app/screens/gallery/views/video_player_view.dart';

import '../controller/gallery_controller.dart';
import '../models/gallery_model.dart';

class AllVideosView extends StatelessWidget {
  final GalleryController controller = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    controller.fetchAllVideos(); // Fetch all videos on load

    return Scaffold(
      appBar: AppBar(
        title: Text("All Videos"),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isGridView.value ? Icons.grid_on : Icons.list,
              ),
            ),
            onPressed: () => controller.toggleView(),
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
                return Center(child: Text("No videos found"));
              }
              return Obx(
                () =>
                    controller.isGridView.value
                        ? _buildGridView()
                        : _buildListView(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Get.width * 0.02,
        mainAxisSpacing: Get.height * 0.02,
      ),
      itemCount: controller.videos.length,
      itemBuilder:
          (context, index) => _buildVideoCard(controller.videos[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: controller.videos.length,
      itemBuilder:
          (context, index) => _buildVideoCard(controller.videos[index]),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
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
          print("❌ File not found at \${file?.path}");
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
                      padding: const EdgeInsets.all(10),
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
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title.isNotEmpty ? video.title : "Untitled Video",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Text(
                    _formatDuration(video.asset.videoDuration),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
    return "\${twoDigits(duration.inMinutes)}:\${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
