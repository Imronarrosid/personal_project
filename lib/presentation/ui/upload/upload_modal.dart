import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/services/firebase/image_picker.dart';
import 'package:personal_project/presentation/router/route_utils.dart';

void showUploadModal(BuildContext context) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              padding: EdgeInsets.all(Dimens.DIMENS_12),
              decoration: BoxDecoration(
                  color: COLOR_white_fff5f5f5,
                  borderRadius: BorderRadius.circular(10)),
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: Dimens.DIMENS_50,
                      height: Dimens.DIMENS_8,
                      decoration: BoxDecoration(
                          color: COLOR_grey,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_6,
                  ),
                  const Text(
                    'Upload',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_6,
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.camera),
                    title: const Text('Camera'),
                    onTap: () async {
                      Future<XFile?> video = pickVideoFromCamera();

                      Future.delayed(const Duration(milliseconds: 100), () {
                        _loadFileModal(context);
                      });
                      XFile? pickVideo = await video;

                      if (pickVideo != null && context.mounted) {
                        context.pop();
                        debugPrint('picked');
                        context.push(APP_PAGE.videoEditor.toPath,
                            extra: pickVideo);
                      } else if (pickVideo == null && context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.image),
                    title: const Text('Galery'),
                    onTap: () async {
                      Future<XFile?> video = pickVideoFromGalery();

                      Future.delayed(const Duration(milliseconds: 100), () {
                        _loadFileModal(context);
                      });
                      XFile? pickVideo = await video;

                      if (pickVideo != null && context.mounted) {
                        context.pop();
                        debugPrint('picked');
                        context.push(APP_PAGE.videoEditor.toPath,
                            extra: pickVideo);
                      } else if (pickVideo == null && context.mounted) {
                        context.pop();
                      }
                    },
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
            decoration: BoxDecoration(
                color: COLOR_white_fff5f5f5,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                SizedBox(
                    width: Dimens.DIMENS_20,
                    height: Dimens.DIMENS_20,
                    child: const CircularProgressIndicator()),
                SizedBox(
                  width: Dimens.DIMENS_8,
                ),
                const Text('Memuat file')
              ],
            ),
          ),
        );
      });
}
