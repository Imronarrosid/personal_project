// ignore: camel_case_types
enum LOCALE { id, en }

extension LocaleExtension on LOCALE {
  String get code {
    switch (this) {
      case LOCALE.en:
        return 'en';
      case LOCALE.id:
        return 'id';

      default:
        return 'id';
    }
  }
}
