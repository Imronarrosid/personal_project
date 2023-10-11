import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

void showUploadingSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      LocaleKeys.message_uploading.tr(),
      textAlign: TextAlign.center,
    ),
    backgroundColor: COLOR_black_ff121212.withOpacity(0.4),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
        left: Dimens.DIMENS_80,
        right: Dimens.DIMENS_80,
        bottom: Dimens.DIMENS_70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showUploadedSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      LocaleKeys.message_uploaded.tr(),
      textAlign: TextAlign.center,
    ),
    backgroundColor: COLOR_black_ff121212.withOpacity(0.4),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
        left: Dimens.DIMENS_80,
        right: Dimens.DIMENS_80,
        bottom: Dimens.DIMENS_70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showLoginSuccessSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      LocaleKeys.message_login_success.tr(),
      textAlign: TextAlign.center,
    ),
    backgroundColor: COLOR_black_ff121212.withOpacity(0.4),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
        left: Dimens.DIMENS_80,
        right: Dimens.DIMENS_80,
        bottom: Dimens.DIMENS_70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
