part of 'upload_bloc.dart';

sealed class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object> get props => [];
}

final class UploadInitial extends UploadState {}

final class Uploading extends UploadState {}

final class VideoUploaded extends UploadState {}
