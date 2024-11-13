import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/video_model.dart';

import '../../../domain/services/firebase/firebase_service.dart';

class Testpage extends StatefulWidget {
  const Testpage({super.key});

  @override
  State<Testpage> createState() => _TestpageState();
}

class _TestpageState extends State<Testpage> {
  List<Video> listDocs = [];
  Future<List<Video>> getListVideoGameIsNull({required int limit}) async {
    // if (gameList.isEmpty) {
    //   return [];
    // }
    try {
      await firebaseFirestore.collection('videos').limit(1).get().then(
        (value) {
          value.docs.forEach(
            (element) {
              listDocs.add(Video.fromSnap(element));
            },
          );
        },
      );

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());

      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: getListVideoGameIsNull(limit: 3),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return PageView.builder(
                controller: PageController(),
                itemCount: listDocs.length,
        
                itemBuilder: (context, index) {
                  CachedVideoPlayerPlusController controller =
                      CachedVideoPlayerPlusController.networkUrl(
                    Uri.parse(snapshot.data![index].videoUrl),
                    httpHeaders: {
                      'Cache-Control': 'max-age=3600',
                    },
                  );
        
                  controller.initialize().then(
                        (value) => controller.play(),
                      );
                  return SizedBox(
                    width: 200,
                    height:300,
                    child: CachedVideoPlayerPlus(controller));
                },
              );
            }),
      ),
    );
  }
}
