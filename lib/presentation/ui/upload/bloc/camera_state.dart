part of 'camera_bloc.dart';


sealed class CameraState extends Equatable {
  const CameraState();
  
  @override
  List<Object> get props => [];
}

final class CameraInitial extends CameraState {}
final class RearCameraInitialized extends CameraState{
  final CameraController cameraController;
  const RearCameraInitialized({required this.cameraController});
  @override
  // TODO: implement props
  List<Object> get props => [cameraController];
}
final class FrontCameraInitialized extends CameraState{
  final CameraController cameraController;
  const FrontCameraInitialized({required this.cameraController});
}
final class CameraError{
  final String error;
  CameraError(this.error);
}
