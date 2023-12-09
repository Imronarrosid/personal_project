import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/file_repository.dart';

class CachesPage extends StatelessWidget {
  const CachesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => FileRepository(),
      child: Builder(builder: (context) {
        FileRepository fileRepository =
            RepositoryProvider.of<FileRepository>(context);
        return Scaffold(
            backgroundColor: COLOR_white_fff5f5f5,
            appBar: AppBar(
              backgroundColor: COLOR_white_fff5f5f5,
              foregroundColor: COLOR_black_ff121212,
              elevation: 0,
              title: const Text('Caches'),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: Dimens.DIMENS_15,
                ),
                FutureBuilder(
                    future: _getCacheInfo(),
                    builder: (_, snapshot) {
                      int cacheSize = 0;
                      if (snapshot.hasData) {
                        cacheSize = snapshot.data!;
                      }
                      return ListTile(
                        tileColor: Colors.white,
                        title: Text('Cache: ${_fileMBSize(cacheSize)}'),
                        subtitle: Text(
                            'Kamu dapat membersihkan cache, Akun tidak akan terpengaruh'),
                        trailing: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                          decoration: BoxDecoration(
                              color: COLOR_black_ff121212,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: COLOR_white_fff5f5f5),
                          ),
                        ),
                      );
                    }),
              ],
            ));
      }),
    );
  }

  String _fileMBSize(int bytes) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<int> _getCacheInfo() async {
    try {
      final Directory appDataDir = await getTemporaryDirectory();
      int appDataSize = 0;

      await for (FileSystemEntity entity in appDataDir.list(recursive: true)) {
        if (entity is File) {
          appDataSize += await entity.length();
        }
      }

      return appDataSize;
    } catch (e) {
      print('Error getting app data size: $e');
      return 0;
    }
  }
}
