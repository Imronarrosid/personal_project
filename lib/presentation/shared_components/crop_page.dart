
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fraction/fraction.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:video_editor_2/video_editor.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key, required this.controller});

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_black_ff121212,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Dimens.DIMENS_24),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: Dimens.DIMENS_34,
                      ),
                      color: COLOR_white_fff5f5f5),
                  Expanded(
                    child: Text(
                      LocaleKeys.title_crop.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.FONT_SIZE_18,
                          color: COLOR_white_fff5f5f5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // WAY 1: validate crop parameters set in the crop view
                      controller.applyCacheCrop();
                      // WAY 2: update manually with Offset values
                      // controller.updateCrop(const Offset(0.2, 0.2), const Offset(0.8, 0.8));
                      Navigator.pop(context);
                    },
                    icon:
                        FaIcon(FontAwesomeIcons.check, size: Dimens.DIMENS_34),
                    color: const CropGridStyle().selectedBoundariesColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimens.DIMENS_20),
            Expanded(
              child: CropGridViewer.edit(
                controller: controller,
                rotateCropArea: false,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                flex: 4,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            color: COLOR_white_fff5f5f5,
                            onPressed: () =>
                                controller.preferredCropAspectRatio = controller
                                    .preferredCropAspectRatio
                                    ?.toFraction()
                                    .inverse()
                                    .toDouble(),
                            icon: controller.preferredCropAspectRatio != null &&
                                    controller.preferredCropAspectRatio! < 1
                                ? Icon(
                                    Icons.panorama_vertical_select_rounded,
                                    color: const CropGridStyle()
                                        .selectedBoundariesColor,
                                  )
                                : const Icon(Icons.panorama_vertical_rounded),
                          ),
                          IconButton(
                            color: COLOR_white_fff5f5f5,
                            onPressed: () =>
                                controller.preferredCropAspectRatio = controller
                                    .preferredCropAspectRatio
                                    ?.toFraction()
                                    .inverse()
                                    .toDouble(),
                            icon: controller.preferredCropAspectRatio != null &&
                                    controller.preferredCropAspectRatio! > 1
                                ? Icon(
                                    Icons.panorama_horizontal_select_rounded,
                                    color: const CropGridStyle()
                                        .selectedBoundariesColor,
                                  )
                                : const Icon(Icons.panorama_horizontal_rounded),
                          ),
                          IconButton(
                            color: COLOR_white_fff5f5f5,
                            onPressed: () => controller
                                .rotate90Degrees(RotateDirection.left),
                            icon: const FaIcon(FontAwesomeIcons.rotateLeft),
                          ),
                          IconButton(
                            color: COLOR_white_fff5f5f5,
                            onPressed: () => controller
                                .rotate90Degrees(RotateDirection.right),
                            icon: const FaIcon(FontAwesomeIcons.rotateRight),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Dimens.DIMENS_8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCropButton(context, null),
                          _buildCropButton(context, 1.toFraction()),
                          _buildCropButton(
                              context, Fraction.fromString("9/16")),
                          _buildCropButton(context, Fraction.fromString("3/4")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 15),
          ]),
        ),
      ),
    );
  }

  Widget _buildCropButton(BuildContext context, Fraction? f) {
    if (controller.preferredCropAspectRatio != null &&
        controller.preferredCropAspectRatio! > 1) f = f?.inverse();

    return Flexible(
      child: Theme(
        data: ThemeData(
          primarySwatch: createMaterialColor(
              COLOR_white_fff5f5f5), // Define your primary color
        ),
        child: TextButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor:
                controller.preferredCropAspectRatio == f?.toDouble()
                    ? const CropGridStyle().selectedBoundariesColor
                    : null,
            foregroundColor:
                controller.preferredCropAspectRatio == f?.toDouble()
                    ? COLOR_black_ff121212
                    : null,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => controller.preferredCropAspectRatio = f?.toDouble(),
          child: Text(
            f == null
                ? LocaleKeys.label_free.tr()
                : '${f.numerator}:${f.denominator}',
          ),
        ),
      ),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  return MaterialColor(color.value, <int, Color>{
    50: color.withOpacity(0.1),
    100: color.withOpacity(0.2),
    200: color.withOpacity(0.3),
    300: color.withOpacity(0.4),
    400: color.withOpacity(0.5),
    500: color.withOpacity(0.6),
    600: color.withOpacity(0.7),
    700: color.withOpacity(0.8),
    800: color.withOpacity(0.9),
    900: color,
  });
}
