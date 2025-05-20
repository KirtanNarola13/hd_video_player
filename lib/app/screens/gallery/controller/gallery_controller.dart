import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/gallery_model.dart';

class GalleryController extends GetxController {
  var videos = <VideoModel>[].obs;
  var isLoading = false.obs;
  var isAdLoaded = false.obs;
  var isGridView = true.obs; // ✅ Move toggle state here
  AssetPathEntity? selectedAlbum;

  var allVideosGallery = <AssetEntity>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    fetchAllVideos();
    super.onInit();
  }

  // Set the selected album
  void setAlbum(AssetPathEntity album) {
    selectedAlbum = album;
    fetchVideosFromAlbum();
  }

  /// Fetches all videos from the device gallery
  Future<void> fetchAllVideos() async {
    print("📽 Fetching videos from gallery...");

    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      print("❌ Permission denied for media access");
      return;
    }

    try {
      List<AssetPathEntity> videoAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      List<AssetEntity> allVideos = [];
      for (var album in videoAlbums) {
        final List<AssetEntity> videos = await album.getAssetListRange(
          start: 0,
          end: await album.assetCountAsync,
        );
        allVideos.addAll(videos);
      }

      allVideosGallery.assignAll(allVideos);
      print("✅ Fetched ${allVideosGallery.length} videos from gallery");
    } catch (e) {
      print("❌ Error fetching videos: $e");
    }
  }

  // Fetch videos from the selected album
  Future<void> fetchVideosFromAlbum() async {
    if (selectedAlbum == null) {
      print("❌ No album selected");
      return;
    }

    isLoading.value = true;
    try {
      List<AssetEntity> media = await selectedAlbum!.getAssetListPaged(
        page: 0,
        size: 50,
      );

      videos.value =
          media
              .map((e) => VideoModel(asset: e, title: e.title ?? 'Untitled'))
              .toList();
    } catch (e) {
      print("❌ Error fetching videos: $e");
    }
    isLoading.value = false;
  }

  // ✅ Toggle Grid/List View
  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}
