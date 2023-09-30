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

final class RearCameraInitialized extends CameraState {
  @override
  List<Object> get props => [];
}

final class FrontCameraInitialized extends CameraState {}

final class CameraError extends CameraState{
  final String error;
  const CameraError(this.error);

  @override
  List<Object> get props => [];
}
