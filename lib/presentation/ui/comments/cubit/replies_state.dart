part of 'replies_cubit.dart';

enum RepliesStatus {
  initial,
  loading,
  loadReplies,
  uploading,
  replyadded,
  removeLocaleRelies,
}

final class RepliesState extends Equatable {
  final RepliesStatus status;
  final List<Reply>? replies;
  final bool? isLastReply;
  const RepliesState({
    required this.status,
    this.replies,
    this.isLastReply,
  });

  @override
  List<Object?> get props => [
        status,
        replies,
        isLastReply,
      ];
}

final class RepliesInitial extends RepliesState {
  const RepliesInitial({
    super.status = RepliesStatus.initial,
  });

  @override
  List<Object> get props => [super.props];
}
