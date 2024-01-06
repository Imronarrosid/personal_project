part of 'comment_bloc.dart';

enum CommentStatus {
  initial,
  open,
  typing,
  uploading,
  succes,
  refresh,
  errorr,
}

final class CommentState extends Equatable {
  final CommentStatus status;
  final Comment? comment;
  const CommentState({
    required this.status,
    this.comment,
  });

  @override
  List<Object?> get props => [status, comment];
}
