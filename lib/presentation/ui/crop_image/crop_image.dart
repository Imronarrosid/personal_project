import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

Future<XFile?> cropImage(
  BuildContext context, {
  required File? pickedFile,
}) async {
  try {
    final CroppedFile? croppedFile;

    croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: LocaleKeys.title_crop.tr(),
            toolbarColor: Theme.of(context).colorScheme.surface,
            toolbarWidgetColor: Theme.of(context).colorScheme.onSurface,
            initAspectRatio: CropAspectRatioPreset.square,
            hideBottomControls: true,
            lockAspectRatio: true),
        IOSUiSettings(
          title: LocaleKeys.title_crop.tr(),
          aspectRatioLockEnabled: true,
          hidesNavigationBar: true,
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.page,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
          viewwMode: WebViewMode.mode_2,
        ),
      ],
    );

    return XFile(croppedFile!.path);
  } catch (e) {
    return null;
  }
}
