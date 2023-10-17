part of 'camera_bloc.dart';

sealed class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object> get props => [];
}

final class CameraInitial extends CameraState {
  @override
  List<Object> get props => [];
}

final class CameraInitialized extends CameraState {
  @override
  List<Object> get props => [];
}

final class RearCameraSelected extends CameraState {
  @override
  List<Object> get props => [];
}

final class FrontCameraSelected extends CameraState {
  @override
  List<Object> get props => [];
}

final class FrontCameraInitialized extends CameraState {}

final class FlashInitialized extends CameraState {
  @override
  List<Object> get props => [];
}

final class FlashOff extends CameraState {
  @override
  List<Object> get props => [];
}

final class CameraRecording extends CameraState {
  @override
  List<Object> get props => [];
}
final class CameraRecordingCanceled extends CameraState {
  @override
  List<Object> get props => [];
}
final class CameraRecordingStoped extends CameraState {
  @override
  List<Object> get props => [];
}
final class CameraRecordingPaused extends CameraState {
  @override
  List<Object> get props => [];
}

final class CameraError extends CameraState {
  final String error;
  const CameraError(this.error);

  @override
  List<Object> get props => [];
}
