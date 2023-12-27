import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';

String numberFormat(Locale locale, int number) {
  String result = '';
  NumberFormat numberFormat = NumberFormat.compact(locale: 'id_ID');
  if (locale.languageCode == LOCALE.id.code) {
    numberFormat = NumberFormat.compact(locale: 'id_ID');
  } else if (locale.languageCode == LOCALE.en.code) {
    numberFormat = NumberFormat.compact(locale: 'en_EN');
  }
  result = numberFormat.format(number);
  return result;
}
