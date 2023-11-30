part of 'captions_cubit.dart';

enum Captions { seeMore, seeLess, initial }

class CaptionsState extends Equatable {
  final Captions status;
  const CaptionsState(this.status);

  @override
  List<Object> get props => [status];
}
