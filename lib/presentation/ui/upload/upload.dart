import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/ui/upload/bloc/camera_bloc.dart';

class UploadPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const UploadPage({super.key, required this.cameras});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  double _previousScale = 1.0;
  double _zoomLevel = 1.0;
  bool isCameraInitialized = false;

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PreviewPage(
      //               picture: picture,
      //             )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera(context, widget.cameras![0]);
    debugPrint(widget.cameras.toString());
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future initCamera(
      BuildContext context, CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        if (_cameraController.value.isInitialized == true) {
          BlocProvider.of<CameraBloc>(context).add(OpenRearCameraEvent(
              isCameraInitialized: _cameraController.value.isInitialized));
        }
        debugPrint('init ${_cameraController.value.isInitialized}');
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) async {
    double newScale = details.scale;

    // Calculate the scale factor change.
    double scaleChange = newScale - _previousScale;

    // Determine if it's a pinch-in or pinch-out.

    if (scaleChange > 0) {
      // Pinch-out (zoom in) detected.
      // You can add your zoom-in logic here.
      // do something after 5 seconds
      _zoomLevel += 0.03;
      if (_zoomLevel > 10.0) {
        _zoomLevel = 10.0;
      }
      //Update zoom
      _cameraController.setZoomLevel(_zoomLevel);
    } else if (scaleChange < 0) {
      // Pinch-in (zoom out) detected.
      // You can add your zoom-out logic here.
      _zoomLevel -= 0.03;
      if (_zoomLevel < 1.0) {
        _zoomLevel = 1.0;
      }
      _cameraController.setZoomLevel(_zoomLevel);
    }

    debugPrint(_zoomLevel.toString());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<CameraBloc>(context).add(CloseCamera());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Post')),
        backgroundColor: COLOR_black_ff121212,
        body: SafeArea(
            child: Stack(
          children: [
            BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                debugPrint('state $state');
                debugPrint(_cameraController.value.isInitialized.toString());
                if (state is RearCameraInitialized) {
                  return GestureDetector(
                      onScaleUpdate: _onScaleUpdate,
                      child: CameraPreview(_cameraController));
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            IconButton(
                onPressed: () {
                  BlocProvider.of<CameraBloc>(context).add(CloseCamera());
                  context.pop();
                },
                icon: const Icon(Icons.close))
          ],
        )),
      ),
    );
  }
}
