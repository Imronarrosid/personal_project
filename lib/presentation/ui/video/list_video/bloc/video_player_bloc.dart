import 'package:bloc/bloc.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

import '../../../../../utils/debug_mode_print.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc({
    required this.videoPlayerRepository,
    required this.videoRepository,
  }) : super(const VideoPlayerInitial()) {
    CachedVideoPlayerPlusController? controller;
    on<VideoPlayerEvent>((event, emit) async {
      debugModePrint('init v player event');
      if (event.actions == VideoEvent.initialize) {
        await _initVideoPlayer(controller, event, emit);
      } else if (event.actions == VideoEvent.play) {
        _playVideo(videoPlayerRepository.controller, emit);
      } else if (event.actions == VideoEvent.pause) {
        _pauseVideo(videoPlayerRepository.controller, emit);
      } else if (event.actions == VideoEvent.delete) {
        await videoRepository.deleteVideo(
            event.postId!, event.videoUrl!, event.thumnailUrl!);
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

  void _playVideo(CachedVideoPlayerPlusController? controller,
      Emitter<VideoPlayerState> emit) {
    controller!.play();
    emit(const VideoPlayerState(status: VideoPlayerStatus.playing));
  }

  void _pauseVideo(CachedVideoPlayerPlusController? controller,
      Emitter<VideoPlayerState> emit) {
    controller!.pause();
    // emit(VideoPaused(opacity: 1, size: Dimens.DIMENS_50));
    emit(const VideoPlayerState(status: VideoPlayerStatus.paused));
  }

  Future<void> _initVideoPlayer(CachedVideoPlayerPlusController? controller,
      VideoPlayerEvent event, Emitter<VideoPlayerState> emit) async {
    try {
      emit(const VideoPlayerInitial());
      controller = await videoPlayerRepository.initVideoPlayer(event.videoUrl!);
      emit(VideoPlayerState(
          controller: controller, status: VideoPlayerStatus.initialized));
      videoPlayerRepository.controller!.setLooping(true);

      var cachedVideoPlayerPlusController = videoPlayerRepository.controller!;
      if (cachedVideoPlayerPlusController.value.isInitialized &&
          !cachedVideoPlayerPlusController.value.isPlaying) {
        videoPlayerRepository.controller!.play();
      }

      // }
    } catch (e) {
      emit(VideoPlayerState(
          status: VideoPlayerStatus.error, error: e.toString()));
      debugModePrint(e.toString());
    }
  }

  final VideoRepository videoRepository;
  final VideoPlayerRepository videoPlayerRepository;

  @override
  Future<void> close() {
    if (videoPlayerRepository.controller != null) {
      videoPlayerRepository.controller?.dispose();
      debugModePrint('dispose video player bloc');
    }
    return super.close();
  }
}
