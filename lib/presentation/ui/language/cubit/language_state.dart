part of 'language_cubit.dart';

enum LanguageStatus {
  initial,
  loading,
  changed,
  error,
}

final class LanguageState extends Equatable {
  final LanguageStatus status;
  final String? selectedLocale;
  const LanguageState({
    required this.status,
    this.selectedLocale,
  });

  @override
  List<Object?> get props => [status, selectedLocale];
}

final class LanguageInitial extends LanguageState {
  const LanguageInitial({required super.status});
}
