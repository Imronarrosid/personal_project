import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/router/route_utils.dart';

showEditPPModal(BuildContext context) {
  var picker = ImagePicker();

  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 200,
            padding: EdgeInsets.all(Dimens.DIMENS_12),
            decoration: BoxDecoration(
                color: COLOR_white_fff5f5f5,
                borderRadius: BorderRadius.circular(10)),
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
                Text(
                  'Foto Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Material(
                  child: ListTile(
                    leading: Icon(MdiIcons.camera),
                    title: Text('Camera'),
                    onTap: () async {
                      XFile? file =
                          await picker.pickImage(source: ImageSource.camera);
                      if (context.mounted && file != null) {
                        context.push(APP_PAGE.cropImage.toPath, extra: file);
                      }
                    },
                  ),
                ),
                Material(
                  child: ListTile(
                    leading: Icon(MdiIcons.image),
                    title: Text('Galeri'),
                    onTap: () async {
                      XFile? file = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 15);
                      if (context.mounted && file != null) {
                        context.push(APP_PAGE.cropImage.toPath, extra: file);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
