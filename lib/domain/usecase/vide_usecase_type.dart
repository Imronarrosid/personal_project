import 'package:personal_project/domain/model/game_fav_modal.dart';

abstract class VideoUseCaseType {
  Future<void> uploapVideo({
    required String songName,
    required String caption,
    required String videoPath,
    required GameFav game,
  });
}
