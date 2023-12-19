import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/language/cubit/language_cubit.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_white_fff5f5f5,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: COLOR_black_ff121212,
        backgroundColor: COLOR_white_fff5f5f5,
        title: Text(LocaleKeys.title_language.tr()),
      ),
      body: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: Dimens.DIMENS_24,
              ),
              Text(LocaleKeys.label_pick_language.tr()),
              SizedBox(
                height: Dimens.DIMENS_12,
              ),
              RadioListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                tileColor: Colors.white,
                groupValue: context.locale.languageCode,
                value: LOCALE.id.code,
                onChanged: (value) {
                  _setLocale(context, value!);
                },
                title: Text(LocaleKeys.label_language_indonesia.tr()),
              ),
              RadioListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                tileColor: Colors.white,
                groupValue: context.locale.languageCode,
                value: LOCALE.en.code,
                onChanged: (value) {
                  _setLocale(context, value!);
                },
                title: Text(LocaleKeys.label_language_english.tr()),
              ),
            ]),
          );
        },
      ),
    );
  }

  void _setLocale(BuildContext context, String selected) {
    final languageCubit = BlocProvider.of<LanguageCubit>(context);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                '${LocaleKeys.label_pick_language.tr()}?',
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: TextButton.styleFrom(
                        textStyle: TextStyle(color: COLOR_white_fff5f5f5)),
                    child: Text(LocaleKeys.label_cancel.tr(),
                        style: TextStyle(color: COLOR_black.withOpacity(0.5)))),
                TextButton(
                    onPressed: () {
                      context.setLocale(Locale(selected));
                      languageCubit.setLocale(selected);
                      context.pop();
                      // context.pushReplacement(APP_PAGE.home.toPath);
                    },
                    child: Text(LocaleKeys.label_oke.tr()))
              ],
            ));
  }
}
