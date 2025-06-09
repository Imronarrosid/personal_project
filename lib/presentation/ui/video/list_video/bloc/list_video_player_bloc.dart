import 'package:bloc/bloc.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

part 'list_video_player_event.dart';
part 'list_video_player_state.dart';

class ListVideoPlayerBloc extends Bloc<ListVideoPlayerEvent, ListVideoPlayerState> {
  ListVideoPlayerBloc(
    this.repository,
  ) : super(VideoState(
          status: VideoStatus.initialized,
          likeStatus: LikeStatus.initial,
          index: 0,
        )) {
    on<InitVideoPlayer>((event, emit) async {
      final CachedVideoPlayerPlusController controller = event.controller;
      if (controller.value.isInitialized) {
        controller.setLooping(true);
        controller.play();
        emit(VideoState(index: event.index, status: VideoStatus.initialized, likeStatus: LikeStatus.initial));
      } else {
        emit(VideoState(index: event.index, status: VideoStatus.loading, likeStatus: LikeStatus.initial));
        await controller.initialize();
        controller.setLooping(true);
        controller.play();
        emit(VideoState(index: event.index, status: VideoStatus.initialized, likeStatus: LikeStatus.initial));
        emit(VideoState(index: event.index, status: VideoStatus.playing));
      }
    });
    on<PlayVideo>(
      (event, emit) {
        final CachedVideoPlayerPlusController controller = event.controller;

        controller.play();
        emit(VideoState(index: event.index, status: VideoStatus.playing));

        debugModePrint('lvp state $state');
      },
    );
    on<PauseVideo>(
      (event, emit) {
        final CachedVideoPlayerPlusController controller = event.controller;

        controller.pause();
        emit(VideoState(
          index: event.index,
          status: VideoStatus.paused,
          likeStatus: LikeStatus.initial,
        ));

        debugModePrint('lvp state $state');
      },
    );

    on<RemovePreviousePauseIcon>((event, emit) {
      if (event.controller.value.isInitialized) {
        emit(VideoState(index: event.index, status: VideoStatus.initialized, likeStatus: LikeStatus.initial));
      } else {
        emit(VideoState(index: event.index, status: VideoStatus.loading, likeStatus: LikeStatus.initial));
      }
    });

    on<LikeVideo>((event, emit) async {
      try {
        Video video = event.video.copyWith();

        repository.likeVideo(video.id!);

        if (video.isLiked) {
          emit(
            VideoState(index: event.index, status: VideoStatus.initialized, likeStatus: LikeStatus.unliked),
          );
        } else {
          emit(
            VideoState(
              index: event.index,
              status: VideoStatus.initialized,
              likeStatus: LikeStatus.liked,
            ),
          );
        }

        await repository.videoRepository.likeVideo(event.video.id!);
      } on Exception catch (e) {
        debugModePrint('likeVideo: $e');
        //undo likes on error
        repository.likeVideo(event.video.id!);
        emit(
          VideoState(
            index: event.index,
            status: VideoStatus.initialized,
            likeStatus: LikeStatus.error,
          ),
        );
      }
    });
    on<DoubleTapLikeVideo>((event, emit) async {
      try {
        Video video = event.video.copyWith();

        if (!video.isLiked) {
          repository.likeVideo(video.id!);
          emit(
            VideoState(
              index: event.index,
              status: VideoStatus.initialized,
              likeStatus: LikeStatus.doubleTapLike,
            ),
          );
          await repository.videoRepository.likeVideo(event.video.id!);
        }
        emit(
          VideoState(
            index: event.index,
            status: VideoStatus.initialized,
            likeStatus: LikeStatus.doubleTapLike,
          ),
        );
      } on Exception catch (e) {
        debugModePrint('likeVideo: $e');
        //undo likes on error
        repository.likeVideo(event.video.id!);
        emit(
          VideoState(
            index: event.index,
            status: VideoStatus.initialized,
            likeStatus: LikeStatus.error,
          ),
        );
      }
    });

    on<DisposeVideoController>(
      (event, emit) async {
        final String url = event.controller.dataSource;
        await event.controller.dispose();
        repository.replaceControllerAtIndex(event.index, repository.setUpVideoController(url));
      },
    );
  }
  final PagingRepository repository;
}
