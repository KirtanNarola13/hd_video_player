// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:hd_video_player/app/screens/music/views/music_player_view.dart';
//
// import '../../../../assets.dart';
// import '../../../utils/constant.dart';
// import '../controllers/music_controller.dart';
//
// class MusicView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final MusicController controller = Get.find();
//     controller.fetchAllSongs();
//     return Scaffold(
//       body: CupertinoPageScaffold(
//         navigationBar: CupertinoNavigationBar(
//           middle: Text(
//             "My Music",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           backgroundColor: CupertinoColors.systemGrey6,
//         ),
//         child: RefreshIndicator(
//           onRefresh: controller.fetchAllSongs,
//           child: Column(
//             children: [
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoading.value) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CupertinoActivityIndicator(radius: 15),
//                           SizedBox(height: 10),
//                           Text(
//                             "Searching for songs...",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   if (controller.songs.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(Images.icEmptyData),
//                           SizedBox(height: 10),
//                           Text(
//                             "Empty Song",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                           SizedBox(
//                             width: Get.width * 0.8,
//                             child: Text(
//                               "Your playlist is empty .add songs and Videos to create your personalised player",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.greyEmptyText,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   return CupertinoScrollbar(
//                     child: ListView.builder(
//                       padding: EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 16,
//                       ),
//                       itemCount: controller.songs.length,
//                       itemBuilder: (context, index) {
//                         final song = controller.songs[index];
//
//                         return GestureDetector(
//                           onTap: () {
//                             Get.to(
//                               MusicPlayerView(
//                                 playlist: controller.songs,
//                                 currentIndex: index,
//                               ),
//                             );
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               vertical: 12,
//                               horizontal: 12,
//                             ),
//                             margin: EdgeInsets.only(bottom: 8),
//                             decoration: BoxDecoration(
//                               color: CupertinoColors.systemGrey6,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Container(
//                                     width: 50,
//                                     height: 50,
//                                     color: CupertinoColors.systemGrey4,
//                                     child: Icon(
//                                       CupertinoIcons.music_note,
//                                       size: 28,
//                                       color: CupertinoColors.systemGrey,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         song.title,
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           color: CupertinoColors.black,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         song.artist,
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: CupertinoColors.systemGrey,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 CupertinoButton(
//                                   padding: EdgeInsets.zero,
//                                   child: Icon(
//                                     CupertinoIcons.play_arrow,
//                                     size: 28,
//                                     color: CupertinoColors.activeBlue,
//                                   ),
//                                   onPressed: () {
//                                     Get.to(
//                                       MusicPlayerView(
//                                         playlist: controller.songs,
//                                         currentIndex: index,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 }),
//               ),
//               if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
//                 if (!controller.isAdLoaded.value)
//                   AdBannerWidget(isInitialAdShow: false),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../assets.dart';
import '../../../utils/constant.dart';
import '../../playlist/views/music_player_view.dart';
import '../controllers/music_controller.dart';
import '../models/music_model.dart';

class MusicView extends StatelessWidget {
  final MusicController controller = Get.put(MusicController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            "My Music",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          backgroundColor: CupertinoColors.systemGrey6,
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingIndicator();
                }

                if (!controller.hasPermission.value) {
                  return _buildPermissionRequest();
                }

                if (controller.songs.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildSongList();
              }),
            ),
            if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
              if (!controller.isAdLoaded.value)
                AdBannerWidget(isInitialAdShow: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return CupertinoScrollbar(
      child: RefreshIndicator(
        onRefresh: controller.fetchAllSongs,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          itemCount: controller.songs.length,
          itemBuilder: (context, index) {
            final song = controller.songs[index];
            return _buildSongItem(song, index);
          },
        ),
      ),
    );
  }

  Widget _buildSongItem(Music song, int index) {
    return GestureDetector(
      onTap: () => Get.to(MusicPlayerView(songPath: song.filePath)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkHeight: 50,
              artworkWidth: 50,
              artworkBorder: BorderRadius.circular(8),
              nullArtworkWidget: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.music_note,
                  size: 28,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${song.artist} • ${_formatDuration(song.duration)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.play_arrow,
                size: 28,
                color: CupertinoColors.activeBlue,
              ),
              onPressed:
                  () => Get.to(
                    MusicPlayerView(songPath: controller.songs[index].filePath),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 15),
          SizedBox(height: 10),
          Text(
            "Searching for songs...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Images.icEmptyData),
          SizedBox(height: 10),
          Text(
            "Empty Song",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(width: Get.width * 0.8),
          Text(
            "Your playlist is empty. Add songs and videos to create your personalized player",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.greyEmptyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.music_mic, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "Permission Required",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          CupertinoButton(
            child: Text("Grant Permission"),
            onPressed: controller.checkAndRequestPermissions,
          ),
        ],
      ),
    );
  }
}
