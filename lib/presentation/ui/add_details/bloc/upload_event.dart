part of 'upload_bloc.dart';

sealed class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadVideoEvent extends UploadEvent {
  final String videoPath, caption, thumbnail;
  final GameFav? game;

  const UploadVideoEvent(
      {required this.videoPath,
      required this.thumbnail,
      required this.caption,
      this.game});

  @override
  List<Object?> get props => [videoPath, caption, thumbnail, game];
}
