
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class ChatRepository {
  List<String> _followingUidList = [];

  final List<DocumentSnapshot> _docs = [];

  void clearPreviouseData() {
    _docs.clear();
  }

  Future<void> initSearchFollowingSearch() async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('following')
          .get()
          .then((value) {
        List<String> results = [];
        for (DocumentSnapshot element in value.docs) {
          results.add(element.id);
        }
        _followingUidList = results;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<DocumentSnapshot>> allSuggestionRoom(int limit) async {
    try {
      QuerySnapshot querySnapshot;
      List<DocumentSnapshot> listDocs = [];

      if (_docs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
            .limit(limit)
            .get();

        debugPrint('empty');
      } else {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
            .limit(limit)
            .startAfterDocument(_docs.last)
            .get();
      }
      debugPrint('get user  ${querySnapshot.docs.length}');

      ///List to get last documet
      _docs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<User>> searchUserFromFollowing(String query) async {
    try {
      List<User> searchResults = [];
      // bool iscanSearch = false;
      // do {
      //   iscanSearch = false;
      //   if (_followingUidList.isNotEmpty) {
      //     iscanSearch = true;
      //   }
      // } while (_followingUidList.isEmpty);

      if (query.isNotEmpty) {
        // Debounce the search to reduce queries to Firestore
        await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
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
            .where('uid', whereIn: _followingUidList)
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
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
