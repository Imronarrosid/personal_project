import 'package:personal_project/presentation/ui/comments/bloc/comment_input/comment_input_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comments/comments_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/replies/replies_bloc.dart';
import 'package:personal_project/presentation/ui/home/navbar_notifier/navbar_notifier.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/coments_paging_repository.dart';
import 'package:personal_project/data/repository/replies_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comment_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/cubit/video_size_cubit.dart';
import 'package:personal_project/presentation/ui/video/video_item/video_padding_notifier.dart';
import 'package:personal_project/utils/number_format.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as tago;
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/debug_mode_print.dart';
import 'local_comments_notifier.dart';

Future showCommentsBottomSheet(
  BuildContext context, {
  required String postId,
}) {
  return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      enableDrag: true,
      isScrollControlled: true,
      builder: (_) {
        return CommentBottomSheet(
          postId: postId,
        );
      });
}

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Comment> _newCommentItems = [];
  late final DraggableScrollableController _draggController;

  final FocusNode _focusNode = FocusNode();

  final double hearthSize = 16;

  bool _isForReply = false;
  bool _isCanPop = true;
  bool onBackButtonPressed = false;
  String? _selectedCommentId;
  String? _repliedUid;
  String? _repliedUserName;

  RepliesBloc? _selectedRepliesBloc;

  late final CommentsBloc _commentsPagingBloc;
  late final ComentsPagingRepository _commentsPagingRepository;
  late final CommentRepository _commentsRepository;
  @override
  void initState() {
    _draggController = DraggableScrollableController();

    // _draggableController.addListener(() {
    //   debugModePrint('siAttached ${_draggableController.isAttached}');
    //   debugPrint('height ${_draggableController.size.toString()}');
    //   double size =
    //       ((MediaQuery.of(context).size.height * _draggableController.size) -
    //           85);
    //   VideoPaddingNOtifire.instance.setBottomPdding(bottomSheetHeight: size);
    // });
    _commentsRepository = CommentRepository(
      authRepository: RepositoryProvider.of<AuthRepository>(context),
    );
    _commentsPagingRepository = ComentsPagingRepository(
      commentRepository: _commentsRepository,
      authRepository: RepositoryProvider.of<AuthRepository>(context),
    );
    _commentsPagingBloc = CommentsBloc(
      _commentsPagingRepository,
    )..add(CommentsEvent.loadComments(postId: widget.postId));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20 &&
          !_commentsPagingBloc.state.status.isLoading) {
        debugModePrint('loadMore');
        _commentsPagingBloc.add(CommentsEvent.loadComments(postId: widget.postId));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => _commentsRepository,
        ),
        RepositoryProvider(
          create: (context) => _commentsPagingRepository,
        ),
        BlocProvider<CommentInputBloc>(
          create: (context) => CommentInputBloc(
            _commentsRepository,
            RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (context) => LocalCommentsNotifier(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CommentBloc(
                RepositoryProvider.of<CommentRepository>(context),
                _commentsPagingRepository,
              ),
            ),
            BlocProvider<CommentsBloc>(create: (context) => _commentsPagingBloc),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<CommentBloc, CommentState>(
                listener: (context, state) {
                  if (state.status == CommentStatus.succes) {}

                  if (state.status == CommentStatus.startReply) {
                    _isForReply = true;
                  } else if (state.status == CommentStatus.replyAdded) {
                    _isForReply = false;
                  }
                },
              ),
              BlocListener<VideoSizeCubit, VideoSizeState>(
                listener: (_, state) {
                  if (state is VideoSizeChanged) {
                    if (state.size < 0.13 && _isCanPop) {
                      // context.pop();
                      // ignore: prefer_const_constructors
                      // _draggableController.animateTo(0.0,
                      //     duration: const Duration(milliseconds: 200),
                      //     curve: Curves.easeInOut);
                      _isCanPop = false;
                      debugPrint('pop');
                    }
                  }
                },
              ),
            ],
            child: Stack(
              children: [
                InkWell(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
                  onTap: () {
                    onBackButtonPressed = true;
                    context.pop();
                    // _draggController.animateTo(0.0,
                    //     duration: const Duration(milliseconds: 200),
                    //     curve: Curves.easeInOut);
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _focusNode.unfocus();
                  },
                  child: StatefulBuilder(builder: (context, setState) {
                    return VisibilityDetector(
                      key: ValueKey(widget.postId),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 1 && !onBackButtonPressed) {
                          NavbarNotifier notifier = context.read<NavbarNotifier>();
                          notifier.chnageNavbarState(NavbarState.hidden);
                        }
                      },
                      child: BackButtonListener(
                        onBackButtonPressed: () async {
                          onBackButtonPressed = true;
                          context.pop();
                          return true;
                        },
                        child: DraggableScrollableSheet(
                          controller: _draggController
                            ..addListener(
                              () {
                                debugModePrint('draggg');
                              },
                            ),
                          expand: true,
                          initialChildSize: 0.7, // Initial height as a fraction of the screen height
                          maxChildSize: 0.7, // Maximum height when fully expanded
                          minChildSize: 0.1, // Minimum height when collapsed,
                          snap: true,

                          snapSizes: const <double>[0.7],
                          builder: (BuildContext context, ScrollController scrollController) {
                            debugModePrint('isAttached${_draggController.isAttached}');

                            return TopRoundedPage(
                              child: Scaffold(
                                backgroundColor: Colors.black,
                                appBar: _commentsHeaders(
                                  context,
                                  LocaleKeys.title_comments.tr(),
                                  removeLeading: true,
                                ),
                                // key: _globalKey,
                                body: _commentPaging(),
                                bottomNavigationBar: _buildCommnetsInput(context),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: 300),
      reverseTransitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Forward animation (entering)
        const begin = Offset(1.0, 0.0); // Start from right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var slideAnimation = Tween(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        // Reverse animation (exiting)
        var reverseSlideAnimation = Tween(
          begin: const Offset(-0.3, 0.0), // Exit to left (partial)
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: curve,
        ));

        // Fade animation for smooth transition
        var fadeAnimation = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ));

        return Stack(
          children: [
            // Previous page (sliding out)
            SlideTransition(
              position: reverseSlideAnimation,
              child: FadeTransition(
                opacity: Tween(begin: 1.0, end: 0.7).animate(secondaryAnimation),
                child: Container(), // This will be the previous page
              ),
            ),
            // Current page (sliding in)
            SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommnetsInput(BuildContext context) {
    return BlocConsumer<CommentInputBloc, CommentInputState>(
      listener: _commentInputListener,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
              top: Dimens.DIMENS_6, bottom: Dimens.DIMENS_6 + MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Dimens.DIMENS_8,
                ),
                child: Visibility(
                  visible: state.isReply,
                  child: Row(
                    children: [
                      Text(
                        '${LocaleKeys.label_reply_to.tr()} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                          _focusNode.unfocus();
                        },
                        child: Text(
                          LocaleKeys.label_cancel.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
                            color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                final isAuthenticated =
                                    RepositoryProvider.of<AuthRepository>(context).currentUser != null;
                                if (isAuthenticated) {
                                  BlocProvider.of<CommentBloc>(context).add(TapCommentForm());
                                } else {
                                  showAuthBottomSheetFunc(context);
                                }
                              },
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                    enabled: state.status == AuthStatus.authenticated,
                                    contentPadding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                                    hintText: '${LocaleKeys.message_add_comments.tr()}...',
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10))),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 3,
                                maxLength: 600,
                                buildCounter: (context,
                                        {required currentLength, required isFocused, required maxLength}) =>
                                    const SizedBox(width: 0, height: 0),
                                onChanged: (text) {
                                  final CommentInputBloc commentsBloc = BlocProvider.of<CommentInputBloc>(context);
                                  if (text.endsWith('\n')) {
                                    // Handle the Enter key press

                                    // You can add your custom logic here
                                  }

                                  commentsBloc.add(
                                    CommentInputEvent.textChanged(
                                      text: text,
                                    ),
                                  );
                                },
                                onSubmitted: (_) {
                                  debugPrint('Submit');
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
                  !state.status.isTyping
                      ? SizedBox.shrink()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.transparent),
                              splashRadius: Dimens.DIMENS_70,
                              onPressed: () {
                                if (_textEditingController.text.isEmpty) return;

                                if (state.isReply) {
                                  BlocProvider.of<CommentInputBloc>(context).add(
                                    CommentInputEvent.submitReply(
                                      commentMessage: _textEditingController.text,
                                    ),
                                  );
                                } else {
                                  BlocProvider.of<CommentInputBloc>(context).add(
                                    CommentInputEvent.submitComment(
                                      commentMessage: _textEditingController.text,
                                    ),
                                  );
                                }
                                _textEditingController.clear();
                                _focusNode.unfocus();
                                debugPrint('plane');
                              },
                              icon: const Icon(
                                Icons.send,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    width: Dimens.DIMENS_8,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _commentInputListener(context, state) {
    final CommentInputStatus status = state.status;
    if (status.isUploading) {
      state.isReply
          ? _selectedRepliesBloc!.add(
              RepliesEvent.addReply(
                reply: state.comment!.copyWith(),
                commentId: state.repliedCommentId!,
              ),
            )
          : _commentsPagingBloc.add(
              CommentsEvent.addComment(
                comment: state.comment!.copyWith(),
              ),
            );
    }
    if (status.isSuccess) {
      _commentsPagingBloc.add(
        CommentsEvent.updateComment(
          comment: state.comment!.copyWith(
            status: Status.uploaded,
          ),
        ),
      );
    }
  }

  Widget _commentItem(
    BuildContext context, {
    required String postId,
    required Comment comment,
    required int index,
  }) {
    if (context.locale.languageCode == LOCALE.id.code) {
      tago.setLocaleMessages('id', tago.IdMessages());
    } else if (context.locale.languageCode == LOCALE.en.code) {
      tago.setLocaleMessages('en', tago.EnMessages());
    }
    final CommentRepository repository = RepositoryProvider.of<CommentRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final userUid = authRepository.currentUser?.uid;
    Size size = MediaQuery.of(context).size;
    int likes = 0;
    return RepositoryProvider(
      create: (context) => RepliesRepository(
        commentsRepository: _commentsRepository,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RepliesBloc>(
            create: (context) => RepliesBloc(RepositoryProvider.of<RepliesRepository>(context)),
          ),
        ],
        child: BlocListener<RepliesBloc, RepliesState>(
          listener: (context, state) {
            debugPrint('replies ${state.status}');
            if (state.status.isAdded) {
              context.read<CommentBloc>().add(UnfocusForm());
            }
            if (state.status.isHidden) {
              if (context.read<RepliesRepository>().isNotifyRemoveLocalReplies()) {
                // context.read<RepliesCubit>().clearLocalRelies();
              }
            }
          },
          child: Builder(builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  isThreeLine: true,
                  minLeadingWidth: Dimens.DIMENS_28,
                  tileColor: Colors.transparent,
                  leading: GestureDetector(
                    onTap: () {
                      _toProfiles(context, comment.authorUserName!);
                    },
                    child: CircleAvatar(
                      radius: Dimens.DIMENS_15,
                      backgroundColor: Colors.black,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: comment.avatar!,
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
                        onTap: () => _toProfiles(context, comment.authorUserName!),
                        child: Text(
                          '@${comment.authorUserName}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: Dimens.DIMENS_6,
                      ),
                      comment.status.isUploading
                          ? CircularProgressIndicator()
                          : Text(
                              tago
                                  .format(comment.datePublished.toDate(), locale: context.locale.languageCode)
                                  .toString(),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                          _selectedRepliesBloc = BlocProvider.of<RepliesBloc>(context);
                          BlocProvider.of<CommentInputBloc>(context).add(
                            CommentInputEvent.openIput(
                              postId: postId,
                              isReply: true,
                              repliedCommentId: comment.id,
                              repliedUserId: comment.uid,
                              repliedUserName: comment.authorUserName,
                            ),
                          );
                          _focusNode.requestFocus();
                        },
                        child: Text(
                          LocaleKeys.label_reply.tr(),
                          style: TextStyle(
                              fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
                            // _likeCommentCubit.like(
                            //   postId: postId,
                            //   comment: comment,
                            // );
                            BlocProvider.of<CommentsBloc>(context).add(
                              CommentsEvent.likeComment(
                                commentId: comment.id!,
                                postId: postId,
                                isLiked: comment.isLiked,
                              ),
                            );
                          } else {
                            showAuthBottomSheetFunc(context);
                          }
                        },
                        child: SizedBox(
                          width: Dimens.DIMENS_30,
                          height: Dimens.DIMENS_30,
                          child: Icon(
                            _commentsPagingRepository.currentLoadedComments[index].isLiked
                                ? SolarIconsBold.heart
                                : SolarIconsOutline.heart,
                            size: hearthSize,
                            color: _commentsPagingRepository.currentLoadedComments[index].isLiked
                                ? Colors.red
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      comment.likesCount == 0
                          ? const Text('')
                          : Text(
                              numberFormat(context.locale, comment.likesCount),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                    ],
                  ),
                ),
                _buildReplies(postId, comment, context)
              ],
            );
          }),
        ),
      ),
    );
  }

  Padding _buildReplies(String postId, Comment comment, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 63),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                BlocBuilder<RepliesBloc, RepliesState>(
                  builder: (_, state) {
                    if (state.status == RepliesStatus.initial && comment.repliesCount == 0) {
                      return Container();
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.replies.length + 1,
                      itemBuilder: (context, index) {
                        if (state.replies.isNotEmpty) {
                          int newIndex = index + 1 < state.replies.length - 1 ? index + 1 : 0;
                          final Reply reply = state.replies[newIndex];
                          return _replyItem(
                            context,
                            postId: widget.postId,
                            commentId: comment.id!,
                            reply: reply,
                          );
                        }

                        if (index == state.replies.length) {
                          if (comment.repliesCount == 0) {
                            return Container();
                          }

                          if (state.status == RepliesStatus.loading) {
                            return Text(
                              LocaleKeys.label_loading.tr(),
                              style: TextStyle(
                                  fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            );
                          }
                          if (state.isLastReply) {
                            return InkWell(
                                onTap: () {
                                  BlocProvider.of<RepliesBloc>(context).add(RepliesEvent.hideReplies());
                                },
                                child: Text(
                                  LocaleKeys.label_hide_reply.tr(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                ));
                          }
                          return InkWell(
                            onTap: () {
                              BlocProvider.of<RepliesBloc>(context).add(
                                RepliesEvent.loadReplies(
                                  commentId: comment.id!,
                                  postId: postId,
                                ),
                              );
                            },
                            child: Text(
                              state.replies?.isNotEmpty ?? false
                                  ? LocaleKeys.label_view_more_reply.tr()
                                  : '${LocaleKeys.label_view_reply.tr()} ${comment.repliesCount != 0 ? '(${comment.repliesCount.toString()})' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    );
                  },
                ),
                // _streamReplies(postId, comment),
                // _repliesFromLocal(comment.id!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyItem(
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
    final CommentRepository repository = RepositoryProvider.of<CommentRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    final userUid = authRepository.currentUser?.uid;
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reply.repliedUserId.isEmpty
            ? Container()
            : Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: Dimens.DIMENS_16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  Text(
                    reply.repliedUserName!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
              _toProfile(
                context,
                reply.authorUserName!,
              );
            },
            child: CircleAvatar(
              radius: Dimens.DIMENS_10,
              backgroundColor: Colors.black,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: reply.avatar!,
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
                onTap: () => _toProfile(
                  context,
                  reply.authorUserName!,
                ),
                child: Text(
                  '@${reply.authorUserName}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: Dimens.DIMENS_6,
              ),
              Text(
                tago.format(reply.datePublished.toDate(), locale: context.locale.languageCode).toString() ==
                        'kurang dari semenit yang lalu'
                    ? 'baru saja'
                    : tago.format(reply.datePublished.toDate(), locale: context.locale.languageCode).toString(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                  // BlocProvider.of<CommentBloc>(context).add(
                  //   StartReply(
                  //     uid: reply.uid,
                  //     usernameReplied: data.userName!,
                  //   ),
                  // );
                  // _repliedUid = reply.uid;
                  // _selectedCommentId = commentId;
                  _selectedRepliesBloc = context.read<RepliesBloc>();
                  _focusNode.requestFocus();
                },
                child: Text(
                  LocaleKeys.label_reply.tr(),
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
                    // TODO: reply like code
                    // BlocProvider.of<LikeCommentCubit>(context).likeReply(
                    //     postId: postId,
                    //     replyid: reply.id!,
                    //     commentId: commentId,
                    //     databaseLikeCount: reply.likesCount,
                    //     stateFromDatabase: reply.likes.contains(userUid));
                  } else {
                    showAuthBottomSheetFunc(context);
                  }
                },
                child: SizedBox(
                  width: Dimens.DIMENS_30,
                  height: Dimens.DIMENS_30,
                  child: reply.isLiked
                      ? Icon(
                          SolarIconsBold.heart,
                          size: hearthSize,
                          color: Colors.red,
                        )
                      : Icon(
                          SolarIconsOutline.heart,
                          size: hearthSize,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                ),
              ),
              reply.likesCount == 0
                  ? const Text('')
                  : Text(
                      numberFormat(
                        context.locale,
                        reply.likesCount,
                      ),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _commentPaging() {
    return BlocBuilder<CommentsBloc, CommentsState>(
      builder: (context, state) {
        final ComentsPagingRepository commentsPagingRepository =
            RepositoryProvider.of<ComentsPagingRepository>(context);

        if (state.status.isLoading && commentsPagingRepository.currentLoadedComments.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refreshComments(context),
          child: ListView.custom(
            controller: _scrollController,
            childrenDelegate: SliverChildBuilderDelegate(
                childCount: commentsPagingRepository.currentLoadedComments.length + 1, (context, index) {
              if (state.status.isLoading && index == 0) {
                return SizedBox(
                  height: Dimens.DIMENS_50,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }
              if (index == 0 && commentsPagingRepository.currentLoadedComments.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: Dimens.DIMENS_50),
                  child: Center(
                    child: Text(
                      LocaleKeys.message_no_comment_yet.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              }
              if (index == commentsPagingRepository.currentLoadedComments.length) {
                if (commentsPagingRepository.isLatPage) {
                  return SizedBox.shrink();
                }
                return SizedBox(
                  height: Dimens.DIMENS_50,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }
              return _commentItem(
                context,
                comment: commentsPagingRepository.currentLoadedComments[index],
                postId: widget.postId,
                index: index,
              );
            }),
          ),
          // child: PagedListView<int, Comment>(
          //   pagingController: state.controller!,
          //   builderDelegate: PagedChildBuilderDelegate(noItemsFoundIndicatorBuilder: (_) {
          //     ///Because new comment is not in this paging widget
          //     ///if [_newCommentItems] is not empty but the paging widget
          //     ///is empty ,this emty state widget will removed
          //     return BlocBuilder<CommentBloc, CommentState>(
          //       builder: (context, state) {
          //         return _newCommentItems.isNotEmpty
          //             ? Container()
          //             : Padding(
          //                 padding: EdgeInsets.only(top: Dimens.DIMENS_50),
          //                 child: Center(
          //                   child: Text(
          //                     LocaleKeys.message_no_comment_yet.tr(),
          //                     style: Theme.of(context).textTheme.titleMedium,
          //                   ),
          //                 ),
          //               );
          //       },
          //     );
          //   }, itemBuilder: (
          //     context,
          //     item,
          //     index,
          //   ) {
          //     return _commentItem(
          //       context,
          //       comment: item,
          //       postId: widget.postId,
          //     );
          //   }),
          // ),
        );
      },
    );
  }

  AppBar _commentsHeaders(BuildContext context, String title, {bool removeLeading = false}) {
    return AppBar(
      title: Text(title),
      elevation: 0.2,
      scrolledUnderElevation: 1,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      shadowColor: COLOR_white_fff5f5f5,
      leading: removeLeading ? Container() : null,
      leadingWidth: removeLeading ? Dimens.DIMENS_3 : null,
      actions: [
        IconButton(
            onPressed: () {
              // BlocProvider.of<VideoSizeCubit>(context).changeVideoSize(0);
              // if (_draggController.isAttached) {
              //   draggableController.animateTo(0.1,
              //       duration: const Duration(
              //         milliseconds: 200,
              //       ),
              //       curve: Curves.easeInOut);
              // }
              onBackButtonPressed = true;
              context.pop();
            },
            icon: const Icon(Icons.close_rounded)),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 1),
        child: Container(
          color: COLOR_black_ff121212.withOpacity(0.2),
          height: 1,
        ),
      ),
    );
  }

  Future<void> _refreshComments(BuildContext context) {
    return Future.sync(() {
      _newCommentItems.clear();
      ComentsPagingRepository commentsPagingReository = RepositoryProvider.of<ComentsPagingRepository>(context);
      commentsPagingReository.clearAllcoment();
      BlocProvider.of<CommentBloc>(context).add(RefreshComentEvent());
      if (commentsPagingReository.controller != null) {
        commentsPagingReository.controller!.refresh();
      }
    });
  }

  void _toProfile(BuildContext context, String userName) {
    context.read<NavbarNotifier>().chnageNavbarState(NavbarState.show);

    GoRouter.of(context).go(
      '${APP_PAGE.home.toPath}@$userName',
    );
  }

  void _toProfiles(BuildContext context, String userName) {
    context.read<NavbarNotifier>().chnageNavbarState(NavbarState.show);

    GoRouter.of(context).go(
      '${APP_PAGE.home.toPath}@$userName',
    );
  }

  @override
  void dispose() {
    if (VideoPaddingNOtifire.instance.bottomPadding > 0) {
      VideoPaddingNOtifire.instance.setBottomPdding(bottomSheetHeight: 0);
    }
    _textEditingController.dispose();
    // _draggableController.dispose();
    _focusNode.dispose();
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

class TopRoundedPage extends StatelessWidget {
  final Widget child;
  const TopRoundedPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
        child: child);
  }
}
