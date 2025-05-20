import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/music_model.dart';

class MusicController extends GetxController {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final RxList<Music> songs = <Music>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAdLoaded = false.obs;
  final RxBool hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAndRequestPermissions();
  }

  Future<void> checkAndRequestPermissions() async {
    hasPermission.value = await _audioQuery.permissionsStatus();
    if (!hasPermission.value) {
      hasPermission.value = await _audioQuery.permissionsRequest();
    }
    if (hasPermission.value) {
      fetchAllSongs();
    }
  }

  Future<void> fetchAllSongs() async {
    try {
      isLoading.value = true;
      final List<SongModel> audioFiles = await _audioQuery.querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      songs.value =
          audioFiles
              .where((song) => _isValidAudioFile(song.data))
              .map(
                (song) => Music(
                  title: song.title,
                  artist: song.artist ?? "Unknown Artist",
                  filePath: song.data,
                  duration: song.duration ?? 0,
                  album: song.album ?? "Unknown Album",
                  id: song.id,
                ),
              )
              .toList();

      print("✅ Fetched ${songs.length} songs");
    } catch (e) {
      print("❌ Error fetching songs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidAudioFile(String path) {
    // Filter system files and verify audio extensions
    return !path.contains('/android_secure/') &&
        [
          '.mp3',
          '.wav',
          '.m4a',
          '.aac',
          '.flac',
          '.ogg',
          '.mp4',
          '.wma',
        ].any((ext) => path.toLowerCase().endsWith(ext));
  }
}
