import 'dart:async';

import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class SearchRepository {
  StreamSubscription? searchSubscription;
  Future<List<User>> onSearchChanged(String query) async {
    List<User> searchResults = [];
    if (query.isNotEmpty) {
      // Debounce the search to reduce queries to Firestore
      await firebaseFirestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get()
          .then((value) {
        for (var element in value.docs) {
          searchResults.add(
              // User(
              //     id: element['uid'],
              //     name: element['name'],
              //     userName: element['userName'],
              //     photo: element['photoUrl']),
              User.fromSnap(element));
        }
      });
      await firebaseFirestore
          .collection('users')
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThan: '${query}z')
          .get()
          .then((value) {
        for (var element in value.docs) {
          if (!searchResults.contains(User.fromSnap(element))) {
            searchResults.add(User.fromSnap(element));
          }
        }
      });
    }
    return searchResults;
  }

  StreamSubscription? searchGameSubscription;
  Future<List<GameFav>> onSearchGame(String query) async {
    List<GameFav> searchResults = [];
    if (query.isNotEmpty) {
      await firebaseFirestore
          .collection('gameFavorites')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .get()
          .then((value) {
        for (var element in value.docs) {
          searchResults.add(GameFav.fromSnap(element));
        }
      });
    }
    return searchResults;
  }
}
