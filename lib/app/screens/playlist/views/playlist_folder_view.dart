import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hd_video_player/app/screens/gallery/views/video_player_view.dart';

import '../../../../assets.dart';
import '../../../utils/constant.dart';
import '../controllers/playlist_controller.dart';
import '../models/playlist_model.dart';

class PlaylistFolderView extends StatelessWidget {
  final PlaylistModel playlist;
  final PlaylistController controller = Get.put(PlaylistController());

  PlaylistFolderView({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name.toString().capitalizeFirst ?? ""),
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
            icon: Icon(Icons.add),
            onPressed: () => controller.addMediaToPlaylist(playlist.name),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (playlist.media.isEmpty) {
                return _buildEmptyState();
              }
              return controller.isGridView.value
                  ? _buildGridView()
                  : _buildListView();
            }),
          ),
          if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
            if (!controller.isAdLoaded.value) AdBannerWidget(),
        ],
      ),
    );
  }

  // Widget _buildEmptyState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.folder_off, size: 80, color: Colors.grey),
  //         SizedBox(height: 10),
  //         Text(
  //           "Empty Playlist",
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //         ),
  //         SizedBox(height: 5),
  //         Text(
  //           "Add songs and videos to create your personalized player.",
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontSize: 14, color: Colors.grey),
  //         ),
  //         SizedBox(height: 20),
  //         ElevatedButton(
  //           onPressed: () => controller.addMediaToPlaylist(playlist.name),
  //           child: Text("Add Media"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Images.icEmptyData),
          SizedBox(height: 10),
          Text(
            "Empty playlist",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(
            width: Get.width * 0.8,
            child: Text(
              "Your playlist is empty. Add songs and videos to create your personalized player.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.greyEmptyText,
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.02),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => controller.addMediaToPlaylist(playlist.name),
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.white.withOpacity(0.3),
              child: Ink(
                height: Get.height * 0.05,
                width: Get.width * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.addPlaylistDarkBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Add Media",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Get.width * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
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
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: playlist.media.length,
      itemBuilder: (context, index) => _buildMediaCard(playlist.media[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: playlist.media.length,
      itemBuilder: (context, index) => _buildMediaCard(playlist.media[index]),
    );
  }

  Widget _buildMediaCard(MediaItem media) {
    return GestureDetector(
      onTap:
          () => Get.to(
            () => VideoPlayerView(assetPath: media.path, title: media.title),
          ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image:
                      media.thumbnail != null
                          ? DecorationImage(
                            image: controller.getThumbnailImage(
                              media.thumbnail,
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                  color: media.thumbnail == null ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    media.thumbnail == null
                        ? Center(
                          child: Icon(
                            Icons.video_library,
                            size: 50,
                            color: Colors.grey[700],
                          ),
                        )
                        : null,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(media.duration),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
