part of 'camera_bloc.dart';

sealed class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}
class OpenRearCameraEvent extends CameraEvent{
  
}
class OpenFrontCameraEvent extends CameraEvent{

}
