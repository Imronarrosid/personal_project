import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/timer_widget.dart';
import 'package:personal_project/presentation/ui/upload/bloc/camera_bloc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class UploadPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const UploadPage({super.key, required this.cameras});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late AnimationController _animationController;

  bool _isRearCameraSelected = true;
  final double _previousScale = 1.0;
  double _zoomLevel = 1.0;
  bool isCameraInitialized = false;
  bool isFlashoN = false;
  String firstVideoPath = '';
  List<String> listVideoPath = [];
  int duration = 60;

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

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    );

    // _animationController.addListener(() {
    //   if (_animationController.value >= 0.0) {
    //     debugPrint('end time');
    //     _cameraController.stopVideoRecording().then((value) {
    //       context.push(APP_PAGE.videoPreview.toPath,extra: File(value.path));
    //     });
    //   }
    //   debugPrint(_animationController.value.toString());
    //  });
    _animationController.addListener(() async {
      if (_animationController.value == 0.0 &&
          _cameraController.value.isRecordingVideo) {
        debugPrint('end time');
        try {
          // await _cameraController.stopVideoRecording().then((value) {
          //   GoRouter.of(context)
          //       .push(APP_PAGE.videoPreview.toPath, extra: File(value.path));
          //       BlocProvider.of<CameraBloc>(context).add(StopCameraRecordingEvent());
          // });
          _stopRecording();
        } on CameraException catch (e) {
          debugPrint(e.toString());
        }
      }
      debugPrint(_animationController.value.toString());
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _animationController.dispose();
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
      _zoomLevel += 0.03;
      if (_zoomLevel > 10.0 && _isRearCameraSelected) {
        _zoomLevel = 10.0;
      } else if (!_isRearCameraSelected) {
        _zoomLevel = 4.0;
      }
      _cameraController.setZoomLevel(_zoomLevel);
      //Update zoom
    } else if (scaleChange < 0) {
      // Pinch-in (zoom out) detected.
      // You can add your zoom-out logic here.
      _zoomLevel -= 0.03;
      if (_zoomLevel < 1.0) {
        _zoomLevel = 1.0;
      }
      _cameraController.setZoomLevel(_zoomLevel);
    }

    debugPrint('zoom$_zoomLevel');
  }

  _flashButton() {
    isFlashoN = !isFlashoN;
    _cameraController.setFlashMode(isFlashoN ? FlashMode.torch : FlashMode.off);
    BlocProvider.of<CameraBloc>(context).add(FlashEvent());
  }

  _changeCamera() {
    isFlashoN = false;
    BlocProvider.of<CameraBloc>(context).add(CloseCamera());
    initCamera(
        context,
        _cameraController.description == widget.cameras![0]
            ? widget.cameras![1]
            : widget.cameras![0]);
    _isRearCameraSelected = !_isRearCameraSelected;
  }

  Future<void> _stopRecording() async {
    _animationController.stop();
    try {
      await _cameraController.stopVideoRecording().then((value) async {
        debugPrint('path video${value.path}');

        _cameraController.dispose();
        //NAVIGATIONG TO VIDEO PREVIEW
        await context.push(APP_PAGE.videoPreview.toPath,
            extra: File(value.path));

        if (mounted && _isRearCameraSelected) {
          initCamera(context, widget.cameras![0]);
        } else if (mounted && !_isRearCameraSelected) {
          initCamera(context, widget.cameras![1]);
        }

        //STOP ANIMATION
        _animationController.reverse(from: 0.0);
        _animationController.stop();
      });
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }
  }

// Future<void> concatenateVideoClips(List<String> clipPaths, String outputPath) async {
//   final flutterFFmpeg = FlutterFFmpeg();

//   // Build a command to concatenate video clips
//   final arguments = [
//     '-i', 'concat:${clipPaths.join('|')}', // Concatenate input clips
//     '-c', 'copy', // Copy codec and format
//     outputPath, // Output path
//   ];

//   final result = await flutterFFmpeg.executeWithArguments(arguments);
//   if (result == 0) {
//     print('Video concatenation successful');
//   } else {
//     print('Video concatenation failed');
//   }
// }

  Future<String> mergeVideos(
      {required String firstPath,
      required String secondPath,
      required String outputPath}) async {
    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    // Build FFmpeg command to concatenate videos
    // String inputArgs = firstVideoPaths.map((path) => '-i $path').join(' ');
    // String filterComplex = 'concat=n=${firstVideoPaths.length}:v=1:a=1 [v] [a]';
    // String outputArgs =
    //     '-map [v] -map [a] -c:v libx264 -c:a aac -strict experimental -b:a 192k -shortest $outputFilePath';

    // String command = '$inputArgs -filter_complex $filterComplex $outputArgs';

    // int rc = await _flutterFFmpeg.execute(command).then((value) {
    //   if (value == 0) {
    //     listVideoPath.add(outputFilePath);
    //   }
    //   return value;
    // });

    // if (rc == 0) {
    //   print('Video merging successful');
    // } else {
    //   print('Video merging failed');
    // }
    String inputArgs = '-i $firstPath -i $secondPath';
    String outputArgs =
        '-filter_complex "concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" -c:a aac -strict experimental -b:a 192k $outputPath';

    String command = '$inputArgs $outputArgs';
    await _flutterFFmpeg.execute(command).then((value) {
      firstVideoPath = outputPath;
    });
    await Gal.putVideo(outputPath);

    return outputPath;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<CameraBloc>(context).add(CloseCamera());
        return true;
      },
      child: BlocListener<CameraBloc, CameraState>(
        listener: (context, state) async {
          try {
            if (state is CameraRecordingCanceled &&
                _cameraController.value.isRecordingVideo) {
              XFile? videoFile = await _cameraController.stopVideoRecording();
              File(videoFile.path).delete();

              _animationController.reverse(from: 0.0);
              _animationController.stop();
            }
          } on CameraException catch (e) {
            debugPrint(e.toString());
          }
        },
        child: Scaffold(
          backgroundColor: COLOR_black,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size(size.width, Dimens.DIMENS_105),
            child: BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                if (state is! CameraRecording) {
                  return AppBar(
                    centerTitle: true,
                    elevation: 0,
                    title: Text(LocaleKeys.title_upload.tr()),
                    backgroundColor: Colors.transparent,
                    toolbarHeight: Dimens.DIMENS_105,
                  );
                }
                return Container();
              },
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: Dimens.DIMENS_70),
                child: BlocBuilder<CameraBloc, CameraState>(
                  builder: (context, state) {
                    debugPrint('state $state');
                    debugPrint(
                        _cameraController.value.isInitialized.toString());
                    if (state is CameraInitialized ||
                        state is CameraRecording ||
                        state is CameraRecordingCanceled) {
                      return GestureDetector(
                          onScaleUpdate: _onScaleUpdate,
                          child: CameraPreview(_cameraController));
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              BlocBuilder<CameraBloc, CameraState>(
                builder: (context, state) {
                  if (state is! CameraRecording) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: Dimens.DIMENS_50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _changeCamera,
                              child: const Icon(Icons.loop),
                            ),
                            BlocBuilder<CameraBloc, CameraState>(
                              builder: (context, state) {
                                if (_isRearCameraSelected) {
                                  return Column(children: [
                                    GestureDetector(
                                      onTap: _flashButton,
                                      child: isFlashoN
                                          ? Icon(
                                              Icons.flash_on,
                                              size: Dimens.DIMENS_36,
                                              color: COLOR_white_fff5f5f5,
                                            )
                                          : Icon(
                                              Icons.flash_off,
                                              size: Dimens.DIMENS_36,
                                              color: COLOR_white_fff5f5f5,
                                            ),
                                    ),
                                    Text(
                                      LocaleKeys.label_flash.tr(),
                                      style: TextStyle(
                                          color: COLOR_white_fff5f5f5,
                                          fontSize: FontSize.FONT_SIZE_12),
                                    )
                                  ]);
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: Dimens.DIMENS_98),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: Dimens.DIMENS_98,
                        height: Dimens.DIMENS_50,
                        child: CountDownTimer(
                          controller: _animationController,
                        ),
                      ),
                      SizedBox(
                        width: size.width,
                        child: Row(
                          children: [
                            BlocBuilder<CameraBloc, CameraState>(
                              builder: (context, state) {
                                if (state is CameraRecording) {
                                  return CancelRecordButonWidget(
                                    size: size,
                                    cameraController: _cameraController,
                                    animationController: _animationController,
                                  );
                                }
                                //left white space for centering record button
                                return SizedBox(
                                  width: (size.width * 0.5) -
                                      (Dimens.DIMENS_70 * 0.5),
                                );
                              },
                            ),
                            BlocBuilder<CameraBloc, CameraState>(
                              builder: (context, state) {
                                if (state is CameraRecording) {
                                  debugPrint('camera recoding$state');
                                  return PauseAndResumeRecordButton(
                                      animationController: _animationController,
                                      cameraController: _cameraController);
                                }
                                return GestureDetector(
                                  onTap: () {
                                    _animationController.reverse(
                                        from: _animationController.value == 0.0
                                            ? 1.0
                                            : _animationController.value);
                                    BlocProvider.of<CameraBloc>(context)
                                        .add(CameraRecordingEvent());
                                    try {
                                      _cameraController.startVideoRecording();
                                    } on CameraException catch (e) {
                                      debugPrint(e.toString());
                                    }
                                  },
                                  child: Container(
                                    width: Dimens.DIMENS_70,
                                    height: Dimens.DIMENS_70,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            color: COLOR_white_fff5f5f5,
                                            width: 3.0)),
                                    padding: EdgeInsets.all(3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: COLOR_red,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              width: Dimens.DIMENS_50,
                            ),
                            BlocBuilder<CameraBloc, CameraState>(
                              builder: (context, state) {
                                if (state is CameraRecording) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await _stopRecording();
                                    },
                                    child: Container(
                                      width: Dimens.DIMENS_34,
                                      height: Dimens.DIMENS_34,
                                      decoration: BoxDecoration(
                                          color: COLOR_red,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: COLOR_white_fff5f5f5,
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: COLOR_red,
                                      borderRadius: BorderRadius.circular(
                                          Dimens.DIMENS_12)),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PauseAndResumeRecordButton extends StatelessWidget {
  const PauseAndResumeRecordButton({
    super.key,
    required AnimationController animationController,
    required CameraController cameraController,
  })  : _animationController = animationController,
        _cameraController = cameraController;

  final AnimationController _animationController;
  final CameraController _cameraController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_animationController.isAnimating) {
          _animationController.stop();
          await _cameraController.pauseVideoRecording();
        } else {
          await _cameraController.resumeVideoRecording();
          debugPrint('resume recording');

          _animationController.reverse(
              from: _animationController.value == 0.0
                  ? 1.0
                  : _animationController.value);
        }

        // if (_cameraController
        //     .value.isRecordingVideo) {
        //   await _cameraController
        //       .pauseVideoRecording();
        //   debugPrint('pause recording');
        //   debugPrint(_cameraController.value.toString());
        // } else if (!_cameraController.value.isRecordingVideo){
        //   debugPrint('resume recording');
        //   await _cameraController
        //       .resumeVideoRecording();
        // }
      },
      child: Stack(
        children: [
          SizedBox(
            width: Dimens.DIMENS_70,
            height: Dimens.DIMENS_70,
            child: Container(
              width: Dimens.DIMENS_70,
              height: Dimens.DIMENS_70,
              decoration: BoxDecoration(
                color: COLOR_white_fff5f5f5.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: Dimens.DIMENS_24,
                  height: Dimens.DIMENS_24,
                  decoration: BoxDecoration(
                      color: COLOR_red, borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: CustomTimerPainter(
                animation: _animationController,
                backgroundColor: Colors.white,
                color: COLOR_red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CancelRecordButonWidget extends StatelessWidget {
  const CancelRecordButonWidget({
    super.key,
    required this.size,
    required this.cameraController,
    required this.animationController,
  });

  final Size size;
  final CameraController cameraController;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: (size.width * 0.5) -
              (Dimens.DIMENS_70 * 0.5) -
              (Dimens.DIMENS_50 + Dimens.DIMENS_34),
        ),
        GestureDetector(
          onTap: () async {
            BlocProvider.of<CameraBloc>(context)
                .add(CancelCameraRecordingEvent());
          },
          child: Container(
            width: Dimens.DIMENS_34,
            height: Dimens.DIMENS_34,
            decoration: BoxDecoration(
                color: COLOR_black, borderRadius: BorderRadius.circular(50)),
            child: Icon(
              Icons.close_rounded,
              color: COLOR_white_fff5f5f5,
            ),
          ),
        ),
        SizedBox(
          width: Dimens.DIMENS_50,
        )
      ],
    );
  }
}
