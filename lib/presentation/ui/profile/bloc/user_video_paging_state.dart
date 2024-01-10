part of 'user_video_paging_bloc.dart';

final class UserVideoPagingState extends Equatable {
  final BlocStatus status;
  final PagingController<int, String>? controller;

  const UserVideoPagingState({
    required this.status,
    this.controller,
  });

  @override
  List<Object?> get props => [status, controller];
}
