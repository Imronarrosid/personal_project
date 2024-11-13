import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/coments_paging_repository.dart';
import 'package:personal_project/data/repository/replies_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comment_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comments_paging_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/desktop_comments_bloc.dart';
import 'package:personal_project/presentation/ui/comments/cubit/like_comment_cubit.dart';
import 'package:personal_project/presentation/ui/comments/cubit/replies_cubit.dart';
import 'package:personal_project/presentation/ui/comments/local_comments_notifier.dart';
import 'package:personal_project/presentation/ui/video/list_video/cubit/video_size_cubit.dart';
import 'package:personal_project/presentation/ui/video/list_video/is_can_scroll_notification.dart';
import 'package:personal_project/utils/number_format.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:timeago/timeago.dart' as tago;

import '../../../../utils/debug_mode_print.dart';

class DesktopCommentsView extends StatefulWidget {
  final String postId;

  const DesktopCommentsView({super.key, required this.postId});

  @override
  State<DesktopCommentsView> createState() => _DesktopCommentsViewState();
}

class _DesktopCommentsViewState extends State<DesktopCommentsView> {
  final TextEditingController _textEditingController = TextEditingController();

  final List<Comment> _newCommentItems = [];
  final _draggableController = DraggableScrollableController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  bool _isForReply = false;
  bool _isCanPop = true;

  String? _selectedCommentId;
  String? _repliedUid;
  String? _repliedUserName;

  RepliesCubit? _selectedRepliescubit;

  @override
  void initState() {
    _draggableController.addListener(() {
      debugModePrint('height ${_draggableController.size.toString()}');

      BlocProvider.of<VideoSizeCubit>(context)
          .changeVideoSize(_draggableController.size);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => CommentRepository(),
        ),
        RepositoryProvider(
          create: (context) => ComentsPagingRepository(),
        ),
      ],
      child: ChangeNotifierProvider(
          create: (context) => LocalCommentsNotifier(),
          builder: (context, child) {
            return Builder(builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => CommentBloc(
                        RepositoryProvider.of<CommentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => CommentsPagingBloc(
                        RepositoryProvider.of<ComentsPagingRepository>(context))
                      ..add(InitCommentsPagingEvent(postId: widget.postId)),
                  ),
                ],
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<CommentBloc, CommentState>(
                      listener: (context, state) {
                        if (state.status == CommentStatus.succes) {
                          final LocalCommentsNotifier notifier =
                              context.read<LocalCommentsNotifier>();
                          Comment commentToMove = state.comment!;

                          notifier.addLocalComments(
                            commentToMove,
                            commentRepository:
                                context.read<ComentsPagingRepository>(),
                          );
                        }

                        if (state.status == CommentStatus.startReply) {
                          _isForReply = true;
                        } else if (state.status == CommentStatus.replyAdded) {
                          _isForReply = false;
                        }
                      },
                    ),
                    BlocListener<VideoSizeCubit, VideoSizeState>(
                      listener: (context, state) {
                        if (state is VideoSizeChanged) {
                          if (state.size < 0.13 && _isCanPop) {
                            // context.pop();
                            // ignore: prefer_const_constructors
                            _draggableController.animateTo(0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                            _isCanPop = false;
                            debugModePrint('pop');
                          }
                        }
                      },
                    ),
                  ],
                  child: Builder(builder: (context) {
                    return Stack(
                      children: [
                        InkWell(
                          splashFactory: NoSplash.splashFactory,
                          splashColor: Colors.transparent,
                          overlayColor: const WidgetStatePropertyAll<Color>(
                              Colors.transparent),
                          onTap: () {
                            _draggableController.animateTo(0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        ),
                        InkWell(
                          onHover: IsCanScrollNotification.instance.onHover,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                          child: SafeArea(
                            child: ClipRRect(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(Dimens.DIMENS_10)),
                              child: Scaffold(
                                appBar: AppBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  title: Text(LocaleKeys.title_comments.tr()),
                                  actions: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IconButton(
                                          onPressed: () {
                                            BlocProvider.of<
                                                        DesktopCommentsBloc>(
                                                    context)
                                                .add(CloseDesktopComments());
                                            IsCanScrollNotification.instance
                                                .onHover(false);
                                          },
                                          icon: const Icon(Icons.close)),
                                    )
                                  ],
                                  bottom: PreferredSize(
                                      preferredSize: const Size.fromHeight(0.1),
                                      child: Divider(
                                        height: 0.1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.2),
                                      )),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                body: _commentPaging(),
                                // body: Container(
                                //   child:
                                //       // _commentsHeaders(context),

                                //       _buildCommentsList(context,
                                //           onRefresh: () {
                                //     return _refreshComments(context);
                                //   }),
                                // ),
                                bottomNavigationBar:
                                    _buildCommnetsInput(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            });
          }),
    );
  }

  Widget _buildCommnetsInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimens.DIMENS_6,
        ),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.tertiary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocConsumer<CommentBloc, CommentState>(
              listener: (_, state) {
                if (state.status == CommentStatus.startReply) {
                  _repliedUserName = state.repliedUsername;
                }
              },
              buildWhen: (previous, current) {
                if (current.status == CommentStatus.startReply ||
                    current.status == CommentStatus.initial ||
                    current.status == CommentStatus.replyAdded) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: Dimens.DIMENS_8,
                  ),
                  child: Visibility(
                    visible: state.status == CommentStatus.startReply ||
                        state.status == CommentStatus.typing ||
                        state.status == CommentStatus.open,
                    child: Row(
                      children: [
                        Text(
                          '${LocaleKeys.label_reply_to.tr()} ',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(' $_repliedUserName'),
                        SizedBox(
                          width: Dimens.DIMENS_8,
                        ),
                        InkWell(
                          onTap: () {
                            BlocProvider.of<CommentBloc>(context).add(
                              UnfocusForm(),
                            );
                            _isForReply = false;
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            LocaleKeys.label_cancel.tr(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(
                                    0.6,
                                  ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                SizedBox(
                  width: Dimens.DIMENS_8,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimens.DIMENS_6),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10)),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return GestureDetector(
                            onTap: () {
                              final isAuthenticated =
                                  RepositoryProvider.of<AuthRepository>(context)
                                          .currentUser !=
                                      null;
                              if (isAuthenticated) {
                                BlocProvider.of<CommentBloc>(context)
                                    .add(TapCommentForm());
                              } else {
                                showAuthBottomSheetFunc(context);
                              }
                            },
                            child: TextField(
                              focusNode: _focusNode,
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                  enabled:
                                      state.status == AuthStatus.authenticated,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: Dimens.DIMENS_12),
                                  hintText:
                                      '${LocaleKeys.message_add_comments.tr()}...',
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.3),
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10))),
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 3,
                              maxLength: 1200,
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      required maxLength}) =>
                                  const SizedBox(width: 0, height: 0),
                              onChanged: (text) {
                                final CommentBloc commentsBloc =
                                    BlocProvider.of<CommentBloc>(context);
                                if (text.endsWith('\n')) {
                                  // Handle the Enter key press

                                  // You can add your custom logic here
                                }
                                if (text.isNotEmpty) {
                                  commentsBloc.add(InputComments());
                                } else {
                                  commentsBloc.add(TapCommentForm());
                                }
                              },
                              onSubmitted: (_) {
                                debugModePrint('Submit');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: Dimens.DIMENS_5,
                ),
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    if (state.status == CommentStatus.open ||
                        state.status == CommentStatus.typing) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent),
                            splashRadius: Dimens.DIMENS_70,
                            onPressed: state.status == CommentStatus.typing &&
                                    _textEditingController.text.isNotEmpty
                                ? () {
                                    if (_textEditingController
                                        .text.isNotEmpty) {
                                      if (!_isForReply) {
                                        BlocProvider.of<CommentBloc>(context)
                                            .add(
                                          PostCommentEvent(
                                              postId: widget.postId,
                                              comment:
                                                  _textEditingController.text),
                                        );
                                      } else {
                                        _selectedRepliescubit!.addReplies(
                                          postId: widget.postId,
                                          reply: _textEditingController.text,
                                          commentId: _selectedCommentId!,
                                          repliedUid: _repliedUid!,
                                        );
                                        _isForReply = false;
                                      }
                                      _textEditingController.clear();
                                      FocusScope.of(context).unfocus();
                                    }
                                    debugModePrint('plane');
                                  }
                                : null,
                            icon: const Icon(
                              Icons.send,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                SizedBox(
                  width: Dimens.DIMENS_8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentItem(
    BuildContext context, {
    required String postId,
    required Comment comment,
  }) {
    if (context.locale.languageCode == LOCALE.id.code) {
      tago.setLocaleMessages('id', tago.IdMessages());
    } else if (context.locale.languageCode == LOCALE.en.code) {
      tago.setLocaleMessages('en', tago.EnMessages());
    }
    final CommentRepository repository =
        RepositoryProvider.of<CommentRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final userUid = authRepository.currentUser?.uid;
    Size size = MediaQuery.of(context).size;
    int likes = 0;
    return RepositoryProvider(
      create: (context) => RepliesRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LikeCommentCubit(
                RepositoryProvider.of<CommentRepository>(context)),
          ),
          BlocProvider(
            create: (context) =>
                RepliesCubit(RepositoryProvider.of<RepliesRepository>(context)),
          ),
        ],
        child: BlocListener<RepliesCubit, RepliesState>(
          listener: (context, state) {
            debugModePrint('replies ${state.status}');
            if (state.status == RepliesStatus.replyadded) {
              context.read<CommentBloc>().add(UnfocusForm());
            }
            if (state.status == RepliesStatus.loadReplies) {
              if (context
                  .read<RepliesRepository>()
                  .isNotifyRemoveLocalReplies()) {
                context.read<RepliesCubit>().clearLocalRelies();
              }
            }
          },
          child: Builder(builder: (context) {
            return FutureBuilder(
                future: repository.getVideoOwnerData(comment.uid),
                builder: (context, snapshot) {
                  User? data = snapshot.data;
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        isThreeLine: true,
                        minLeadingWidth: Dimens.DIMENS_28,
                        tileColor: Colors.transparent,
                        leading: GestureDetector(
                          onTap: () {
                            _onAvatarTap(context, data);
                          },
                          child: CircleAvatar(
                            radius: Dimens.DIMENS_15,
                            backgroundColor: Colors.black,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: data!.photo!,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.end,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.go(
                                  '/@${data.userName}',
                                  extra: ProfilePayload(
                                    user: data,
                                    isForOtherUser: true,
                                  ),
                                );
                              },
                              child: Text(
                                '@${data.userName!}',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              width: Dimens.DIMENS_6,
                            ),
                            Text(
                              tago
                                  .format(
                                      DateTime.parse(comment.datePublished
                                          .toDate()
                                          .toString()),
                                      locale: context.locale.languageCode)
                                  .toString(),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.8,
                              child: Text(
                                comment.comment,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_8,
                            ),
                            InkWell(
                              onTap: () {
                                // commentId = comment.id;
                                // BlocProvider.of<CommentBloc>(context).add(
                                //   InitReply(commentId: comment.id!, comment: comment),
                                // );
                                // _globalKey.currentState!.openEndDrawer();
                                BlocProvider.of<CommentBloc>(context).add(
                                  StartReply(
                                    uid: comment.uid,
                                    usernameReplied: data.userName!,
                                  ),
                                );
                                _isForReply = true;
                                _repliedUid = '';
                                _selectedCommentId = comment.id;
                                _selectedRepliescubit =
                                    context.read<RepliesCubit>();
                                _focusNode.requestFocus();
                              },
                              child: Text(
                                LocaleKeys.label_reply.tr(),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6)),
                              ),
                              // child: Text(
                              //     '${LocaleKeys.label_reply.tr()}  ${comment.repliesCount != 0 ? '(${comment.repliesCount.toString()})' : ''} '),
                            )
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(50),
                              radius: 24,
                              onTap: () {
                                if (authRepository.currentUser != null) {
                                  BlocProvider.of<LikeCommentCubit>(context)
                                      .likeComment(
                                          postId: postId,
                                          commentId: comment.id!,
                                          databaseLikeCount: comment.likesCount,
                                          stateFromDatabase:
                                              comment.likes.contains(userUid));
                                } else {
                                  showAuthBottomSheetFunc(context);
                                }
                              },
                              child: SizedBox(
                                width: Dimens.DIMENS_22,
                                height: Dimens.DIMENS_22,
                                child: BlocBuilder<LikeCommentCubit,
                                    LikeCommentState>(
                                  builder: (context, state) {
                                    if (state is CommentLiked) {
                                      return Icon(
                                        SolarIconsBold.heart,
                                        size: hearthSize,
                                        color: Colors.red,
                                      );
                                    } else if (state is UnilkedComment) {
                                      return Icon(
                                        SolarIconsOutline.heart,
                                        size: hearthSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      );
                                    }
                                    return comment.likes.contains(userUid)
                                        ? Icon(
                                            SolarIconsBold.heart,
                                            size: hearthSize,
                                            color: Colors.red,
                                          )
                                        : Icon(
                                            SolarIconsOutline.heart,
                                            size: hearthSize,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                          );
                                  },
                                ),
                              ),
                            ),
                            BlocBuilder<LikeCommentCubit, LikeCommentState>(
                              builder: (context, state) {
                                likes = comment.likesCount;

                                if (state is CommentLiked) {
                                  likes = state.likeCount;
                                } else if (state is UnilkedComment) {
                                  likes = state.likeCount;
                                }

                                return likes == 0
                                    ? const Text('')
                                    : Text(
                                        numberFormat(context.locale, likes),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                      _buildReplies(postId, comment, context)
                    ],
                  );
                });
          }),
        ),
      ),
    );
  }

  double get hearthSize => 16;

  Padding _buildReplies(String postId, Comment comment, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 63),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                BlocBuilder<RepliesCubit, RepliesState>(
                  buildWhen: (previous, current) {
                    if (current.status == RepliesStatus.loadReplies ||
                        current.status == RepliesStatus.initial) {
                      return true;
                    } else {
                      return false;
                    }
                  },
                  builder: (_, state) {
                    if (state.status == RepliesStatus.initial) {
                      return Container();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.replies?.length ?? 0,
                      itemBuilder: (context, index) {
                        Reply reply = state.replies![index];
                        return _replyItem(
                          context,
                          postId: widget.postId,
                          commentId: comment.id!,
                          reply: reply,
                        );
                      },
                    );
                  },
                ),
                // _streamReplies(postId, comment),
                _repliesFromLocal(comment.id!),
              ],
            ),
          ),
          comment.repliesCount == 0
              ? Container()
              : BlocBuilder<RepliesCubit, RepliesState>(
                  buildWhen: (_, current) {
                    if (current.status == RepliesStatus.removeLocaleRelies) {
                      return false;
                    }
                    if (current.status == RepliesStatus.replyadded ||
                        current.status == RepliesStatus.uploading) {
                      return false;
                    }
                    return true;
                  },
                  builder: (_, state) {
                    if (state.status == RepliesStatus.loading) {
                      return Text(
                        LocaleKeys.label_loading.tr(),
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)),
                      );
                    }
                    if (state.isLastReply ?? false) {
                      return InkWell(
                          onTap: () {
                            BlocProvider.of<RepliesCubit>(context)
                                .hideReplies();
                          },
                          child: Text(
                            LocaleKeys.label_hide_reply.tr(),
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6)),
                          ));
                    }
                    return InkWell(
                      onTap: () {
                        BlocProvider.of<RepliesCubit>(context).loadReplies(
                          commentId: comment.id!,
                          postId: postId,
                        );
                      },
                      child: Text(
                        state.replies?.isNotEmpty ?? false
                            ? LocaleKeys.label_view_more_reply.tr()
                            : '${LocaleKeys.label_view_reply.tr()} ${comment.repliesCount != 0 ? '(${comment.repliesCount.toString()})' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  BlocProvider<LikeCommentCubit> _replyItem(
    BuildContext context, {
    required String postId,
    required String commentId,
    required Reply reply,
  }) {
    if (context.locale.languageCode == LOCALE.id.code) {
      tago.setLocaleMessages('id', tago.IdMessages());
    } else if (context.locale.languageCode == LOCALE.en.code) {
      tago.setLocaleMessages('en', tago.EnMessages());
    }
    int likes = 0;
    final CommentRepository repository =
        RepositoryProvider.of<CommentRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    final userUid = authRepository.currentUser?.uid;
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          LikeCommentCubit(RepositoryProvider.of<CommentRepository>(context)),
      child: Builder(builder: (context) {
        return FutureBuilder(
            future: repository.getVideoOwnerData(reply.uid),
            builder: (context, snapshot) {
              User? data = snapshot.data;
              if (!snapshot.hasData) {
                return Container();
              }
              return FutureBuilder<String>(
                  future: userRepository.getUserNameOnly(
                    reply.repliedUid,
                  ),
                  builder: (context, snapshot) {
                    String? repliedUsername = snapshot.data;
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        snapshot.data!.isEmpty
                            ? Container()
                            : Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: Dimens.DIMENS_16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                  Text(
                                    '$repliedUsername',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                        ListTile(
                          isThreeLine: true,
                          visualDensity: VisualDensity.compact,
                          minLeadingWidth: Dimens.DIMENS_28,
                          tileColor: Colors.transparent,
                          contentPadding: EdgeInsets.only(
                            right: Dimens.DIMENS_24,
                          ),
                          leading: GestureDetector(
                            onTap: () {
                              _onAvatarTap(context, data);
                            },
                            child: CircleAvatar(
                              radius: Dimens.DIMENS_10,
                              backgroundColor: Colors.black,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: data!.photo!,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.end,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.go(
                                    '/@${data.userName}',
                                    extra: ProfilePayload(
                                      user: data,
                                      isForOtherUser: true,
                                    ),
                                  );
                                },
                                child: Text(
                                  '@${data.userName!}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                width: Dimens.DIMENS_6,
                              ),
                              Text(
                                tago
                                            .format(
                                                DateTime.parse(reply
                                                    .datePublished
                                                    .toDate()
                                                    .toString()),
                                                locale:
                                                    context.locale.languageCode)
                                            .toString() ==
                                        'kurang dari semenit yang lalu'
                                    ? 'baru saja'
                                    : tago
                                        .format(
                                            DateTime.parse(reply.datePublished
                                                .toDate()
                                                .toString()),
                                            locale: context.locale.languageCode)
                                        .toString(),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width * 0.8,
                                child: Text(
                                  reply.comment,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Dimens.DIMENS_8,
                              ),
                              InkWell(
                                onTap: () {
                                  // commentId = comment.id;
                                  // BlocProvider.of<CommentBloc>(context).add(
                                  //   InitReply(commentId: comment.id!, comment: comment),
                                  // );
                                  // _globalKey.currentState!.openEndDrawer();
                                  BlocProvider.of<CommentBloc>(context).add(
                                    StartReply(
                                      uid: reply.uid,
                                      usernameReplied: data.userName!,
                                    ),
                                  );
                                  _repliedUid = reply.uid;
                                  _selectedCommentId = commentId;
                                  _selectedRepliescubit =
                                      context.read<RepliesCubit>();
                                  _focusNode.requestFocus();
                                },
                                child: Text(
                                  LocaleKeys.label_reply.tr(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6)),
                                ),
                                // child: Text(
                                //     '${LocaleKeys.label_reply.tr()}  ${comment.repliesCount != 0 ? '(${comment.repliesCount.toString()})' : ''} '),
                              )
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                radius: 24,
                                onTap: () {
                                  if (authRepository.currentUser != null) {
                                    BlocProvider.of<LikeCommentCubit>(context)
                                        .likeReply(
                                            postId: postId,
                                            replyid: reply.id!,
                                            commentId: commentId,
                                            databaseLikeCount: reply.likesCount,
                                            stateFromDatabase:
                                                reply.likes.contains(userUid));
                                  } else {
                                    showAuthBottomSheetFunc(context);
                                  }
                                },
                                child: SizedBox(
                                  width: Dimens.DIMENS_30,
                                  height: Dimens.DIMENS_30,
                                  child: BlocBuilder<LikeCommentCubit,
                                      LikeCommentState>(
                                    builder: (context, state) {
                                      if (state is ReplyLiked) {
                                        return const Icon(
                                          SolarIconsBold.heart,
                                          size: 16,
                                          color: Colors.red,
                                        );
                                      } else if (state is UnilkedReply) {
                                        return Icon(
                                          SolarIconsOutline.heart,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                        );
                                      }
                                      return reply.likes.contains(userUid)
                                          ? const Icon(
                                              SolarIconsBold.heart,
                                              size: 16,
                                              color: Colors.red,
                                            )
                                          : Icon(
                                              SolarIconsOutline.heart,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                            );
                                    },
                                  ),
                                ),
                              ),
                              BlocBuilder<LikeCommentCubit, LikeCommentState>(
                                builder: (context, state) {
                                  likes = reply.likesCount;

                                  if (state is ReplyLiked) {
                                    likes = state.likeCount;
                                  } else if (state is UnilkedReply) {
                                    likes = state.likeCount;
                                  }

                                  return likes == 0
                                      ? const Text('')
                                      : Text(
                                          numberFormat(
                                            context.locale,
                                            likes,
                                          ),
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
            });
      }),
    );
  }

  BlocBuilder<CommentsPagingBloc, CommentsPagingState> _commentPaging() {
    return BlocBuilder<CommentsPagingBloc, CommentsPagingState>(
      buildWhen: (previous, current) {
        if (current == RemoveLocaleComment()) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is CommentsPagingInitialized) {
          return Consumer<LocalCommentsNotifier>(
            builder: (context, value, child) => ListenableBuilder(
                listenable: value,
                builder: (context, child) {
                  return RefreshIndicator(
                    onRefresh: () async => _refreshComments(context),
                    child: PagedListView<int, Comment>(
                      scrollController: _scrollController,
                      pagingController: state.controller!,
                      // shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      builderDelegate: PagedChildBuilderDelegate(
                          noItemsFoundIndicatorBuilder: (_) {
                        ///Because new comment is not in this paging widget
                        ///if [_newCommentItems] is not empty but the paging widget
                        ///is empty ,this emty state widget will removed
                        return BlocBuilder<CommentBloc, CommentState>(
                          builder: (context, state) {
                            return _newCommentItems.isNotEmpty
                                ? Container()
                                : Padding(
                                    padding:
                                        EdgeInsets.only(top: Dimens.DIMENS_50),
                                    child: Center(
                                      child: Text(
                                        LocaleKeys.message_no_comment_yet.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  );
                          },
                        );
                      }, itemBuilder: (
                        context,
                        item,
                        index,
                      ) {
                        return _commentItem(
                          context,
                          comment: item,
                          postId: widget.postId,
                        );
                      }),
                    ),
                  );
                }),
          );
        }
        return Container();
      },
    );
  }

  BlocBuilder<RepliesCubit, RepliesState> _repliesFromLocal(String commentId) {
    return BlocBuilder<RepliesCubit, RepliesState>(
      builder: (context, state) {
        List<Reply> newRepliesItems =
            context.read<RepliesRepository>().repliesFromLocal;
        return ListView.builder(
          reverse: true,
          shrinkWrap: true,
          itemCount: newRepliesItems.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return _replyItem(
              context,
              commentId: commentId,
              reply: newRepliesItems[index],
              postId: widget.postId,
            );
          }),
        );
      },
    );
  }

  Future<void> _refreshComments(BuildContext context) {
    return Future.sync(() {
      _newCommentItems.clear();
      ComentsPagingRepository commentsPagingReository =
          RepositoryProvider.of<ComentsPagingRepository>(context);
      commentsPagingReository.clearAllcoment();
      BlocProvider.of<CommentBloc>(context).add(RefreshComentEvent());
      if (commentsPagingReository.controller != null) {
        commentsPagingReository.controller!.refresh();
      }
    });
  }

  void _onAvatarTap(BuildContext context, User data) {
    context.go(
      '/@${data.userName}',
      extra: ProfilePayload(
        user: data,
        isForOtherUser: true,
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _draggableController.dispose();
    super.dispose();
  }
}

// class CommentItem extends StatelessWidget {
//   final String postId;
//   final Function() onReplyPressed;
//   final Comment comment;
//   const CommentItem({
//     super.key,
//     required this.onReplyPressed,
//     required this.comment,
//     required this.postId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (context.locale.languageCode == LOCALE.id.code) {
//       tago.setLocaleMessages('id', tago.IdMessages());
//     } else if (context.locale.languageCode == LOCALE.en.code) {
//       tago.setLocaleMessages('en', tago.EnMessages());
//     }

//     Size size = MediaQuery.of(context).size;
//     final CommentRepository repository = RepositoryProvider.of<CommentRepository>(context);
//     final authRepository = RepositoryProvider.of<AuthRepository>(context);
//     final userUid = authRepository.currentUser?.uid;
//     return _commentItem(repository, size, authRepository, userUid);
//   }

//   void _onAvatarTap(BuildContext context, User data) {
//     context.push(APP_PAGE.profile.toPath,
//         extra: ProfilePayload(
//             uid: data.id, name: data.name!, userName: data.userName!, photoURL: data.photo!));
//   }
// }
