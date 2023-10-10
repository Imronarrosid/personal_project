import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';

class NotAuthenticatedPage extends StatelessWidget {
  const NotAuthenticatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.width,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: Dimens.DIMENS_70,
          child: SvgPicture.asset(
            Images.IC_PERSON_2_OUTLINE,
            width: Dimens.DIMENS_70,
          ),
        ),
        SizedBox(
          height: Dimens.DIMENS_24,
        ),
        Text(LocaleKeys.message_login_first.tr()),
        SizedBox(
          height: Dimens.DIMENS_24,
        ),
        InkWell(
          onTap: () {
            showAuthBottomSheetFunc(context);
          },
          child: Container(
            alignment: Alignment.center,
            width: Dimens.DIMENS_250,
            height: Dimens.DIMENS_36,
            decoration: BoxDecoration(
                color: COLOR_black_ff121212,
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              LocaleKeys.label_login.tr(),
              style: TextStyle(color: COLOR_white_fff5f5f5),
            ),
          ),
        )
      ]),
    );
  }
}
