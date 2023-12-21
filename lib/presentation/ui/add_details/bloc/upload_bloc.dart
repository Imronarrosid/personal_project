import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/utils/get_thumbnails.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc(this.videoRepository) : super(UploadInitial()) {
    on<UploadVideoEvent>((event, emit) async {
      emit(Uploading(
          File(
            event.thumbnail,
          ),
          event.caption));
      try {
        await videoRepository.uploapVideo(
            songName: 'tidak diketahui',
            caption: event.caption,
            videoPath: event.videoPath,
            game: event.game);
        emit(VideoUploaded());
        _removeFile(event.videoPath);
      } catch (e) {
        debugPrint('upload $e');
        emit(UploadError(e.toString()));
      }
    });
  }
  void _removeFile(String path) {
    File(path).deleteSync(recursive: true);
  }

  VideoRepository videoRepository;
}
