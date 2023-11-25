import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
}
