import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class SearchRepository {
  StreamSubscription? searchSubscription;
  Future<List<User>> onSearchChanged(String query) async {
    List<User> _searchResults = [];
    if (query.isNotEmpty) {
      // Debounce the search to reduce queries to Firestore
      await firebaseFirestore
          .collection('users')
          .where('searchKey', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('searchKey', isLessThan: '${query.toLowerCase()}z')
          .get()
          .then((value) {
        for (var element in value.docs) {
          _searchResults.add(
            User(
                id: element['uid'],
                userName: element['name'] ?? element['userName'],
                photo: element['photo'] ?? element['photoUrl']),
          );
        }
      });
    }
    return _searchResults;
  }
}
