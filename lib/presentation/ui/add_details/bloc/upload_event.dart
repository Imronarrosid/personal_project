part of 'upload_bloc.dart';

sealed class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadVideoEvent extends UploadEvent {
  final String videoPath, caption, thumbnail;
  final String? category;
  final GameFav? game;

  const UploadVideoEvent({
    required this.videoPath,
    required this.thumbnail,
    required this.caption,
    this.category,
    this.game,
  });

  @override
  List<Object?> get props => [
        videoPath,
        caption,
        thumbnail,
        game,
        category,
      ];
}

class DeleteVideo extends UploadEvent {
  final int pagingIndex;

  const DeleteVideo({required this.pagingIndex});

  @override
  List<Object?> get props => [super.props, pagingIndex];
}
