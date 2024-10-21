import 'package:flutter/foundation.dart';

class ListChatNotifier extends ChangeNotifier {
  int _limit = 10;

  int get limit => _limit;

  onEndReached() {
    _limit =_limit + 10;
    notifyListeners();
  }
}
