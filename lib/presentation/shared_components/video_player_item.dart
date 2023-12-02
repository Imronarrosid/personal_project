import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/video_player_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';

class VideoPlayerItem extends StatelessWidget {
  final String url;
  final Video item;
  final bool auto;
  const VideoPlayerItem({
    super.key,
    required this.url,
    required this.item,
    this.auto = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => VideoPlayerRepository(),
      child: BlocProvider(
        create: (context) => VideoPlayerBloc(
            videoPlayerRepository:
                RepositoryProvider.of<VideoPlayerRepository>(context),
            videoRepository: RepositoryProvider.of<VideoRepository>(context))
          ..add(
            InitVideoPlayerEvent(url: item.videoUrl),
          ),
        child: VideoItem(
          videoData: item,
          auto: auto,
        ),
      ),
    );
  }
}
