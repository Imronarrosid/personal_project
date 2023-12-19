import 'dart:math';

String generateRandomString(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))),
  );
}
