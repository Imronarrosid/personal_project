import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/reporsitory/camera_repository.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<OpenRearCameraEvent>((event, emit) async {
      if (event.isCameraInitialized) {
        emit(RearCameraInitialized());
      }
    });
    on<CloseCamera>((event, emit) {
      emit(CameraInitial());
    });
    on<OpenFrontCameraEvent>((event, emit) {
      emit(CameraInitial());
      emit(FrontCameraInitialized());
    });
  }
}
