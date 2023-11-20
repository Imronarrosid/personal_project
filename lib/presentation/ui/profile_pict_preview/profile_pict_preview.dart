import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';

class PrevewProfilePictPage extends StatefulWidget {
  final XFile? imageFile;
  const PrevewProfilePictPage({super.key, this.imageFile});

  @override
  State<PrevewProfilePictPage> createState() => _PrevewProfilePictPageState();
}

class _PrevewProfilePictPageState extends State<PrevewProfilePictPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foto Profil'),
        backgroundColor: Colors.transparent,
        foregroundColor: COLOR_black_ff121212,
        elevation: 0,
        leading: IconButton(
            icon: Icon(MdiIcons.close), onPressed: () => context.pop()),
            actions: [IconButton(
            icon: Icon(MdiIcons.check), onPressed: () => context.pop()),],
      ),
      body: Center(
        child: Image.file(File(widget.imageFile!.path)),
      ),
    );
  }
}
