import 'package:fluttertoast/fluttertoast.dart';
import 'package:personal_project/constant/color.dart';

void showToast({
  required String msg,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: COLOR_black_ff121212,
    textColor: COLOR_white_fff5f5f5,
    fontSize: 16.0,
  );
}
