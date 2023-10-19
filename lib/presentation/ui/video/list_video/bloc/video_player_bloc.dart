import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc(this.repository) : super(VideoPlayerInitial()) {
    on<InitVideoPlayer>((event, emit) async {
      debugPrint('init video playre${event.controller.value.isInitialized}');
      await event.controller.initialize().then((value) async {
        User ownerData = await repository.getVideoOwnerData(event.ownerUid);
        if (event.controller.value.isInitialized) {
          emit(VideoPlayerIntialized(ownerData: ownerData));
          event.controller.play();
        }
      });
    });
    on<StopVideoPriviewEvent>((event, emit) {
      emit(VideoPreviewInitial());
    });
  }
  final VideoRepository repository;
}
