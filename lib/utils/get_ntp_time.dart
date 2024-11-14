import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

Future<DateTime> fetchTime() async {
  DocumentReference ref = firebaseFirestore
      .collection('users')
      .doc(firebaseAuth.currentUser!.uid)
      .collection('dateTime')
      .doc('dateTime');
  await ref.set({'dateTime': FieldValue.serverTimestamp()});
  DateTime dateTime = await ref.get().then(
    (value) {
      debugModePrint((value.data() as Map<String, dynamic>)['dateTime']);
      Timestamp timeStamp =
          ((value.data() as Map<String, dynamic>)['dateTime']);
      debugModePrint(timeStamp.toDate());
      return timeStamp.toDate();
    },
  );
  return dateTime;
}
