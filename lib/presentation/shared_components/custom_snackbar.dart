import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

void showUploadingSnackBar() {
  Fluttertoast.showToast(
      msg: LocaleKeys.message_uploading.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: COLOR_black_ff121212,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showUploadedSnackBar() {
  Fluttertoast.showToast(
      msg: LocaleKeys.message_uploaded.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: COLOR_black_ff121212,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showLoginSuccessSnackBar() {
  Fluttertoast.showToast(
      msg: LocaleKeys.message_login_success.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: COLOR_black_ff121212,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showLoginErrorSnackBar() {
  Fluttertoast.showToast(
      msg: 'Login error',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: COLOR_black_ff121212,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showNoInternetSnackBar() {
  Fluttertoast.showToast(
      msg: 'No internet',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: COLOR_black_ff121212,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showLoginFailedSnackBar() {
  Fluttertoast.showToast(
      msg: 'Login gagal',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: COLOR_black_ff121212,
      textColor: Colors.white,
      fontSize: 16.0);
}
