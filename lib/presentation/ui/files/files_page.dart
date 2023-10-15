import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/domain/model/files_model.dart';
import 'package:personal_project/presentation/shared_components/video_thumbnails_item.dart';
import 'package:personal_project/presentation/ui/files/bloc/files_bloc.dart';

showFileBottomSheet(BuildContext context) {
  BlocProvider.of<FilesBloc>(context).add(LoadFilesEvent());
  final FileManagerController controller = FileManagerController();
  showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(),
          body: FileManager(
            controller: controller,
            builder: (context, snapshot) {
              final List<FileSystemEntity> entities = snapshot;

              List<String> paths =[];
                  for (var element in entities) {
                    if(FileManager.isFile(element)){
                      paths.add(element.path);
                    } else{
                    }
                  }
              return ListView.builder(
                itemCount: entities.length,
                itemBuilder: (context, index) {

                  return Card(
                    child: ListTile(
                      leading: FileManager.isFile(entities[index])
                          ? Icon(Icons.feed_outlined)
                          : Icon(Icons.folder),
                      title: Text(FileManager.basename(entities[index])),
                      onTap: () {
                        if (FileManager.isDirectory(entities[index])) {
                          controller
                              .openDirectory(entities[index]); // open directory
                        } else {
                          // Perform file-related tasks.
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      });
}
