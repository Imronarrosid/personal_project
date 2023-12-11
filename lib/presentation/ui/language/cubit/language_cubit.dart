import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:restart_app/restart_app.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(this._appService)
      : super(LanguageState(
            status: LanguageStatus.initial,
            selectedLocale: _appService.getAppLocale));

  void setLocale(String selected) {
    if (selected == LOCALE.en.code) {
      _appService.setAppLocale(LOCALE.en);
      Restart.restartApp();
    } else if (selected == LOCALE.id.code) {
      _appService.setAppLocale(LOCALE.id);
      Restart.restartApp();
    }
    emit(LanguageState(
        status: LanguageStatus.changed, selectedLocale: selected));
  }

  final AppService _appService;
}
