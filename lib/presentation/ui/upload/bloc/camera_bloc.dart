import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/reporsitory/camera_repository.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc({required CameraRepository cameraRepository})
      : _cameraRepository = cameraRepository,
        super(CameraInitial()) {
    on<OpenRearCameraEvent>((event, emit) async {
      // TODO: implement event handler
      emit(CameraInitial());
      await _cameraRepository.rearCamera().initialize();
      if (_cameraRepository.rearCamera().value.isInitialized) {
        emit(RearCameraInitialized(
            cameraController: _cameraRepository.rearCamera()));
      }
        debugPrint('OpenRearCameraEvent()');
    });
    on<OpenFrontCameraEvent>((event, emit) {
      emit(CameraInitial());
      emit(FrontCameraInitialized(
          cameraController: _cameraRepository.openFrontCamera()));
    });
  }
  final CameraRepository _cameraRepository;

  
}
