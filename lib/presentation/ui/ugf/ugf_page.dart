import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';

class UGFPage extends StatefulWidget {
  const UGFPage({super.key});

  @override
  State<UGFPage> createState() => _UGFPageState();
}

class _UGFPageState extends State<UGFPage> {
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                AuthRepository authRepository =
                    RepositoryProvider.of<AuthRepository>(context);
                if (imageFile != null && controller.text.isNotEmpty) {
                  await authRepository.addGameFav(controller.text, imageFile!);
                  setState(() {
                    imageFile = null;
                    controller.clear();
                  });
                }
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(label: Text('Game Title')),
          ),
          ElevatedButton(
              onPressed: () async {
                ImagePicker picker = ImagePicker();
                XFile? file =
                    await picker.pickImage(source: ImageSource.gallery);

                if (file != null) {
                  setState(() {
                    imageFile = File(file.path);
                  });
                }
              },
              child: const Text('Game Image')),
          imageFile != null ? Image.file(imageFile!) : Container()
        ],
      ),
    );
  }
}
