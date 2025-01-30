import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

///to track user connectivity.
///To backup when user conectivity when not updated to offline properly.
Future<void> updateUserLastSeen() async {
  final DocumentReference ref =
      firebaseFirestore.collection('users').doc(firebaseAuth.currentUser!.uid);
  firebaseFirestore.runTransaction(
    (transaction) async {
      transaction.update(ref, {'lastSeen': FieldValue.serverTimestamp()});
    },
  );
}
