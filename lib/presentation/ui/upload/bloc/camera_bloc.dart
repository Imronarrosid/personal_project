import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/reporsitory/camera_repository.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    // bool _isRearCameraSelected = true;
    on<OpenRearCameraEvent>((event, emit) async {
      if (event.isCameraInitialized) {
        emit(CameraInitialized());
        // _isRearCameraSelected = !_isRearCameraSelected;
        // if (_isRearCameraSelected) {
        //   emit(RearCameraSelected());
        // } else {
        //   emit(FrontCameraSelected());
        // }
      }
    });

    on<CloseCamera>((event, emit) {
      emit(CameraInitial());
    });
    on<FlashEvent>((event, emit) {
      emit(FlashInitialized());
      emit(CameraInitialized());
    });
    on<CameraRecordingEvent>((event, emit) {
      emit(CameraInitialized());
      emit(CameraRecording());
    });
    on<StopCameraRecordingEvent>((event, emit) {
      emit(CameraRecordingStoped());
    });

    on<OpenCameraEvent>((event, emit) {
      emit(CameraInitial());
      emit(FrontCameraInitialized());
    });
  }
}
