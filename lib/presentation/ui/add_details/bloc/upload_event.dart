part of 'upload_bloc.dart';

sealed class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object> get props => [];
}

class UploadVideoEvent extends UploadEvent {
  final String videoPath, caption;

  const UploadVideoEvent({required this.videoPath, required this.caption});

  @override
  List<Object> get props => [videoPath, caption];
}