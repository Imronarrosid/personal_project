part of 'language_cubit.dart';

enum LanguageStatus {
  initial,
  loading,
  changed,
  error,
}

final class LanguageState extends Equatable {
  final LanguageStatus status;
  const LanguageState({
    required this.status,
  });

  @override
  List<Object> get props => [status];
}

final class LanguageInitial extends LanguageState {
  const LanguageInitial({required super.status});
}
