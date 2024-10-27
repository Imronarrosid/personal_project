import 'package:flutter/material.dart';

class IsCanScrollNotification extends ChangeNotifier {
  static IsCanScrollNotification instance = IsCanScrollNotification();

  bool _value = true;
  double _previousScrollPosition = 0;

  bool get value => _value;
  void setValue(bool isCanSroll) {
    _value = isCanSroll;
    notifyListeners();
  }

  ScrollPhysics getPhysics(bool valu) {
    if (value) {
      return const AlwaysScrollableScrollPhysics();
    } else {
      return const NeverScrollableScrollPhysics();
    }
  }

  bool onNotification(ScrollNotification scrollNotification) {
    if (_value && scrollNotification.metrics.atEdge) {
      _value = false; // Disable PageView scroll
      debugPrint('scrolling $_value ${scrollNotification.metrics.atEdge}');
      notifyListeners();
    } else if (!scrollNotification.metrics.atEdge && !_value) {
      _value = true; // Enable PageView scroll
      debugPrint('scrolling $_value');
      notifyListeners();
    }
    return false;
  }

  bool onHover(value) {
    if (!value && !_value) {
      notifyListeners();
      _value = true;
    } else if(value && _value){
      _value = false;
      notifyListeners();
    }
    return _value;
  }
}
