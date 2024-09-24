import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/upload_repository.dart';
import 'package:personal_project/domain/services/firebase/image_picker.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:universal_html/html.dart' as html;
import 'package:personal_project/utils/pick_video.dart';

void showUploadModal(BuildContext context) {
  final UploadRepository uploadRepository = UploadRepository.instance;
  // late DropzoneViewController controller;
  // showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //           child: GestureDetector(
  //             onTap: () async {
  //               Future<XFile?> video = pickVideoFromGalery();

  //               Future.delayed(const Duration(milliseconds: 100), () {
  //                 _loadFileModal(context);
  //               });
  //               XFile? pickVideo = await video;

  //               if (pickVideo != null && context.mounted) {
  //                 context.pop();
  //                 debugPrint('picked');
  //                 context.push(APP_PAGE.videoEditor.toPath, extra: pickVideo);
  //               } else if (pickVideo == null && context.mounted) {
  //                 context.pop();
  //               }
  //             },
  //             child: SizedBox(
  //                 width: 540,
  //                 height: 540,
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       'testing ${kIsWeb}',
  //                     ),
  //                     // kIsWeb && context.mounted
  //                     //     ? DropZone(
  //                     //         onDragEnter: () {
  //                     //           print('drag enter');
  //                     //         },
  //                     //         onDragExit: () {
  //                     //           print('drag exit');
  //                     //         },
  //                     //         onDrop: (List<html.File?>? p0) async {
  //                     //           debugPrint('on drag');
  //                     //           if (p0!.isNotEmpty) {
  //                     //             debugPrint(p0[0]!.name);
  //                     //             debugPrint(
  //                     //                 'relative[ath${p0[0]!.relativePath}');
  //                     //             File file =
  //                     //                 await _convertHtmlFileToFile(p0.last!);
  //                     //             XFile? pickVideo = XFile(file.path);
  //                     //             debugPrint(pickVideo.path);

  //                     //             if (pickVideo != null && context.mounted) {
  //                     //               debugPrint('picked');
  //                     //               context.push(APP_PAGE.videoEditor.toPath,
  //                     //                   extra: pickVideo);
  //                     //             } else if (pickVideo == null &&
  //                     //                 context.mounted) {}
  //                     //           }
  //                     //         },
  //                     //         child: GestureDetector(
  //                     //           onTap: () async {
  //                     //             Future<XFile?> video = pickVideoFromGalery();

  //                     //             Future.delayed(
  //                     //                 const Duration(milliseconds: 100), () {
  //                     //               _loadFileModal(context);
  //                     //             });
  //                     //             XFile? pickVideo = await video;

  //                     //             if (pickVideo != null && context.mounted) {
  //                     //               context.pop();
  //                     //               debugPrint('picked');
  //                     //               context.push(APP_PAGE.videoEditor.toPath,
  //                     //                   extra: pickVideo);
  //                     //             } else if (pickVideo == null &&
  //                     //                 context.mounted) {
  //                     //               context.pop();
  //                     //             }
  //                     //           },
  //                     //           child: Container(
  //                     //             width: 540,
  //                     //             height: 300,
  //                     //             color: Colors.blue,
  //                     //             child: const Text('Chose file or drag it here'),
  //                     //           ),
  //                     //         ))
  //                     //     : Container(),
  //                     SizedBox(
  //                       width: 400,
  //                       height: 400,
  //                       child: DropzoneView(
  //                         operation: DragOperation.all,
  //                         cursor: CursorType.grab,
  //                         onCreated: (DropzoneViewController ctrl) =>
  //                             controller = ctrl,
  //                         onLoaded: () => print('Zone loaded'),
  //                         onError: (String? ev) => print('Error: $ev'),
  //                         onHover: () => print('Zone hovered'),
  //                         onDrop: (ev) async {
  //                           XFile xFile = XFile(
  //                             html.Url.createObjectUrl(ev),
  //                             mimeType: '.mp4'
  //                           );
  //                           print(
  //                               'Drop: ${(ev as html.File).name} ${xFile.name}');
  //                           context.push(APP_PAGE.videoEditor.toPath,
  //                               extra: xFile);
  //                         },
  //                         onLeave: () => print('Zone left'),
  //                       ),
  //                     )
  //                   ],
  //                 )),
  //           ),
  //         ));
  // return;
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              padding: EdgeInsets.all(Dimens.DIMENS_12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(10)),
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: Dimens.DIMENS_50,
                      height: Dimens.DIMENS_5,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_6,
                  ),
                  Text(
                    LocaleKeys.title_upload.tr(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_6,
                  ),
                  Material(
                    child: ListTile(
                        leading: const Icon(BootstrapIcons.camera),
                        title: Text(LocaleKeys.label_camera.tr()),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        )),
                        onTap: () => uploadRepository.openCamera(context)),
                  ),
                  Material(
                    child: ListTile(
                      leading: const Icon(BootstrapIcons.image),
                      title: Text(LocaleKeys.label_galery.tr()),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )),
                      onTap: () => uploadRepository.pickVideoOnGalery(context),
                    ),
                  )
                ],
              )),
        );
      });
}

Future<dynamic> _loadFileModal(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                SizedBox(
                    width: Dimens.DIMENS_20,
                    height: Dimens.DIMENS_20,
                    child: const CircularProgressIndicator()),
                SizedBox(
                  width: Dimens.DIMENS_8,
                ),
                Text(LocaleKeys.message_load_file.tr())
              ],
            ),
          ),
        );
      });
}

Future<File> _convertHtmlFileToFile(html.File htmlFile) async {
  File? ioFile;
  // Read the file content
  final reader = html.FileReader();
  reader.readAsArrayBuffer(htmlFile);
  reader.onLoadEnd.listen((event) async {
    final Uint8List fileBytes = reader.result as Uint8List;

    // Create a dart:io File in a temporary directory
    ioFile = await _writeToFile(htmlFile.name, fileBytes);

    // Use the dart:io File as needed
    print('Dart File Path: ${ioFile!.path}');
  });
  return ioFile!;
}

Future<File> _writeToFile(String fileName, Uint8List bytes) async {
  // Use the path_provider package to get the temporary directory
  final directory = await Directory.systemTemp.createTemp();
  final ioFile = File('${directory.path}/$fileName');

  // Write the bytes to the file
  await ioFile.writeAsBytes(bytes);
  return ioFile;
}
