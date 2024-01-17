import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/dimens.dart';
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
          BootstrapIcons.person_fill,
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
