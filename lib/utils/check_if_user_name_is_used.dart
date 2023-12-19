import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

Future<bool> isUserNameAvailable(String value) async {
  try {
    QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('users')
        .where('uid', isNotEqualTo: firebaseAuth.currentUser!.uid)
        .where('userName', isEqualTo: value)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      debugPrint(' qwerty Document(s) exist with the specified query');
      // Access the first document's data if needed
      debugPrint(
          'qwerty First document data: ${querySnapshot.docs.first.data()}');
      return false;
    } else {
      debugPrint('qwerty No document found with the specified query');
      return true;
    }
  } catch (e) {
    debugPrint('qwerty Error checking document existence with query: $e');
    return false;
  }
}
