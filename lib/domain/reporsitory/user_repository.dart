import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/usecase/user_usecase_type.dart';

class UserRepository implements UserUseCaseType {
  @override
  Future<Map<String, dynamic>> getUserData(String uid) async {
    var myVideos = await FirebaseServices.firebaseFirestore
        .collection('videos')
        .where('uid', isEqualTo: uid)
        .get();
    DocumentSnapshot userDoc = await FirebaseServices.firebaseFirestore
        .collection('users')
        .doc(uid)
        .get();
    final userData = userDoc.data()! as dynamic;
    String name = userData['name'];
    String photo = userData['photo'];
    int likes = 0;
    int followers = 0;
    int following = 0;
    bool isFollowing = false;

    for (var item in myVideos.docs) {
      likes += (item.data()['likes'] as List).length;
    }
    var followerDoc = await FirebaseServices.firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    var followingDoc = await FirebaseServices.firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    followers = followerDoc.docs.length;
    following = followingDoc.docs.length;

    await FirebaseServices.firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(uid)
        .get()
        .then((value) {
      if (value.exists) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }
    });

    var user = {
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing,
      'likes': likes.toString(),
      'photo': photo,
      'name': name,
    };

    return user;
  }

  @override
  Future<void> followUser(
      {required String currentUserUid, required String uid}) async {
    var doc = await FirebaseServices.firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(currentUserUid)
        .get();
    if (!doc.exists) {
      await FirebaseServices.firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .doc(currentUserUid)
          .set({});
      await FirebaseServices.firebaseFirestore
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
      await FirebaseServices.firebaseFirestore
          .collection('users')
          .doc(currentUserUid)
          .collection('following')
          .doc(uid)
          .delete();
      await FirebaseServices.firebaseFirestore
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
    var myVideos = await FirebaseServices.firebaseFirestore
        .collection('videos')
        .where('uid', isEqualTo: uid)
        .get();

    for (var i = 0; i < myVideos.docs.length; i++) {
      thumbnails.add((myVideos.docs[i].data() as dynamic)['thumnail']);
    }

    return Future.value(thumbnails);
  }
}
