import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project/data/repository/upload_repository.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:video_editor_2/video_editor.dart';
import 'package:universal_html/html.dart' as html;

import '../../../constant/color.dart';
import '../../../constant/dimens.dart';
import '../../../domain/services/firebase/image_picker.dart';

class DropZonePage extends StatefulWidget {
  const DropZonePage({super.key});

  @override
  State<DropZonePage> createState() => _DropZonePageState();
}

class _DropZonePageState extends State<DropZonePage> {
  late DropzoneViewController _dropZoneController;

  DropStatus _dropStatus = DropStatus.created;

  @override
  Widget build(BuildContext context) {
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
                onLoaded: () => print('Zone loaded'),
                onError: (String? ev) => print('Error: $ev'),
                onHover: () {
                  print('Zone hovered');
                  setState(() {
                    _dropStatus = DropStatus.hover;
                  });
                },
                onDrop: (ev) async {
                  XFile xFile =
                      XFile(html.Url.createObjectUrl(ev), mimeType: '.mp4');
                  print('Drop: ${(ev as html.File).name} ${xFile.name}');
                  if (ev.name.contains('.mp4')) {
                    UploadRepository.instance.pickVideo(xFile);
                    context.go(
                        APP_PAGE.upload.toPath + APP_PAGE.videoEditor.toPath);
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
                  print('Zone left');
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
                        debugPrint('chose video');

                        UploadRepository.instance
                            .pickVideoFromComputer(context);
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
              debugPrint('chose video');
              UploadRepository.instance.pickVideoFromComputer(context);
            },
          ),
        ),
      );
    }
    ;
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
