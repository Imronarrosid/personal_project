import 'package:flutter/material.dart';

class NavbarNotifier extends ChangeNotifier {
  NavbarState _navbarState = NavbarState.show;

  NavbarState get navbarState => _navbarState;

  void chnageNavbarState(NavbarState isShowing) {
    _navbarState = isShowing;
    notifyListeners();
  }
}

enum NavbarState {
  show,
  hidden,
}
