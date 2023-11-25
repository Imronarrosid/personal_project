import 'package:ntp/ntp.dart';

Future<DateTime> getNtpTime() async {
  DateTime myTime = DateTime.now();
  DateTime ntpTime;
  final int offset = await NTP.getNtpOffset(localTime: DateTime.now());
  ntpTime = myTime.add(Duration(milliseconds: offset));

  return ntpTime;
}
