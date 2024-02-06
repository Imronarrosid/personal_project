part of 'comment_bloc.dart';

enum CommentStatus {
  initial,
  open,
  openReplyForm,
  typing,
  typingReply,
  uploading,
  succes,
  refresh,
  errorr,
  initReply,
  replyAdded,
}

final class CommentState extends Equatable {
  final CommentStatus status;
  final Comment? comment;
  final String? commentId;
  const CommentState({
    required this.status,
    this.comment,
    this.commentId,
  });

  @override
  List<Object?> get props => [
        status,
        comment,
        commentId,
      ];
}
