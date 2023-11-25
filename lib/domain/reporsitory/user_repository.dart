import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:personal_project/domain/model/user_data_model.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/usecase/user_usecase_type.dart';

class UserRepository implements UserUseCaseType {
  Stream<String> get uid {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      final uid = firebaseUser!.uid;
      // _cache.write(key: userCacheKey, value: user);
      return uid;
    });
  }

  @override
  Future<UserData> getUserData(String uid) async {
    var myVideos = await firebaseFirestore
        .collection('videos')
        .where('uid', isEqualTo: uid)
        .get();
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection('users').doc(uid).get();
    final userData = userDoc.data()! as dynamic;
    String name = userData['name'];
    String photo = userDoc['photoUrl'];
    int likes = 0;
    int followers = 0;
    int following = 0;
    bool isFollowing = false;

    for (var item in myVideos.docs) {
      likes += (item.data()['likes'] as List).length;
    }
    var followerDoc = await firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    var followingDoc = await firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    followers = followerDoc.docs.length;
    following = followingDoc.docs.length;

    await firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((value) {
      if (value.exists) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }
    });

    var user = {
      'uid': userDoc['uid'],
      'name': userDoc['name'],
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing,
      'likes': likes.toString(),
      'photoUrl': photo,
      'userName': userDoc['userName'],
      'updatedAt': userDoc['updatedAt'],
      'userNameUpdatedAt': userDoc['userNameUpdatedAt']
    };

    return UserData.fromMap(user);
  }

  @override
  Future<void> followUser(
      {required String currentUserUid, required String uid}) async {
    var doc = await firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(currentUserUid)
        .get();
    if (!doc.exists) {
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .doc(currentUserUid)
          .set({});
      await firebaseFirestore
          .collection('users')
          .doc(currentUserUid)
          .collection('following')
          .doc(uid)
          .set({});
      // _user.update(
      //   'followers',
      //   (value) => (int.parse(value) + 1).toString(),
      // );
    } else {
      await firebaseFirestore
          .collection('users')
          .doc(currentUserUid)
          .collection('following')
          .doc(uid)
          .delete();
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .doc(currentUserUid)
          .delete();
      // _user.update('followers', (value) => (int.parse(value) - 1).toString());
    }
  }

  @override
  Future<List<String>> getUserVideoThumnails(String uid) async {
    List<String> thumbnails = [];
    var myVideos = await firebaseFirestore
        .collection('videos')
        .where('uid', isEqualTo: uid)
        .get();

    for (var i = 0; i < myVideos.docs.length; i++) {
      thumbnails.add((myVideos.docs[i].data() as dynamic)['thumnail']);
    }

    return Future.value(thumbnails);
  }

  Future<bool> isFollowig(
      {required String currentUserUid, required String otherUserUid}) async {
    await firebaseFirestore
        .collection('user')
        .doc(otherUserUid)
        .collection('followers')
        .doc(currentUserUid)
        .get()
        .then((value) {
      if (value.exists) {
        return true;
      }
    });
    return false;
  }

  Future<String> getBio(String uid) async {
    String bio = '';
    var doc = await firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('otherInfo')
        .doc('bio')
        .get();
    bio = doc['bio'];
    return bio;
  }

  Future<void> editName(String newName) async {
    try {
      debugPrint(newName);
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'name': newName, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editUserName(String newName) async {
    try {
      debugPrint(newName);
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({
        'userName': newName,
        'userNameUpdatedAt': FieldValue.serverTimestamp()
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editBio(String bio) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('otherInfo')
          .doc('bio')
          .set({'bio': bio});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editProfilePict(File imageFile) async {
    try {
      Reference ref = firebaseStorage
          .ref()
          .child('pofilePicts')
          .child('profilePicts ${FieldValue.serverTimestamp()}');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloaUrl = await snapshot.ref.getDownloadURL();
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'photoUrl': downloaUrl});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GameFav>> getAllGameFav() async {
    List<GameFav> gameFav = [];
    try {
      QuerySnapshot<Map<String, dynamic>> docs =
          await firebaseFirestore.collection('gameFavorites').get();
      for (var element in docs.docs) {
        gameFav.add(GameFav.fromSnap(element));
        element.reference;
      }
    } catch (e) {
      rethrow;
    }

    return gameFav;
  }

  Future<void> editGameFav(List<String> gameFav) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('otherInfo')
          .doc('gameFav')
          .set({'titles': gameFav});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> _getAllGameDocuments(
      List<DocumentReference> documentReferences) async {
    List<DocumentSnapshot> documents = [];
    debugPrint('getDocs');
    try {
      for (DocumentReference reference in documentReferences) {
        DocumentSnapshot snapshot = await reference.get();
        if (snapshot.exists) {
          documents.add(snapshot);
        }
      }
    } catch (e) {
      print('Error getting documents: $e');
    }

    return documents;
  }

  Future<List<GameFav>> getSelectedGames(String uid) async {
    List<GameFav> gameFav = [];
    debugPrint('gametes');
    try {
      DocumentSnapshot data = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('otherInfo')
          .doc('gameFav')
          .get();

      List<dynamic> gv = data['titles'];

      debugPrint('reff${gv}');
      var doc = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('otherInfo')
          .doc('bio')
          .get();
      debugPrint('bio: ${doc['bio'].runtimeType}');

    
      // debugPrint('games ${rfs.length}');
      for (var element in gv) {
        var game = await firebaseFirestore
            .collection('gameFavorites')
            .doc(element)
            .get();
        gameFav.add(GameFav.fromSnap(game));

        debugPrint('gameFav$element');
      }
    } catch (e) {
      rethrow;
    }

    return gameFav;
  }
}
