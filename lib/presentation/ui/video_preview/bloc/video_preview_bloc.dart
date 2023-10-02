import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

part 'video_preview_event.dart';
part 'video_preview_state.dart';

class VideoPreviewBloc extends Bloc<VideoPreviewEvent, VideoPreviewState> {
  VideoPreviewBloc() : super(VideoPreviewInitial()) {
    on<InitVideoPlayer>((event, emit) {
      debugPrint('init video playre${event.controller.value.isInitialized}');
      emit(VideoPlayerIntialized());
      event.controller.play();
    });
    on<StopVideoPriviewEvent>((event, emit) {
      emit(VideoPreviewInitial());
    });
  }
}
