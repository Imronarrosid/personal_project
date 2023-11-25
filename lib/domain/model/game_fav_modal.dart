import 'package:cloud_firestore/cloud_firestore.dart';

class GameFav {
  final String? gameTitle;
  final String? gameImage;

  GameFav({
    this.gameTitle,
    this.gameImage,
  });

  static fromSnap(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return GameFav(gameImage: data['icon'], gameTitle: data['title']);
  }
}
