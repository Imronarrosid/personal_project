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
  loadReplies,
  loadingReplies,
  startReply,
  removeLocaleComment
}

final class CommentState extends Equatable {
  final CommentStatus status;
  final String? repliedUsername;
  final String? repliedUid;
  final Comment? comment;
  final Reply? reply;
  final String? commentId;
  final List<Comment>? listReply;
  const CommentState({
    required this.status,
    this.repliedUsername,
    this.repliedUid,
    this.comment,
    this.commentId,
    this.listReply,
    this.reply,
  });

  @override
  List<Object?> get props => [
        status,
        comment,
        commentId,
        listReply,
        repliedUsername,
        repliedUsername,
        reply,
      ];
}
