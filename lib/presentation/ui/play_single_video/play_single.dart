import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';

class PlaySingleVideoPage extends StatelessWidget {
  final PlaySingleData data;
  const PlaySingleVideoPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: VideoPlayerItem(
          index: data.index,
          url: data.videoData.uid,
          item: data.videoData,
          isForLogedUserVideo: data.isForLogedUserVideo,
        ));
  }
}
