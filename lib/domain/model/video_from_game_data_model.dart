import 'package:personal_project/domain/model/game_fav_modal.dart';

class VideoFromGameData {
  final GameFav game;
  final String captions;
  final String profileImg;

  VideoFromGameData(
      {required this.game, required this.captions, required this.profileImg});
}
