import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/playlist_model.dart';

class PlaylistController extends GetxController {
  var playlists = <PlaylistModel>[].obs;
  var isLoading = false.obs;
  var isGridView = true.obs;
  var isAdLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlaylists();
  }

  /// Toggle between Grid/List view
  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  /// Load playlists from SharedPreferences
  Future<void> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('playlists');

      if (data != null) {
        playlists.assignAll(
          List<PlaylistModel>.from(
            jsonDecode(data).map((x) => PlaylistModel.fromJson(x)),
          ),
        );
      }
    } catch (e) {
      print("❌ Error loading playlists: $e");
    }
  }

  /// Save playlists to SharedPreferences
  Future<void> savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'playlists',
        jsonEncode(playlists.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      print("❌ Error saving playlists: $e");
    }
  }

  ImageProvider<Object> getThumbnailImage(String? thumbnailPath) {
    if (thumbnailPath != null && File(thumbnailPath).existsSync()) {
      return FileImage(File(thumbnailPath));
    } else {
      return AssetImage("assets/default_thumbnail.png"); // Fallback image
    }
  }

  /// Add a new playlist
  Future<void> addPlaylist(String name) async {
    playlists.add(PlaylistModel(name: name, media: []));
    await savePlaylists();
  }

  /// Pick media files and add them to the selected playlist
  Future<void> addMediaToPlaylist(String playlistName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'mp4', 'mkv', 'avi', 'mov'],
      );

      if (result == null) return; // User canceled file picking

      List<MediaItem> selectedMedia = [];

      for (var filePath in result.paths) {
        if (filePath == null) continue;

        File file = File(filePath);
        String fileName = file.uri.pathSegments.last;
        String? thumbnail = await _generateThumbnail(filePath);

        selectedMedia.add(
          MediaItem(
            path: filePath,
            title: fileName,
            thumbnail: thumbnail,
            duration:
                "Unknown", // Placeholder, replace with actual duration if needed
          ),
        );
      }

      int playlistIndex = playlists.indexWhere(
        (playlist) => playlist.name == playlistName,
      );

      if (playlistIndex != -1) {
        playlists[playlistIndex].media.addAll(selectedMedia);
        playlists.refresh(); // Ensure UI updates
        await savePlaylists();
      }
    } catch (e) {
      print("❌ Error adding media: $e");
    }
  }

  /// Generate a video thumbnail
  Future<String?> _generateThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String thumbnailPath =
          await VideoThumbnail.thumbnailFile(
            video: videoPath,
            thumbnailPath: tempDir.path,
            imageFormat: ImageFormat.PNG,
            maxHeight: 100,
            quality: 75,
          ) ??
          '';

      if (thumbnailPath.isEmpty || !File(thumbnailPath).existsSync()) {
        print("❌ Thumbnail generation failed: File does not exist.");
        return null;
      }

      print("✅ Thumbnail generated: $thumbnailPath");
      return thumbnailPath;
    } catch (e) {
      print("❌ Error generating thumbnail: $e");
      return null;
    }
  }
}
