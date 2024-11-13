//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
import 'dart:async';
import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/domain/model/add_details_model.dart';
import 'package:personal_project/domain/services/firebase/image_picker.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/crop_page.dart';
// import 'package:video_editor/video_editor.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:video_editor_2/domain/entities/file_format.dart';
import 'package:video_editor_2/video_editor.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/debug_mode_print.dart';

class VideoEditorDesktop extends StatefulWidget {
  const VideoEditorDesktop({super.key, required this.file});

  final XFile? file;

  @override
  State<VideoEditorDesktop> createState() => _VideoEditorDesktopState();
}

class _VideoEditorDesktopState extends State<VideoEditorDesktop> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  XFile? videoFile;

  late final VideoEditorController _controller;
  // ignore: unused_field
  late DropzoneViewController _dropZoneController;

  DropStatus _dropStatus = DropStatus.created;

  @override
  void initState() {
    super.initState();
    videoFile = widget.file;
    if (videoFile != null) {
      _controller = VideoEditorController.file(
        widget.file!,
        minDuration: const Duration(seconds: 1),
        maxDuration: const Duration(minutes: 1),
      );
      _controller.initialize().then((_) => setState(() {})).catchError((error) {
        // handle minumum duration bigger than video duration error
        if (mounted) {
          context.pop();
        }
      }, test: (e) => e is VideoMinDurationError);
    }
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
  int _fileMBSize(Uint8List bytes) {
    return bytes.lengthInBytes ~/ (1024 * 1024);
  }

  Future<void> _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    _controller.video.pause();
    try {
      int fileSize = _fileMBSize(await _controller.file.readAsBytes());
      bool isMoreThan12MB = 12 < fileSize;
      bool under30secButMoreThan5MB =
          (_controller.video.value.duration.inSeconds < 30 && fileSize > 5);
      debugModePrint('video size $fileSize');
      final coverFile = await VideoThumbnail.thumbnailFile(
        imageFormat: ImageFormat.JPEG,
        thumbnailPath: kIsWeb ? null : (await getTemporaryDirectory()).path,
        video: _controller.file.path,
        timeMs: _controller.selectedCoverVal?.timeMs ??
            _controller.startTrim.inMilliseconds,
        quality: 6,
      );
      File file = File(coverFile.path);
      if (_controller.isTrimmed ||
          isMoreThan12MB ||
          under30secButMoreThan5MB ||
          _controller.isRotated ||
          _controller.video.value.size.width != _controller.croppedArea.width ||
          _controller.video.value.size.height !=
              _controller.croppedArea.height) {
        final video = await exportVideo(
          customInstruction:
              " -crf 28 -c:v libx264 -c:a aac -b:v 1250k -b:a 192k ",
          onStatistics: (stats) => _exportingProgress.value =
              stats.getProgress(_controller.trimmedDuration.inMilliseconds),
        );
        debugModePrint('video size ${_fileMBSize(await video.readAsBytes())}');
        if (mounted) {
          context.go(
            APP_PAGE.upload.toPath + APP_PAGE.addDetails.toPath,
            extra: AddDetails(videoFile: File(video.path), thumbnail: file),
          );
        }
      } else {
        if (!mounted) return;
        context.go(
          APP_PAGE.upload.toPath + APP_PAGE.addDetails.toPath,
          extra: AddDetails(
              videoFile: File(_controller.file.path), thumbnail: file),
        );
      }
      _isExporting.value = false;
    } catch (e) {
      debugModePrint('error ${e.toString()}');
      _showErrorSnackBar("Error on export video :(");
    }
  }

  // void _exportCover() async {
  //   final config = CoverFFmpegVideoEditorConfig(_controller);
  //   final execute = await config.getExecuteConfig();
  //   if (execute == null) {
  //     _showErrorSnackBar("Error on cover exportation initialization.");
  //     return;
  //   }

  //   await ExportService.runFFmpegCommand(
  //     execute,
  //     onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
  //     onCompleted: (cover) {
  //       if (!mounted) return;

  //       showDialog(
  //         context: context,
  //         builder: (_) => CoverResultPopup(cover: cover),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool canPop, _) async {
        _removeFile();
        _controller.video.pause();
      },
      child: videoFile == null
          ? _dropZone(context)
          : Scaffold(
              backgroundColor: COLOR_black_ff121212,
              body: _controller.initialized
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 8, bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.tertiary),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  _topNavBar(),
                                  Expanded(
                                    child: DefaultTabController(
                                      length: 1,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: TabBarView(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              children: [
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    VisibilityDetector(
                                                      key: UniqueKey(),
                                                      onVisibilityChanged:
                                                          (info) {
                                                        if (info.visibleFraction <
                                                            1) {
                                                          _controller.video
                                                              .pause();
                                                        } else {}
                                                      },
                                                      child: CropGridViewer
                                                          .preview(
                                                              controller:
                                                                  _controller),
                                                    ),
                                                    AnimatedBuilder(
                                                      animation:
                                                          _controller.video,
                                                      builder: (_, __) =>
                                                          AnimatedOpacity(
                                                        opacity: _controller
                                                                .isPlaying
                                                            ? 0
                                                            : 1,
                                                        duration:
                                                            kThemeAnimationDuration,
                                                        child: GestureDetector(
                                                          onTap: _controller
                                                              .video.play,
                                                          child: Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 210,
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: TabBarView(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: _trimSlider(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: IconButton(
                                                        color:
                                                            COLOR_white_fff5f5f5,
                                                        onPressed: () => _controller
                                                            .rotate90Degrees(
                                                                RotateDirection
                                                                    .left),
                                                        icon: const Icon(
                                                            BootstrapIcons
                                                                .arrow_counterclockwise),
                                                        tooltip: LocaleKeys
                                                            .label_rotate_counterclockwise
                                                            .tr(),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IconButton(
                                                        color:
                                                            COLOR_white_fff5f5f5,
                                                        onPressed: () => _controller
                                                            .rotate90Degrees(
                                                                RotateDirection
                                                                    .right),
                                                        icon: const Icon(
                                                            BootstrapIcons
                                                                .arrow_clockwise),
                                                        tooltip: LocaleKeys
                                                            .label_rotate_clockwise
                                                            .tr(),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IconButton(
                                                        color:
                                                            COLOR_white_fff5f5f5,
                                                        onPressed: () =>
                                                            Navigator.push(
                                                          context,
                                                          MaterialPageRoute<
                                                              void>(
                                                            builder: (context) =>
                                                                CropScreen(
                                                                    controller:
                                                                        _controller),
                                                          ),
                                                        ),
                                                        icon: const Icon(
                                                            BootstrapIcons
                                                                .crop),
                                                        tooltip:
                                                            'Open crop screen',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: Dimens.DIMENS_24,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              ValueListenableBuilder(
                                valueListenable: _isExporting,
                                builder: (_, bool export, Widget? child) =>
                                    AnimatedSize(
                                  duration: kThemeAnimationDuration,
                                  child: export ? child : null,
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  decoration: const BoxDecoration(
                                      color: Colors.black38),
                                  child: AlertDialog(
                                    title: ValueListenableBuilder(
                                      valueListenable: _exportingProgress,
                                      builder: (_, double value, __) => Row(
                                        children: [
                                          CircularProgressIndicator(
                                              value: value),
                                          SizedBox(
                                            width: Dimens.DIMENS_12,
                                          ),
                                          Text(
                                            "${LocaleKeys.message_wait.tr()} ${(value * 100).ceil()}%",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
    );
  }

  Widget _dropZone(BuildContext context) {
    if (kIsWeb) {
      return Container(
        padding: const EdgeInsets.only(
          left: 0,
          top: 8,
          right: 8,
          bottom: 8,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _dropStatus == DropStatus.hover
                    ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: DropzoneView(
                operation: DragOperation.all,
                onCreated: (DropzoneViewController ctrl) =>
                    _dropZoneController = ctrl,
                onLoaded: () => debugModePrint('Zone loaded'),
                onError: (String? ev) => debugModePrint('Error: $ev'),
                onHover: () {
                  debugModePrint('Zone hovered');
                  setState(() {
                    _dropStatus = DropStatus.hover;
                  });
                },
                onDrop: (ev) async {
                  XFile xFile =
                      XFile(html.Url.createObjectUrl(ev), mimeType: '.mp4');
                  debugModePrint(
                      'Drop: ${(ev as html.File).name} ${xFile.name}');
                  if (ev.name.contains('.mp4')) {
                    videoFile = xFile;
                    _controller = VideoEditorController.file(
                      xFile,
                      minDuration: const Duration(seconds: 1),
                      maxDuration: const Duration(minutes: 1),
                    );
                    _controller
                        .initialize()
                        .then((_) => setState(() {}))
                        .catchError((error) {
                      // handle minumum duration bigger than video duration error
                      if (context.mounted) {
                        context.pop();
                      }
                    }, test: (e) => e is VideoMinDurationError);
                  } else {
                    setState(() {
                      _dropStatus = DropStatus.error;
                    });
                    Fluttertoast.showToast(
                        msg: 'File not supported',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: COLOR_black_ff121212,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                onLeave: () => setState(() {
                  debugModePrint('Zone left');
                  _dropStatus = DropStatus.left;
                }),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(SolarIconsBold.videoFramePlayHorizontal,
                      size: 80,
                      color: _dropStatus == DropStatus.hover
                          ? Theme.of(context).colorScheme.primary
                          : null),
                  Text(
                    'Chose a video,or Drag it here.',
                    style: TextStyle(
                        fontSize: 20,
                        color: _dropStatus == DropStatus.hover
                            ? Theme.of(context).colorScheme.primary
                            : null),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_22,
                  ),
                  Material(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                          height: 32,
                          width: 240,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('Chose from computer')),
                      onTap: () async {
                        debugModePrint('chose video');
                        videoFile = await pickVideoFromGalery();
                        if (videoFile != null) {
                          _controller = VideoEditorController.file(
                            videoFile!,
                            minDuration: const Duration(seconds: 1),
                            maxDuration: const Duration(minutes: 1),
                          );
                          _controller
                              .initialize()
                              .then((_) => setState(() {}))
                              .catchError((error) {
                            // handle minumum duration bigger than video duration error
                            Navigator.pop(context);
                          }, test: (e) => e is VideoMinDurationError);
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            child: Container(
                height: 32,
                width: 240,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6)),
                child: Text('Chose from computer')),
            onTap: () async {
              debugModePrint('chose video');
              videoFile = await pickVideoFromGalery();
              if (videoFile != null) {
                _controller = VideoEditorController.file(
                  videoFile!,
                  minDuration: const Duration(seconds: 1),
                  maxDuration: const Duration(minutes: 1),
                );
                _controller
                    .initialize()
                    .then((_) => setState(() {}))
                    .catchError((error) {
                  // handle minumum duration bigger than video duration error
                  Navigator.pop(context);
                }, test: (e) => e is VideoMinDurationError);
              }
            },
          ),
        ),
      );
    }
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            SizedBox(
              width: Dimens.DIMENS_8,
            ),
            Material(
              color: COLOR_grey.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  context.pop();
                },
                child: Container(
                  height: Dimens.DIMENS_38,
                  width: Dimens.DIMENS_38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(right: 2, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    BootstrapIcons.arrow_left,
                    size: Dimens.DIMENS_20,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: InkWell(
                onTap: _exportVideo,
                splashColor: COLOR_black_ff121212.withOpacity(0.4),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                    width: Dimens.DIMENS_98,
                    height: Dimens.DIMENS_38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      LocaleKeys.label_next.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: FontSize.FONT_SIZE_12,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ),
            SizedBox(
              width: Dimens.DIMENS_8,
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(
                formatter(
                  Duration(
                    seconds: pos.toInt(),
                  ),
                ),
                style: TextStyle(color: COLOR_white_fff5f5f5),
              ),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    formatter(_controller.startTrim),
                    style: TextStyle(color: COLOR_white_fff5f5f5),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatter(_controller.endTrim),
                    style: TextStyle(color: COLOR_white_fff5f5f5),
                  ),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          quality: 0,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            quantity: 5,
            controller: _controller,
            localSeconds: LocaleKeys.label_sconds.tr(),
            textStyle: TextStyle(
                fontSize: FontSize.FONT_SIZE_8, color: COLOR_white_fff5f5f5),
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  void _removeFile() {
    File(widget.file!.path).deleteSync(recursive: true);
  }

  // Widget _coverSelection() {
  //   return SingleChildScrollView(
  //     child: Center(
  //       child: Container(
  //         margin: const EdgeInsets.all(15),
  //         child: CoverSelection(
  //           controller: _controller,
  //           size: height + 10,
  //           quantity: 8,
  //           selectedCoverBuilder: (cover, size) {
  //             return Stack(
  //               alignment: Alignment.center,
  //               children: [
  //                 cover,
  //                 Icon(
  //                   Icons.check_circle,
  //                   color: const CoverSelectionStyle().selectedBorderColor,
  //                 )
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<String> ioOutputPath(String filePath, FileFormat format) async {
    final tempPath = (await getTemporaryDirectory()).path;
    final name = path.basenameWithoutExtension(filePath);
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return "$tempPath/${name}_$epoch.${format.extension}";
  }

  String _webPath(String prePath, String format) {
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return '${prePath}_$epoch.$format';
  }

  String webInputPath(String format) => _webPath('input', format);

  String webOutputPath(String format) => _webPath('output', format);

  Future<XFile> exportVideo({
    void Function(FFmpegStatistics)? onStatistics,
    VideoExportFormat outputFormat = VideoExportFormat.mp4,
    double scale = 1.0,
    String customInstruction = '',
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) async {
    final inputPath = kIsWeb ? webInputPath('mp4') : _controller.file.path;
    final outputPath = kIsWeb
        ? webOutputPath('mp4')
        : await ioOutputPath(inputPath, outputFormat);

    String quotedInputPath = '"$inputPath"';
    String quotedOutputPath = '"$outputPath"';

    final config = _controller.createVideoFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: kIsWeb ? quotedInputPath.replaceAll('"', '') : quotedInputPath,
      outputPath:
          kIsWeb ? quotedOutputPath.replaceAll('"', '') : quotedOutputPath,
      outputFormat: outputFormat,
      scale: scale,
      customInstruction: customInstruction,
      preset: preset,
      isFiltersEnabled: isFiltersEnabled,
    );

    debugModePrint('run export video command : [$execute]');

    if (kIsWeb) {
      debugModePrint('f fweb');
      debugModePrint('f fweb ${inputPath}');

      return const FFmpegExport().executeFFmpegWeb(
        execute: execute,
        inputData: await _controller.file.readAsBytes(),
        inputPath: inputPath,
        outputPath: outputPath,
        outputMimeType: outputFormat.mimeType,
        onStatistics: onStatistics,
      );
    } else {
      debugModePrint('f fio');

      return const FFmpegExport().executeFFmpegIO(
        execute: execute,
        outputPath: outputPath,
        outputMimeType: outputFormat.mimeType,
        onStatistics: onStatistics,
      );
    }
  }

  Future<XFile> extractCover({
    void Function(FFmpegStatistics)? onStatistics,
    CoverExportFormat outputFormat = CoverExportFormat.jpg,
    double scale = 1.0,
    int quality = 100,
    bool isFiltersEnabled = true,
  }) async {
    // file generated from the thumbnail library or video source
    final coverFile = await VideoThumbnail.thumbnailFile(
      imageFormat: ImageFormat.JPEG,
      thumbnailPath: kIsWeb ? null : (await getTemporaryDirectory()).path,
      video: _controller.file.path,
      timeMs: _controller.selectedCoverVal?.timeMs ??
          _controller.startTrim.inMilliseconds,
      quality: quality,
    );

    final inputPath = kIsWeb ? webInputPath('jpg') : coverFile.path;
    final outputPath = kIsWeb
        ? webOutputPath('jpg')
        : await ioOutputPath(coverFile.path, outputFormat);

    var config = _controller.createCoverFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: inputPath,
      outputPath: outputPath,
      scale: scale,
      quality: quality,
      isFiltersEnabled: isFiltersEnabled,
    );

    debugModePrint('VideoEditor - run export cover command : [$execute]');

    if (kIsWeb) {
      debugModePrint('f fweb');
      return const FFmpegExport().executeFFmpegWeb(
        execute: execute,
        inputData: await coverFile.readAsBytes(),
        inputPath: inputPath,
        outputPath: outputPath,
        outputMimeType: outputFormat.mimeType,
      );
    } else {
      debugModePrint('ffwio');

      return const FFmpegExport().executeFFmpegIO(
        execute: execute,
        outputPath: outputPath,
        outputMimeType: outputFormat.mimeType,
      );
    }
  }

  Future<XFile> extractFirstFrame() async {
    String inputPath = webInputPath('jpg');
    String outputPath = webOutputPath('jpg');
    final execute = '-i $inputPath -vf select=eq(n,0) -vsync 0 $outputPath';

    return const FFmpegExport().executeFFmpegWeb(
        execute: execute,
        inputData: await _controller.file.readAsBytes(),
        inputPath: inputPath,
        outputPath: outputPath,
        outputMimeType: '.jpg');
  }
}

class FFmpegExport {
  const FFmpegExport();

  Future<XFile> executeFFmpegIO({
    required String execute,
    required String outputPath,
    String? outputMimeType,
    void Function(FFmpegStatistics)? onStatistics,
  }) {
    final completer = Completer<XFile>();

    FFmpegKit.executeAsync(
      execute,
      (session) async {
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          completer.complete(XFile(outputPath, mimeType: outputMimeType));
        } else {
          final state = FFmpegKitConfig.sessionStateToString(
            await session.getState(),
          );
          completer.completeError(
            Exception(
              'FFmpeg process exited with state $state and return code $code.'
              '${await session.getOutput()}',
            ),
          );
        }
      },
      null,
      onStatistics != null
          ? (s) => onStatistics(FFmpegStatistics.fromIOStatistics(s))
          : null,
    );

    return completer.future;
  }

  Future<XFile> executeFFmpegWeb({
    required String execute,
    required Uint8List inputData,
    required String inputPath,
    required String outputPath,
    String? outputMimeType,
    void Function(FFmpegStatistics)? onStatistics,
  }) async {
    debugModePrint('ffweb');
    FFmpeg? ffmpeg;
    final logs = <String>[];
    try {
      var corePath =
          'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js';
      ffmpeg = createFFmpeg(
        CreateFFmpegParam(
          log: true,
          corePath: corePath,
        ),
      );
      ffmpeg.setLogger((LoggerParam logger) {
        logs.add('[${logger.type}] ${logger.message}');

        if (onStatistics != null && logger.type == 'fferr') {
          final statistics = FFmpegStatistics.fromMessage(logger.message);
          if (statistics != null) {
            onStatistics(statistics);
          }
        }
      });

      await ffmpeg.load();

      ffmpeg.writeFile(inputPath, inputData);
      await ffmpeg.runCommand(execute);

      final data = ffmpeg.readFile(outputPath);
      debugModePrint('Xfile data$data');
      return XFile.fromData(data, mimeType: outputMimeType);
    } catch (e, s) {
      Error.throwWithStackTrace(
        Exception('Exception:\n$e\n\nLogs:${logs.join('\n')}}'),
        s,
      );
    } finally {
      ffmpeg?.exit();
    }
  }
}

/// Common class for ffmpeg_kit and ffmpeg_wasm statistics.
class FFmpegStatistics {
  final int videoFrameNumber;
  final double videoFps;
  final double videoQuality;
  final int size;
  final int time;
  final double bitrate;
  final double speed;

  static final statisticsRegex = RegExp(
    r'frame\s*=\s*(\d+)\s+fps\s*=\s*(\d+(?:\.\d+)?)\s+q\s*=\s*([\d.-]+)\s+L?size\s*=\s*(\d+)\w*\s+time\s*=\s*([\d:.]+)\s+bitrate\s*=\s*([\d.]+)\s*(\w+)/s\s+speed\s*=\s*([\d.]+)x',
  );

  const FFmpegStatistics({
    required this.videoFrameNumber,
    required this.videoFps,
    required this.videoQuality,
    required this.size,
    required this.time,
    required this.bitrate,
    required this.speed,
  });

  FFmpegStatistics.fromIOStatistics(Statistics s)
      : this(
          videoFrameNumber: s.getVideoFrameNumber(),
          videoFps: s.getVideoFps(),
          videoQuality: s.getVideoQuality(),
          size: s.getSize(),
          time: s.getTime().toInt(),
          bitrate: s.getBitrate(),
          speed: s.getSpeed(),
        );

  static FFmpegStatistics? fromMessage(String message) {
    final match = statisticsRegex.firstMatch(message);
    if (match != null) {
      return FFmpegStatistics(
        videoFrameNumber: int.parse(match.group(1)!),
        videoFps: double.parse(match.group(2)!),
        videoQuality: double.parse(match.group(3)!),
        size: int.parse(match.group(4)!),
        time: _timeToMs(match.group(5)!),
        bitrate: double.parse(match.group(6)!),
        // final bitrateUnit = match.group(7);
        speed: double.parse(match.group(8)!),
      );
    }

    return null;
  }

  double getProgress(int videoDurationMs) {
    return videoDurationMs <= 0.0
        ? 0.0
        : (time / videoDurationMs).clamp(0.0, 1.0);
  }

  static int _timeToMs(String timeString) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final secondsParts = parts[2].split('.');
    final seconds = int.parse(secondsParts[0]);
    final milliseconds = int.parse(secondsParts[1]);
    return ((hours * 60 * 60 + minutes * 60 + seconds) * 1000 + milliseconds);
  }
}

enum DropStatus {
  created,
  load,
  hover,
  left,
  drop,
  error,
}
