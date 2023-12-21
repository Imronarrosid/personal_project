part of 'upload_bloc.dart';

sealed class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object> get props => [];
}

class UploadVideoEvent extends UploadEvent {
  final String videoPath, caption, thumbnail, game;

  const UploadVideoEvent(
      {required this.videoPath,
      required this.thumbnail,
      required this.caption,
      required this.game});

  @override
  List<Object> get props => [videoPath, caption, thumbnail, game];
}
