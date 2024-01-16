import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/utils/check_network.dart';

void showAuthBottomSheetFunc(BuildContext context) {
  showModalBottomSheet(
      context: context,
      enableDrag: true,
      elevation: 4,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(Dimens.DIMENS_10),
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_45,
                  ),
                  Text(
                    LocaleKeys.label_signin.tr(),
                    style: TextStyle(
                        fontSize: FontSize.FONT_SIZE_24,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_10,
                  ),
                  Text(
                    LocaleKeys.message_login_for_more_experience.tr(),
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.6),
                        ),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_70,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_20),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: InkWell(
                        splashColor: COLOR_grey,
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {
                          if (await checkNetwork() && context.mounted) {
                            BlocProvider.of<AuthBloc>(context)
                                .add(LogInWithGoogle());
                          } else {
                            showNoInternetSnackBar();
                          }
                        },
                        child: Container(
                          height: Dimens.DIMENS_45,
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimens.DIMENS_8,
                              vertical: Dimens.DIMENS_8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(50)),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SvgPicture.asset(
                                  Images.IC_GOOLE,
                                  width: Dimens.DIMENS_34,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  LocaleKeys.label_signin_with_google.tr(),
                                  style: TextStyle(
                                      fontSize: FontSize.FONT_SIZE_16,
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        );
      });
}
