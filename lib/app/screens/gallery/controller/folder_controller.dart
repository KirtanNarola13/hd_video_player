import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class FolderModel {
  final String path;
  final String name;
  final int videoCount;
  final AssetPathEntity? album; // ✅ Store album reference for gallery folders

  FolderModel({
    required this.path,
    required this.name,
    required this.videoCount,
    this.album, // Optional field for gallery folders
  });
}

class FileGalleryController extends GetxController {
  var folders = <FolderModel>[].obs;
  var isLoading = true.obs;
  var isAdLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllVideoFolders();
  }

  Future<void> fetchAllVideoFolders() async {
    isLoading.value = true;
    print("====== [START] Fetching All Video Folders ======");

    List<FolderModel> allFolders = [];

    try {
      List<FolderModel> fileSystemFolders =
          await _fetchVideoFoldersFromFileSystem();
      List<FolderModel> galleryFolders = await _fetchVideoFoldersFromGallery();

      allFolders.addAll(fileSystemFolders);
      allFolders.addAll(galleryFolders);

      folders.value = _removeDuplicateFolders(allFolders);

      print(
        "====== ✅ [RESULT] Total Folders with Videos Found: ${folders.length} ======",
      );
      for (var folder in folders) {
        print(
          "📁 Folder: ${folder.name} | Videos: ${folder.videoCount} | Path: ${folder.path}",
        );
      }
    } catch (e) {
      print("====== ❌ [ERROR] Fetching Video Folders Failed: $e ======");
    }

    isLoading.value = false;
    print("====== [END] Fetching All Video Folders ======");
  }

  // Fetch video folders from the file system
  Future<List<FolderModel>> _fetchVideoFoldersFromFileSystem() async {
    List<FolderModel> folderList = [];
    try {
      Directory? scanDir = await _getVideoDirectory();
      if (scanDir == null || !scanDir.existsSync()) {
        print("====== ❌ [ERROR] File System Video folder not found! ======");
        return [];
      }

      print(
        "====== 📂 [INFO] Scanning File System Directory: ${scanDir.path} ======",
      );

      Map<String, int> folderVideoCount = {}; // ✅ Store folder -> video count

      await for (var entity in scanDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && _isVideoFile(entity.path)) {
          String folderPath = entity.parent.path;
          folderVideoCount[folderPath] =
              (folderVideoCount[folderPath] ?? 0) + 1;
        }
      }

      // Add folders with video counts
      folderVideoCount.forEach((path, count) {
        String folderName = path.split(Platform.pathSeparator).last;
        folderList.add(
          FolderModel(path: path, name: folderName, videoCount: count),
        );
        print(
          "📂 [ADDING FILE SYSTEM FOLDER] Name: $folderName, Videos: $count, Path: $path",
        );
      });
    } catch (e) {
      print(
        "====== ❌ [ERROR] Fetching File System Video Folders Failed: $e ======",
      );
    }
    return folderList;
  }

  // Fetch video folders from the gallery
  Future<List<FolderModel>> _fetchVideoFoldersFromGallery() async {
    List<FolderModel> folderList = [];
    try {
      var permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        print("====== ❌ [ERROR] No permission to access gallery ======");
        return [];
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      for (var album in albums) {
        int videoCount =
            await album.assetCountAsync; // ✅ Fetch asset count asynchronously
        if (videoCount > 0) {
          folderList.add(
            FolderModel(
              path: album.name,
              name: album.name,
              videoCount: videoCount,
              album: album, // ✅ Store album reference
            ),
          );
          print(
            "📂 [ADDING GALLERY FOLDER] Name: ${album.name}, Videos: $videoCount",
          );
        }
      }
    } catch (e) {
      print(
        "====== ❌ [ERROR] Fetching Gallery Video Folders Failed: $e ======",
      );
    }
    return folderList;
  }

  Future<Directory?> _getVideoDirectory() async {
    try {
      if (Platform.isAndroid) {
        Directory? externalDir = await getExternalStorageDirectory();
        return externalDir != null
            ? Directory("${externalDir.path}/Documents")
            : Directory("/storage/emulated/0/Movies");
      } else if (Platform.isIOS) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        Directory videoDir = Directory("${appDocDir.path}/Videos");

        // ✅ Check if the folder exists, else create it
        if (!(await videoDir.exists())) {
          await videoDir.create(recursive: true);
        }

        return videoDir;
      }
    } catch (e) {
      print("====== ❌ [ERROR] Unable to get video directory: $e ======");
    }
    return null;
  }

  bool _isVideoFile(String path) {
    const videoExtensions = ['.mp4', '.mkv', '.avi', '.mov', '.flv'];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  List<FolderModel> _removeDuplicateFolders(List<FolderModel> folders) {
    final uniqueFolders = <String, FolderModel>{};
    for (var folder in folders) {
      uniqueFolders[folder.path] = folder;
    }
    return uniqueFolders.values.toList();
  }
}
