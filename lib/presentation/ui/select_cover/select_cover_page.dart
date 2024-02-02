//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
import 'dart:async';
import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/presentation/ui/select_cover/cubit/select_cover_cubit.dart';
import 'package:video_editor_2/domain/entities/file_format.dart';
import 'package:video_editor_2/video_editor.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class SelectCover extends StatefulWidget {
  const SelectCover({super.key, required this.file});

  final XFile file;

  @override
  State<SelectCover> createState() => _SelectCoverState();
}

class _SelectCoverState extends State<SelectCover> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(minutes: 1),
  );

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) => setState(() {})).catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _removeFile();
        return false;
      },
      child: Scaffold(
        backgroundColor: COLOR_black_ff121212,
        body: _controller.initialized
            ? SafeArea(
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
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(controller: _controller),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, __) => AnimatedOpacity(
                                              opacity: _controller.isPlaying ? 0 : 1,
                                              duration: kThemeAnimationDuration,
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
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
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: TabBarView(
                                          physics: const NeverScrollableScrollPhysics(),
                                          children: [
                                            // Column(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.center,
                                            //   children: _trimSlider(),
                                            // ),
                                            _coverSelection(),
                                          ],
                                        ),
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
                      builder: (_, bool export, Widget? child) => AnimatedSize(
                        duration: kThemeAnimationDuration,
                        child: export ? child : null,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: const BoxDecoration(color: Colors.black38),
                        child: AlertDialog(
                          title: ValueListenableBuilder(
                            valueListenable: _exportingProgress,
                            builder: (_, double value, __) => Row(
                              children: [
                                CircularProgressIndicator(value: value),
                                SizedBox(
                                  width: Dimens.DIMENS_12,
                                ),
                                Text(
                                  "${LocaleKeys.message_wait.tr()} ${(value * 100).ceil()}%",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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
                      color: Colors.transparent, borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    BootstrapIcons.arrow_left,
                    size: Dimens.DIMENS_20,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              child: InkWell(
                onTap: _exportCover,
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
                      LocaleKeys.label_save.tr(),
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

  void _removeFile() {
    File(widget.file.path).deleteSync(recursive: true);
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String> ioOutputPath(String filePath, FileFormat format) async {
    final tempPath = (await getTemporaryDirectory()).path;
    final name = path.basenameWithoutExtension(filePath);
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return "$tempPath/${name}_$epoch.${format.extension}";
  }

  String _webPath(String prePath, FileFormat format) {
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return '${prePath}_$epoch.${format.extension}';
  }

  String webInputPath(FileFormat format) => _webPath('input', format);

  String webOutputPath(FileFormat format) => _webPath('output', format);

  Future<void> _exportCover() async {
    try {
      final cover = await extractCover();

      if (mounted) {
        // showDialog(
        //   context: context,
        //   builder: (_) => CoverResultPopup(cover: cover),
        // );
        BlocProvider.of<SelectCoverCubit>(context).selectCover(cover.path);
        context.pop();
        debugPrint("cover ${cover.path}");
      }
    } catch (e) {
      _showErrorSnackBar("Error on cover exportation :(");
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
      timeMs: _controller.selectedCoverVal?.timeMs ?? _controller.startTrim.inMilliseconds,
      quality: quality,
    );

    final inputPath =
        kIsWeb ? webInputPath(FileFormat.fromMimeType(coverFile.mimeType)) : coverFile.path;
    final outputPath =
        kIsWeb ? webOutputPath(outputFormat) : await ioOutputPath(coverFile.path, outputFormat);

    var config = _controller.createCoverFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: '"$inputPath"',
      outputPath: '"$outputPath"',
      scale: scale,
      quality: quality,
      isFiltersEnabled: isFiltersEnabled,
    );

    debugPrint('VideoEditor - run export cover command : [$execute]');

    if (kIsWeb) {
      return const FFmpegExport().executeFFmpegWeb(
        execute: execute,
        inputData: await coverFile.readAsBytes(),
        inputPath: inputPath,
        outputPath: outputPath,
        outputMimeType: outputFormat.mimeType,
      );
    } else {
      return const FFmpegExport().executeFFmpegIO(
        execute: execute,
        outputPath: outputPath,
        outputMimeType: outputFormat.mimeType,
      );
    }
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
      onStatistics != null ? (s) => onStatistics(FFmpegStatistics.fromIOStatistics(s)) : null,
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
    FFmpeg? ffmpeg;
    final logs = <String>[];
    try {
      ffmpeg = createFFmpeg(CreateFFmpegParam(log: false));
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
    return videoDurationMs <= 0.0 ? 0.0 : (time / videoDurationMs).clamp(0.0, 1.0);
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