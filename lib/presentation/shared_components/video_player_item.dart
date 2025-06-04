import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/video_player_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';
import 'package:personal_project/presentation/ui/video/video_item/responsive/video_item_desktop.dart';
import 'package:personal_project/presentation/ui/video/video_item/responsive/video_item_mobile.dart';

class VideoPlayerItem extends StatelessWidget {
  final int index;
  final String url;
  final Video item;

  /// if value is true video will auto
  ///
  /// play and pause
  final bool auto;
  final bool? isForLogedUserVideo;
  final CachedVideoPlayerPlusController controller;
  const VideoPlayerItem({
    super.key,
    required this.index,
    required this.url,
    required this.item,
    this.auto = false,
    this.isForLogedUserVideo = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => VideoPlayerRepository(),
      child: BlocProvider(
        create: (context) => VideoPlayerBloc(
            controller: controller,
            videoPlayerRepository: RepositoryProvider.of<VideoPlayerRepository>(context),
            videoRepository: RepositoryProvider.of<VideoRepository>(context))
          ..add(
            VideoPlayerEvent(actions: VideoEvent.initialize, videoUrl: item.videoUrl),
          ),
        child: ResponsiveLayout(
          mobileBody: VideoItemMobile(
            controller: controller,
            index: index,
            videoData: item,
            auto: auto,
            isForLogedUserVideo: isForLogedUserVideo,
          ),
          desktopBody: VideoItemDesktop(
            index: index,
            videoData: item,
            auto: auto,
            isForLogedUserVideo: isForLogedUserVideo,
          ),
        ),
      ),
    );
  }
}
