import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constant.dart';
import '../models/music_model.dart';

class MusicPlayerView extends StatefulWidget {
  final List<Music> playlist;
  final int currentIndex;

  const MusicPlayerView({
    super.key,
    required this.playlist,
    required this.currentIndex,
  });

  @override
  _MusicPlayerViewState createState() => _MusicPlayerViewState();
}

class _MusicPlayerViewState extends State<MusicPlayerView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;
  bool isLooping = false;
  bool isShuffling = false;
  List<int> shuffledIndices = [];
  var isAdLoaded = false.obs;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNext();
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => duration = d);
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() => position = p);
    });

    // Start playing the song immediately
    await _playSong(widget.playlist[currentIndex].filePath);
  }

  Future<void> _playSong(String url) async {
    await _audioPlayer.stop();
    await _audioPlayer.setSourceDeviceFile(url);

    await _audioPlayer.setReleaseMode(
      isLooping ? ReleaseMode.loop : ReleaseMode.release,
    );
    await _audioPlayer.resume();
    setState(() => isPlaying = true);
  }

  void _playPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => isPlaying = !isPlaying);
  }

  void _playNext() {
    int nextIndex;
    if (isShuffling) {
      if (shuffledIndices.isEmpty) {
        _generateShuffledPlaylist();
      }
      nextIndex = shuffledIndices.removeAt(0);
    } else {
      nextIndex = (currentIndex + 1) % widget.playlist.length;
    }
    _updateSong(nextIndex);
  }

  void _playPrevious() {
    int prevIndex =
        (currentIndex - 1) < 0 ? widget.playlist.length - 1 : currentIndex - 1;
    _updateSong(prevIndex);
  }

  void _updateSong(int index) async {
    currentIndex = index;
    await _playSong(widget.playlist[currentIndex].filePath);
  }

  void _toggleLoop() {
    isLooping = !isLooping;
    _audioPlayer.setReleaseMode(
      isLooping ? ReleaseMode.loop : ReleaseMode.release,
    );
    setState(() {});
  }

  void _toggleShuffle() {
    isShuffling = !isShuffling;
    if (isShuffling) {
      _generateShuffledPlaylist();
    } else {
      shuffledIndices.clear();
    }
    setState(() {});
  }

  void _generateShuffledPlaylist() {
    shuffledIndices = List.generate(widget.playlist.length, (i) => i)
      ..shuffle(Random());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[currentIndex];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(currentSong.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAlbumArt(),
                    SizedBox(height: 20),
                    Text(
                      currentSong.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentSong.artist,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final newPosition = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(newPosition);
                        await _audioPlayer.resume();
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(position),
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatTime(duration),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isShuffling ? Icons.shuffle_on : Icons.shuffle,
                            color: isShuffling ? Colors.blue : Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleShuffle,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: _playPrevious,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 40,
                            ),
                            onPressed: _playPause,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: _playNext,
                        ),
                        IconButton(
                          icon: Icon(
                            isLooping ? Icons.repeat_on : Icons.repeat,
                            color: isLooping ? Colors.blue : Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleLoop,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
            if (isAdLoaded.value) AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return CircleAvatar(
      radius: 100,
      backgroundColor: Colors.white24, // Background for the icon
      backgroundImage: AssetImage('assets/album_placeholder.png'),
      onBackgroundImageError: (_, __) {
        setState(() {}); // This forces the fallback to the icon
      },
      child: Image.asset(
        'assets/album_placeholder.png',
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                Icon(Icons.music_note, size: 80, color: Colors.white70),
      ),
    );
  }
}
