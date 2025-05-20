import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../assets.dart';
import '../../../utils/constant.dart';
import '../controllers/playlist_controller.dart';
import 'playlist_folder_view.dart';

class PlaylistScreen extends StatelessWidget {
  final PlaylistController controller = Get.put(PlaylistController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Playlists"),
        actions: [
          Obx(
            () =>
                controller.playlists.isNotEmpty
                    ? GestureDetector(
                      onTap: () => _showAddPlaylistDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.primaryColor),
                          SizedBox(width: 4),
                          Text(
                            "Add New",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SizedBox(),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (controller.playlists.isEmpty) {
                    return _buildEmptyState(constraints);
                  }

                  int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: constraints.maxWidth * 0.02,
                      mainAxisExtent: constraints.maxHeight * 0.19,
                      mainAxisSpacing: constraints.maxHeight * 0.02,
                    ),
                    itemCount: controller.playlists.length,
                    itemBuilder: (context, index) {
                      var playlist = controller.playlists[index];
                      return GestureDetector(
                        onTap:
                            () => Get.to(
                              () => PlaylistFolderView(playlist: playlist),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.folderContainerBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                Images.icFolder,
                                width: constraints.maxWidth * 0.13,
                              ),
                              SizedBox(height: constraints.maxHeight * 0.01),
                              AutoSizeText(
                                playlist.name.capitalizeFirst ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                minFontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${playlist.media.length} Videos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greyEmptyText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
                if (!controller.isAdLoaded.value) AdBannerWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BoxConstraints constraints) {
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
            width: constraints.maxWidth * 0.8,
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
          SizedBox(height: constraints.maxHeight * 0.02),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _showAddPlaylistDialog(Get.context!),
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.white.withOpacity(0.3),
              child: Ink(
                height: constraints.maxHeight * 0.05,
                width: constraints.maxWidth * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.addPlaylistDarkBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Add Media",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.04,
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

  void _showAddPlaylistDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: Text("New Playlist"),
            content: Column(
              children: [
                Text("Choose a title for your new playlist"),
                SizedBox(height: 10),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: "Playlist Name",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.primaryColor),
                ),
                onPressed: () => Get.back(),
              ),
              CupertinoDialogAction(
                child: Text(
                  "Save",
                  style: TextStyle(color: AppColors.primaryColor),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    controller.addPlaylist(nameController.text);
                    Get.back();
                  }
                },
              ),
            ],
          ),
    );
  }
}
