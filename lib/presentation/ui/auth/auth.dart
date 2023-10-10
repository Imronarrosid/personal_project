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
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';

void showAuthBottomSheetFunc(BuildContext context) {
  showModalBottomSheet(
      context: context,
      enableDrag: true,
      elevation: 4,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            debugPrint('auth state $state');
            if (state is LoginProcessing) {
              context.pop();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: COLOR_white_fff5f5f5,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(0),
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
                SizedBox(
                  height: Dimens.DIMENS_50,
                ),
                Text(
                  LocaleKeys.label_signin.tr(),
                  style: TextStyle(
                      fontSize: FontSize.FONT_SIZE_24,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(
                  height: Dimens.DIMENS_70,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_24),
                  child: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: InkWell(
                      splashColor: COLOR_grey,
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        BlocProvider.of<AuthBloc>(context)
                            .add(LogInWithGoogle());
                      },
                      child: Container(
                        height: Dimens.DIMENS_50,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimens.DIMENS_8,
                            vertical: Dimens.DIMENS_8),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: COLOR_grey,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: SvgPicture.asset(
                                  Images.IC_GOOLE,
                                  width: Dimens.DIMENS_34,
                                )),
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
          ),
        );
      });
}
