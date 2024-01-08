import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

Future<File?> cropImage(
  BuildContext context, {
  required File? pickedFile,
}) async {
  try {
    final CroppedFile? croppedFile;

    croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: LocaleKeys.title_crop.tr(),
            toolbarColor: Theme.of(context).colorScheme.secondary,
            toolbarWidgetColor: Theme.of(context).colorScheme.primary,
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
          presentStyle: CropperPresentStyle.page,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'square'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );

    return File(croppedFile!.path);
  } catch (e) {
    return null;
  }
}
