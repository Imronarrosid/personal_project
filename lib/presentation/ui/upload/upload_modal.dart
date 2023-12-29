import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/services/firebase/image_picker.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';

void showUploadModal(BuildContext context) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              padding: EdgeInsets.all(Dimens.DIMENS_12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
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
                      leading: Icon(MdiIcons.camera),
                      title: Text(LocaleKeys.label_camera.tr()),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )),
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
                  ),
                  Material(
                    child: ListTile(
                      leading: Icon(MdiIcons.image),
                      title: Text(LocaleKeys.label_galery.tr()),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )),
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
