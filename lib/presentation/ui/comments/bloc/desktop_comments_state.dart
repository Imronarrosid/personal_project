part of 'desktop_comments_bloc.dart';

enum DesktopCommentsStatus {
  initial,
  opened,
  closed,
}

final class DesktopCommentsState extends Equatable {
  final DesktopCommentsStatus status;
  final String? postId;
  const DesktopCommentsState(
    this.status, {
    this.postId,
  });

  @override
  List<Object?> get props => [
        status,
        postId,
      ];
}

final class DesktopCommentsInitial extends DesktopCommentsState {
  const DesktopCommentsInitial(super.status);
  @override
  List<Object> get props => [super.props];
}
