import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

enum TabFor { following, followers }

class FollowingNFollowersRepository {
  PagingController<int, String>? controller;
  List<DocumentSnapshot> users = [];

  final int _pageSize = 4;
  final List<Video> currentLoadedVideo = [];

  void initPagingController(String uid, {required TabFor tabFor}) {
    controller = PagingController(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      try {
        _fetchPage(uid: uid, pageKey: pageKey, tabFor: tabFor);
        debugPrint('Fetch data video user:');
      } catch (e) {
        debugPrint('Fetch data video user:$e');
      }
    });
  }

  Future<void> _fetchPage(
      {required TabFor tabFor,
      required String uid,
      required int pageKey}) async {
    try {
      List<String> listUsers = [];
      late final List<DocumentSnapshot> newItems;
      if (tabFor == TabFor.following) {
        newItems = await _getListFollowing(limit: _pageSize, uid: uid);

        for (var element in newItems) {
          listUsers.add(element.id);
        }
      } else if (tabFor == TabFor.followers) {
        newItems = await _getListFollowers(limit: _pageSize, uid: uid);
        for (var element in newItems) {
          listUsers.add(element.id);
        }
      }
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        controller!.appendLastPage(listUsers);
      } else {
        final nextPageKey = pageKey + newItems.length;
        controller!.appendPage(listUsers, nextPageKey);
      }
    } catch (error) {
      controller!.error = error;
    }
  }

  Future<List<DocumentSnapshot>> _getListFollowing(
      {required int limit, required String uid}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (users.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('following')
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('following')
            .startAfterDocument(users.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      users.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> _getListFollowers(
      {required int limit, required String uid}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (users.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('followers')
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('followers')
            .startAfterDocument(users.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      users.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }
}
