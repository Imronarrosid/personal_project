part of 'vbc_bloc.dart';

sealed class VbcEvent extends Equatable {
  const VbcEvent();

  @override
  List<Object> get props => [];
}

final class InitVbcEvent extends VbcEvent {
  final String category;
  const InitVbcEvent({
    required this.category,
  });

  @override
  List<Object> get props => [
        category,
      ];
}
