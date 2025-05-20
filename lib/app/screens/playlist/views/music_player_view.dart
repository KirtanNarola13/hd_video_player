import 'package:flutter/material.dart';

class MusicPlayerView extends StatelessWidget {
  final String songPath;

  MusicPlayerView({required this.songPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Now Playing")),
      body: Center(child: Text("Playing: $songPath")),
    );
  }
}
