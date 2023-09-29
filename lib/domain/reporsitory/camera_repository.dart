import 'package:camera/camera.dart';

class CameraRepository {
  final List<CameraDescription> cameras;
  CameraRepository({required this.cameras});

  CameraController rearCamera() {
    return CameraController(cameras[0], ResolutionPreset.veryHigh);
  }
  CameraController openFrontCamera() {
    return CameraController(cameras[1], ResolutionPreset.veryHigh);
  }
}
