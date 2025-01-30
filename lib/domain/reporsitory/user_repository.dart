import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/usecase/user_usecase_type.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/debug_mode_print.dart';

class UserRepository implements UserUseCaseType {
  Stream<String> get uid {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      final uid = firebaseUser!.uid;
      // _cache.write(key: userCacheKey, value: user);
      return uid;
    });
  }

  Future<User> getOtherUserData(String uid) async {
    final user = await firebaseFirestore.collection('users').doc(uid).get();

    return User.fromSnap(user);
  }

  Stream<User> currentUserSream() {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .snapshots()
        .map(
          (event) => User.fromSnap(event),
        );
  }

  Stream<User> otherUserSream(String uid) {
    return firebaseFirestore.collection('users').doc(uid).snapshots().map(
          (event) => User.fromSnap(event),
        );
  }

  Future<void> onUserOnline() async {
    return await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }

  Future<void> onUserOffline() async {
    return await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': false,
    });
  }

  Future<void> setTypingIndicator(bool status) async {
    DocumentReference ref = firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid);
    firebaseFirestore.runTransaction(
      (transaction) {
        return transaction.get(ref).then(
          (value) {
            transaction.update(ref, {
              'isTyping': status,
              'lastTyping': FieldValue.serverTimestamp(),
            });
          },
        );
      },
    );
    // return await firebaseFirestore
    //     .collection('users')
    //     .doc(firebaseAuth.currentUser!.uid)
  }
  // @override
  // Future<UserData> getUserData(String uid) async {
  //   var myVideos = await firebaseFirestore
  //       .collection('videos')
  //       .where('uid', isEqualTo: uid)
  //       .get();
  //   DocumentSnapshot userDoc =
  //       await firebaseFirestore.collection('users').doc(uid).get();
  //   final userData = userDoc.data()! as dynamic;
  //   String name = userData['name'];
  //   String photo = userDoc['photoUrl'];
  //   int likes = 0;
  //   int followers = 0;
  //   int following = 0;
  //   bool isFollowing = false;

  //   for (var item in myVideos.docs) {
  //     likes += (item.data()['likes'] as List).length;
  //   }
  //   var followerDoc = await firebaseFirestore
  //       .collection('users')
  //       .doc(uid)
  //       .collection('followers')
  //       .get();
  //   var followingDoc = await firebaseFirestore
  //       .collection('users')
  //       .doc(uid)
  //       .collection('following')
  //       .get();

  //   followers = followerDoc.docs.length;
  //   following = followingDoc.docs.length;

  //   await firebaseFirestore
  //       .collection('users')
  //       .doc(uid)
  //       .collection('followers')
  //       .doc(firebaseAuth.currentUser!.uid)
  //       .get()
  //       .then((value) {
  //     if (value.exists) {
  //       isFollowing = true;
  //     } else {
  //       isFollowing = false;
  //     }
  //   });

  //   var user = {
  //     'uid': userDoc['uid'],
  //     'name': userDoc['name'],
  //     'followers': followers.toString(),
  //     'following': following.toString(),
  //     'isFollowing': isFollowing,
  //     'likes': likes.toString(),
  //     'photoUrl': photo,
  //     'userName': userDoc['userName'],
  //     'updatedAt': userDoc['updatedAt'],
  //     'userNameUpdatedAt': userDoc['userNameUpdatedAt']
  //   };

  //   return UserData.fromMap(user);
  // }

  Future<bool> isFollowing(String uid) async {
    bool isFollowing = false;
    try {
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
      return isFollowing;
    } catch (e) {
      return false;
    }
  }

  Stream<bool>? isFollowingStream(String uid) {
    try {
      const Duration debounceTime = Duration(milliseconds: 300);

      return firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .doc(firebaseAuth.currentUser!.uid)
          .snapshots()
          .map((event) => event.exists)
          .debounceTime(debounceTime)
          .asBroadcastStream();
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getUserSuggestion(int limit) async {
    try {
      final List<User> users = [];
      final QuerySnapshot queryDocumentSnapshot =
          await firebaseFirestore.collection('users').limit(limit).get();

      for (var element in queryDocumentSnapshot.docs) {
        users.add(User.fromSnap(element));
      }
      return users;
    } catch (e) {
      return [];
    }
  }

  Future<int> getFollowingCount(uid) async {
    try {
      int following = 0;
      var followingDoc = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .get();

      following = followingDoc.docs.length;

      return following;
    } catch (e) {
      debugModePrint(e.toString());
      return 0;
    }
  }

  Future<int> getFollowerCount(String uid) async {
    try {
      int followers = 0;
      var followerDoc = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get();
      followers = followerDoc.docs.length;
      return followers;
    } catch (e) {
      debugModePrint(e.toString());
      return 0;
    }
  }

  Future<int> getLikesCount(String uid) async {
    int likes = 0;

    var myVideos = await firebaseFirestore
        .collection('videos')
        .where('uid', isEqualTo: uid)
        .get();

    for (var item in myVideos.docs) {
      if (item.data().containsKey('likesCount')) {
        likes += item.data()['likesCount'] as int;
      } else {
        likes += (item.data()['likes'] as List).length;
      }
    }
    return likes;
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

  Stream getUser(String uid) {
    Stream data = firebaseFirestore.collection('users').doc(uid).snapshots();
    return data;
  }

  Stream<User>? userDataStream(String uid) {
    return firebaseFirestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((user) => User.fromSnap(user));
  }

  Stream<User>? userDataStreamByUsername(String userName) {
    try {
      Stream<User> stream = firebaseFirestore
          .collection('users')
          .where('userName', isEqualTo: userName)
          .limit(1)
          .snapshots()
          .map((user) {
        if (user.docs.isNotEmpty) {
          return User.fromSnap(user.docs.first);
        }
        throw 'User not found.';
      });

      return stream;
    } catch (e) {
      throw e.toString();
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
    try {
      var doc = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('otherInfo')
          .doc('bio')
          .get();
      if (doc.exists) {
        bio = doc['bio'] ?? '';
      }
    } catch (e) {
      debugModePrint(e.toString());
    }
    return bio;
  }

  Future<void> editName(String newName) async {
    try {
      debugModePrint(newName);
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({
        'name': newName,
        'nameUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editUserName(String newName) async {
    try {
      debugModePrint(newName);
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({
        'userName': newName,
        'userNameUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp()
      });
      await firebaseFirestore
          .collection('userNames')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'userName': newName});
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
          .child('pofilePicts/${firebaseAuth.currentUser!.uid}')
          .child('profilePicts ${firebaseAuth.currentUser!.uid}');
      await ref.putData(await imageFile.readAsBytes());

      String downloaUrl = await ref.getDownloadURL();
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'photoUrl': downloaUrl});
      await firebaseFirestore
          .collection('avatars')
          .doc(firebaseAuth.currentUser!.uid)
          .set({'avatar': downloaUrl});

      imageFile.deleteSync(recursive: true);
    } catch (e) {
      debugModePrint('upload $imageFile$e');
      rethrow;
    }
  }

  Future<void> editProfilePictWeb(Uint8List data) async {
    try {
      Reference ref = firebaseStorage
          .ref()
          .child('pofilePicts/${firebaseAuth.currentUser!.uid}')
          .child('profilePicts ${firebaseAuth.currentUser!.uid}');
      await ref.putData(data);

      String downloaUrl = await ref.getDownloadURL();
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'photoUrl': downloaUrl});
      await firebaseFirestore
          .collection('avatars')
          .doc(firebaseAuth.currentUser!.uid)
          .set({'avatar': downloaUrl});
    } catch (e) {
      debugModePrint('upload $data$e');
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

  Stream<QuerySnapshot<Map<String, dynamic>>>? gameStream() {
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        firebaseFirestore.collection('gameFavorites').snapshots();
    return snapshots;
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

  // Future<List<DocumentSnapshot>> _getAllGameDocuments(
  //     List<DocumentReference> documentReferences) async {
  //   List<DocumentSnapshot> documents = [];
  //   debugModePrint('getDocs');
  //   try {
  //     for (DocumentReference reference in documentReferences) {
  //       DocumentSnapshot snapshot = await reference.get();
  //       if (snapshot.exists) {
  //         documents.add(snapshot);
  //       }
  //     }
  //   } catch (e) {
  //     print('Error getting documents: $e');
  //   }

  //   return documents;
  // }

  Future<List<GameFav>> getSelectedGames(String uid) async {
    List<GameFav> gameFav = [];
    debugModePrint('gametes');
    try {
      DocumentSnapshot data = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('otherInfo')
          .doc('gameFav')
          .get();

      List<dynamic> gv = data['titles'];

      // debugModePrint('games ${rfs.length}');
      for (var element in gv) {
        var game = await firebaseFirestore
            .collection('gameFavorites')
            .doc(element)
            .get();
        if (game.exists) {
          gameFav.add(GameFav.fromSnap(game));

          debugModePrint('gameFav$element');
        } else {
          return [];
        }
      }
    } catch (e) {
      debugModePrint(e.toString());
    }

    return gameFav;
  }

  Stream<String>? getAvatar(String uid) {
    try {
      return firebaseFirestore
          .collection('avatars')
          .doc(uid)
          .snapshots()
          .map((event) => event['avatar']);

      // avatar = snap['avatar'];
      // return avatar;
    } catch (e) {
      debugModePrint(e.toString());
      return null;
    }
  }

  Future<List<User>>? getUserListWithLimit(int limit) async {
    List<User> users = <User>[];
    try {
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('following')
          .limit(limit)
          .get();
      for (var element in snapshot.docs) {
        DocumentSnapshot docs =
            await firebaseFirestore.collection('users').doc(element.id).get();
        users.add(User.fromSnap(docs));
      }
      return users;
    } catch (e) {
      debugModePrint(e.toString());
      return [];
    }
  }

  Future<String> getUserNameOnly(String uid) async {
    try {
      String avatar;

      DocumentSnapshot snap =
          await firebaseFirestore.collection('userNames').doc(uid).get();

      avatar = snap['userName'];
      return avatar;
    } catch (e) {
      debugModePrint(e.toString());
      return '';
    }
  }
}
