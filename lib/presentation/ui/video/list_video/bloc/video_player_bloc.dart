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
    on<InitVideoPlayer>((event, emit) async {
      debugPrint('InitVideoPlayer');
      User ownerData = await videoRepository.getVideoOwnerData(event.ownerUid);
      try {
        debugPrint('init video playre ${event.controller.value.isInitialized}');
        await event.controller.initialize().then((value) async {
          await videoRepository.getVideoOwnerData(event.ownerUid);
          if (event.controller.value.isInitialized) {
            emit(VideoPlayerIntialized(ownerData: ownerData));
            event.controller.play();
            debugPrint('Is initialized');
          }
        });
      } catch (e) {
        emit(VideoPlayerError());
        debugPrint(e.toString());
      }
    });
    on<StopVideoPriviewEvent>((event, emit) {
      emit(VideoPreviewInitial());
    });
    on<InitVideoPlayerEvent>((event, emit) async {
      CachedVideoPlayerController? controller;
      try {
        if (videoPlayerRepository.controller == null) {
          controller = await videoPlayerRepository.initVideoPlayer(event.url);
          if (controller!.value.isInitialized) {
            emit(VideoPlayerIntialized(videoPlayerController: controller));
            controller.play();
          }
        } else {
          if (controller!.value.isInitialized) {
            emit(VideoPlayerIntialized(videoPlayerController: controller));
            controller.play();
          }
        }
      } catch (e) {
        emit(VideoPlayerError());
        debugPrint(e.toString());
      }
    });
  }
  final VideoRepository videoRepository;
  final VideoPlayerRepository videoPlayerRepository;

 
}
