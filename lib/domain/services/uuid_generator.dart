import 'package:uuid/uuid.dart';

var uuid = const Uuid();

String generateUuid() {
  return uuid.v4();
}
