import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_profile_pict_cubit.dart';

class PrevewProfilePictPage extends StatelessWidget {
  final XFile? imageFile;
  const PrevewProfilePictPage({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfilePictCubit, EditProfilePictState>(
      listener: (context, state) {
        if (state.status == EditProfilePicStatus.success) {
          context.pop();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Foto Profil'),
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
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return const Center(child: CircularProgressIndicator());
                    });
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
