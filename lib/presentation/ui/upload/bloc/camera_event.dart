part of 'camera_bloc.dart';

sealed class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

class OpenRearCameraEvent extends CameraEvent {
  final bool isCameraInitialized;
  const OpenRearCameraEvent({this.isCameraInitialized = false});

  @override
  List<Object> get props => [isCameraInitialized];
}

class ChangeCameraEvent extends CameraEvent {
  @override
  List<Object> get props => [];
}

class FlashEvent extends CameraEvent {
  @override
  List<Object> get props => [];
}
class CameraRecordingEvent extends CameraEvent {
  @override
  List<Object> get props => [];
}
class StopCameraRecordingEvent extends CameraEvent {
  @override
  List<Object> get props => [];
}

class OpenCameraEvent extends CameraEvent {
  @override
  List<Object> get props => [];
}

class CloseCamera extends CameraEvent {
  @override
  List<Object> get props => [];
}
