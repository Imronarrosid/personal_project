import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:video_cached_player/video_cached_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc({
    required this.videoPlayerRepository,
    required this.videoRepository,
  }) : super(VideoPlayerInitial()) {
    on<InitVideoPlayerEvent>((event, emit) async {
      debugPrint('init v player event');
      CachedVideoPlayerController? controller;
      try {
        if (videoPlayerRepository.controller == null) {
          controller = await videoPlayerRepository.initVideoPlayer(event.url);
          if (controller!.value.isInitialized) {
            emit(VideoPlayerIntialized(videoPlayerController: controller));
          }
        }
      } catch (e) {
        emit(VideoPlayerError(error: e.toString()));
        debugPrint(e.toString());
      }
    });
  }
  final VideoRepository videoRepository;
  final VideoPlayerRepository videoPlayerRepository;
}
