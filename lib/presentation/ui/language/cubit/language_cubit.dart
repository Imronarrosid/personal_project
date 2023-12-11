import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState(status: LanguageStatus.initial));

  void setLocale(String selected) {
    emit(const LanguageState(status: LanguageStatus.changed));
  }
}
