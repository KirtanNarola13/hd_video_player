import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../assets.dart';
import '../../../utils/constant.dart';
import '../controller/folder_controller.dart';
import 'gallery_view.dart';

class FolderListScreen extends StatelessWidget {
  final FileGalleryController controller = Get.put(FileGalleryController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar:
          (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false) &&
                  !controller.isAdLoaded.value
              ? AdBannerWidget(isInitialAdShow: false)
              : null,

      body: CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            "Gallery",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: CupertinoColors.systemGrey6,
        ),
        child: Obx(() {
          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: controller.fetchAllVideoFolders,
              ),

              if (controller.isLoading.value)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(radius: screenWidth * 0.04),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Loading your gallery...",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (controller.folders.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Images.icEmptyData,
                          width: screenWidth * 0.4,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Empty Media Player",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: Text(
                            "Your playlist is empty. Add songs and videos to create your personalized player.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyEmptyText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var folder = controller.folders[index];

                    if (folder == null) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () {
                        if (folder.album != null)
                          Get.to(() => GalleryVideoView(album: folder.album!));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.04,
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.005,
                          horizontal: screenWidth * 0.04,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.folderContainerBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              Images.icFolder,
                              width: screenWidth * 0.12,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    folder.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                      color: CupertinoColors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    "${folder.videoCount} videos",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
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
                                CupertinoIcons.right_chevron,
                                size: screenWidth * 0.05,
                                color: CupertinoColors.activeBlue,
                              ),
                              onPressed: () {
                                Get.to(
                                  () => GalleryVideoView(album: folder.album!),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: controller.folders.length),
                ),
            ],
          );
        }),
      ),
    );
  }
}
