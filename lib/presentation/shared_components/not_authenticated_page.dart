import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
        Icon(
          MdiIcons.account,
          size: Dimens.DIMENS_80,
        ),
        SizedBox(
          height: Dimens.DIMENS_20,
        ),
        Text(LocaleKeys.message_login_first.tr()),
        SizedBox(
          height: Dimens.DIMENS_20,
        ),
        Material(
          color: Theme.of(context).colorScheme.onTertiary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showAuthBottomSheetFunc(context);
            },
            child: Container(
              alignment: Alignment.center,
              width: Dimens.DIMENS_250,
              height: Dimens.DIMENS_38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                LocaleKeys.label_login.tr(),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
