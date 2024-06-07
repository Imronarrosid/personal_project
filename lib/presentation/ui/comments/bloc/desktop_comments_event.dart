part of 'desktop_comments_bloc.dart';

sealed class DesktopCommentsEvent extends Equatable {
  const DesktopCommentsEvent();

  @override
  List<Object> get props => [];
}

class OpenDesktopComments extends DesktopCommentsEvent {
  final String postId;

  const OpenDesktopComments({
    required this.postId,
  });
  @override
  List<Object> get props => [
        super.props,
        postId,
      ];
}

class CloseDesktopComments extends DesktopCommentsEvent {}
