import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constant/color.dart';

void showFlutterToast({
  required String msg,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: COLOR_black_ff121212,
    textColor: Colors.white,
    fontSize: 16.0,
    webBgColor: '#222222',
  );
}
