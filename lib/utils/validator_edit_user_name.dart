
import 'package:cloud_firestore/cloud_firestore.dart';

bool isCanEditUserName(Timestamp timestamp) {
  // Get the current time
  DateTime now = DateTime.now();

  // Convert Firestore timestamp to DateTime
  DateTime timestampDateTime = timestamp.toDate();

  // Calculate the difference in milliseconds
  int difference = now.difference(timestampDateTime).inMilliseconds;

  // Calculate the difference in days
  int differenceInDays = (difference / (24 * 60 * 60 * 1000)).round();

  // Check if the difference is greater than or equal to 14 days (2 weeks)
  return differenceInDays >= 14;
}

int calculateDaysAgo(Timestamp timestamp) {
  // Get the current time
  DateTime now = DateTime.now();

  // Convert Firestore timestamp to DateTime
  DateTime timestampDateTime = timestamp.toDate();

  // Calculate the difference in days
  int differenceInDays = now.difference(timestampDateTime).inDays;

  return differenceInDays;
}

int daysUntilTwoWeeks(Timestamp timestamp) {
  // Get the current time
  DateTime now = DateTime.now();

  // Convert Firestore timestamp to DateTime
  DateTime timestampDateTime = timestamp.toDate();

  // Calculate the difference in days
  int differenceInDays = now.difference(timestampDateTime).inDays;

  // Calculate the remaining days until two weeks (14 days)
  int remainingDays = 14 - differenceInDays;

  return remainingDays;
}

String? validateNoWhitespace(String? value) {
  if (value!.contains(RegExp(r'\s'))) {
    return 'Nama pengguna tidak boleh menggunakan spasi.';
  } else if (value.isEmpty) {
    return 'Nama Pengguna tidak boleh kosong.';
  } else if (value.trim().isEmpty) {
    return 'Nama pengguna tidak boleh diawali spasi.';
  }
  return null; // Return null if the input is valid
}
