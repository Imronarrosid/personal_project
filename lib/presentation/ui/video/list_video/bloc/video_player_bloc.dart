import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc(
      {required this.repository, required this.videoPlayerController})
      : super(videoPlayerController.value.isInitialized
            ? VideoPlayerIntialized(ownerData: repository.videoOwnerData)
            : VideoPlayerInitial()) {
    on<InitVideoPlayer>((event, emit) async {
      debugPrint('InitVideoPlayer');
      User ownerData = await repository.getVideoOwnerData(event.ownerUid);
      try {
        debugPrint('init video playre ${event.controller.value.isInitialized}');
        await event.controller.initialize().then((value) async {
          await repository.getVideoOwnerData(event.ownerUid);
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
  }
  final VideoRepository repository;
  final VideoPlayerController videoPlayerController;
}
