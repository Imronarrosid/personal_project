import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/utils/get_ntp_time.dart';

Future<bool> isCanEditName(Timestamp timestamp) async {
  // Get the current time
  DateTime now = await getNtpTime();

  // Convert Firestore timestamp to DateTime
  DateTime timestampDateTime = timestamp.toDate();

  // Calculate the difference in milliseconds
  int difference = now.difference(timestampDateTime).inMilliseconds;

  // Calculate the difference in days
  int differenceInDays = (difference / (24 * 60 * 60 * 1000)).round();

  // Check if the difference is greater than or equal to 14 days (2 weeks)
  return differenceInDays >= 7;
}

Future<int> calculateDaysAgo(Timestamp timestamp) async {
  // Get the current time
  DateTime now = await getNtpTime();

  // Convert Firestore timestamp to DateTime
  DateTime timestampDateTime = timestamp.toDate();

  // Calculate the difference in days
  int differenceInDays = now.difference(timestampDateTime).inDays;

  return differenceInDays;
}

Future<int> daysUntilOneWeeks(Timestamp timestamp) async {
  // Get the current time
  DateTime now = await getNtpTime();

  // Convert Firestore timestamp to DateTime
  DateTime timestampDateTime = timestamp.toDate();

  // Calculate the difference in days
  int differenceInDays = now.difference(timestampDateTime).inDays;

  // Calculate the remaining days until two weeks (14 days)
  int remainingDays = 7 - differenceInDays;

  return remainingDays;
}
