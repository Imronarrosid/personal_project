import 'package:flutter/foundation.dart';

class LikeAnimationController {
  final ValueNotifier<bool> _trigger = ValueNotifier(false);

  void show() {
    _trigger.value = true;
  }

  set setShowAnimation(bool isShow) => _trigger.value = isShow;

  ValueListenable<bool> get listenable => _trigger;
}
