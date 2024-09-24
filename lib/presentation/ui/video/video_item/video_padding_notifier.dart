import 'package:flutter/material.dart';

class VideoPaddingNOtifire extends ChangeNotifier {
  static VideoPaddingNOtifire instance = VideoPaddingNOtifire();
  double _bottomPadding = 0.0;

  double get bottomPadding => _bottomPadding;

  void setBottomPdding({required double bottomSheetHeight}) {
    _bottomPadding = bottomSheetHeight.isNegative ? 0 : bottomSheetHeight;

    notifyListeners();
  }
}
