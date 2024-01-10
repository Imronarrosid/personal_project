part of 'upload_bloc.dart';

sealed class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object> get props => [];
}

final class UploadInitial extends UploadState {}

final class Uploading extends UploadState {
  final File thumbnail;
  final String caption;

  const Uploading(this.thumbnail, this.caption);
  @override
  List<Object> get props => [thumbnail, caption];
}

final class VideoUploaded extends UploadState {}

final class VideoDeleted extends UploadState {
  final int pagedIndex;

  const VideoDeleted({required this.pagedIndex});

  @override
  List<Object> get props => [
        super.props,
        pagedIndex,
      ];
}

final class UploadError extends UploadState {
  final String error;

  const UploadError(this.error);

  @override
  List<Object> get props => [error];
}
