import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/constant/color.dart';
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
          appBar: AppBar(
            title: const Text('Caches'),
          ),
          body: FutureBuilder(
            future: fileRepository.getAppCaches(),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    String path = data[index];
                    return ListTile(
                        leading: SizedBox(
                          width: 20,
                          height: 20,
                          child: FutureBuilder(
                              future: fileRepository.getVideoThumnails(path),
                              builder: (context, snapshot) {
                                var data = snapshot.data;
                                if (!snapshot.hasData) {
                                  return Container(
                                    color: COLOR_grey,
                                  );
                                }
                                return Image.file(data!);
                              }),
                        ),
                        title: Text(path));
                  });
            },
          ),
        );
      }),
    );
  }
}
