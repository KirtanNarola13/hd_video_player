import 'package:get/get.dart';

class PlaylistModel {
  String name;
  RxList<MediaItem> media; // ✅ Change to store `MediaItem` objects

  PlaylistModel({required this.name, required List<MediaItem> media})
    : media = media.obs; // ✅ Convert List<MediaItem> to RxList<MediaItem>

  /// Convert JSON to `PlaylistModel`
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      name: json['name'],
      media:
          (json['media'] as List?)
              ?.map((item) => MediaItem.fromJson(item))
              .toList() ??
          [], // ✅ Ensure backward compatibility
    );
  }

  /// Convert `PlaylistModel` to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'media':
          media
              .map((item) => item.toJson())
              .toList(), // ✅ Convert objects to JSON
    };
  }
}

class MediaItem {
  final String path;
  final String title;
  final String? thumbnail;
  final String duration;

  MediaItem({
    required this.path,
    required this.title,
    this.thumbnail,
    required this.duration,
  });

  /// Convert JSON to `MediaItem`
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      path: json['path'],
      title: json['title'],
      thumbnail: json['thumbnail'] != null ? json['thumbnail'] : null,
      duration: json['duration'],
    );
  }

  /// Convert `MediaItem` to JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'thumbnail': thumbnail, // Store file path instead of File object
      'duration': duration,
    };
  }
}
