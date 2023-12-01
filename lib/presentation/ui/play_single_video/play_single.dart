import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';

class PlaySingleVideoPage extends StatelessWidget {
  final Video videoData;
  const PlaySingleVideoPage({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: VideoPlayerItem(url: videoData.videoUrl, item: videoData));
  }
}
