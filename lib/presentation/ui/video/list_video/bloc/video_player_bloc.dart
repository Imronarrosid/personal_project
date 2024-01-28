import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:video_cached_player/video_cached_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc({
    required this.videoPlayerRepository,
    required this.videoRepository,
  }) : super(const VideoPlayerInitial()) {
    CachedVideoPlayerController? controller;
    on<VideoPlayerEvent>((event, emit) async {
      debugPrint('init v player event');
      if (event.actions == VideoEvent.initialize) {
        await _initVideoPlayer(controller, event, emit);
      } else if (event.actions == VideoEvent.play) {
        _playVideo(videoPlayerRepository.controller, emit);
      } else if (event.actions == VideoEvent.pause) {
        _pauseVideo(videoPlayerRepository.controller, emit);
      } else if (event.actions == VideoEvent.delete) {
        await videoRepository.deleteVideo(event.postId!, event.videoUrl!, event.thumnailUrl!);
        emit(const VideoPlayerState(status: VideoPlayerStatus.videoDeleted));
      } else if (event.actions == VideoEvent.showBufferingIndicator) {
        emit(
          const VideoPlayerState(
            status: VideoPlayerStatus.buffering,
          ),
        );
      } else if (event.actions == VideoEvent.removeBufferingIndicator) {
        emit(
          const VideoPlayerState(
            status: VideoPlayerStatus.playing,
          ),
        );
      } else if (event.actions == VideoEvent.dispose) {
        if (videoPlayerRepository.controller != null) {
          videoPlayerRepository.controller!.dispose();
        }
        videoPlayerRepository.setController = null;
        emit(const VideoPlayerState(status: VideoPlayerStatus.disposed));
      }
    });
  }

  void _playVideo(CachedVideoPlayerController? controller, Emitter<VideoPlayerState> emit) {
    controller!.play();
    emit(const VideoPlayerState(status: VideoPlayerStatus.playing));
  }

  void _pauseVideo(CachedVideoPlayerController? controller, Emitter<VideoPlayerState> emit) {
    controller!.pause();
    // emit(VideoPaused(opacity: 1, size: Dimens.DIMENS_50));
    emit(const VideoPlayerState(status: VideoPlayerStatus.paused));
  }

  Future<void> _initVideoPlayer(CachedVideoPlayerController? controller, VideoPlayerEvent event,
      Emitter<VideoPlayerState> emit) async {
    try {
      emit(const VideoPlayerInitial());
      controller = await videoPlayerRepository.initVideoPlayer(event.videoUrl!);
      emit(VideoPlayerState(controller: controller, status: VideoPlayerStatus.initialized));
      videoPlayerRepository.controller!.setLooping(true);
      videoPlayerRepository.controller!.play();

      // }
    } catch (e) {
      emit(VideoPlayerState(status: VideoPlayerStatus.error, error: e.toString()));
      debugPrint(e.toString());
    }
  }

  final VideoRepository videoRepository;
  final VideoPlayerRepository videoPlayerRepository;

  @override
  Future<void> close() {
    if (videoPlayerRepository.controller != null) {
      videoPlayerRepository.controller?.dispose();
      debugPrint('dispose video player bloc');
    }
    return super.close();
  }
}
