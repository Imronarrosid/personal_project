import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_profile_pict_cubit.dart';

class PrevewProfilePictPage extends StatelessWidget {
  final XFile? imageFile;
  const PrevewProfilePictPage({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfilePictCubit, EditProfilePictState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.label_profile_pict.tr()),
          backgroundColor: Colors.transparent,
          foregroundColor: COLOR_black_ff121212,
          elevation: 0,
          leading: IconButton(
              icon: Icon(MdiIcons.close), onPressed: () => context.pop()),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.check),
              onPressed: () {
                BlocProvider.of<EditProfilePictCubit>(context).editProfilePict(
                  File(imageFile!.path),
                );
                context.pop();
              },
            ),
          ],
        ),
        body: Center(
          child: Image.file(File(imageFile!.path)),
        ),
      ),
    );
  }
}
