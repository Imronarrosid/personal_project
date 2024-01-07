import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
    on<CancelCameraRecordingEvent>((event, emit) {
      emit(CameraRecordingCanceled());
    });

    bool isRecordingPaused = false;
    on<PauseCameraRecordingEvent>((event, emit) {

      isRecordingPaused
          ? emit(CameraRecording())
          : emit(CameraRecordingPaused());
      isRecordingPaused = !isRecordingPaused;
    });

    on<OpenCameraEvent>((event, emit) {
      emit(CameraInitial());
      emit(FrontCameraInitialized());
    });
  }
}
