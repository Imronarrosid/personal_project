import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/coments_paging_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comment_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comments_paging_bloc.dart';
import 'package:personal_project/presentation/ui/comments/cubit/like_comment_cubit.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _textEditingController = TextEditingController();

  final List<Comment> _newCommentItems = [];

  @override
  void initState() {
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CommentBloc(RepositoryProvider.of<CommentRepository>(context)),
          ),
          BlocProvider(
            create: (context) => CommentsPagingBloc(
                RepositoryProvider.of<ComentsPagingRepository>(context))
              ..add(InitCommentsPagingEvent(postId: widget.postId)),
          ),
        ],
        child: BlocListener<CommentBloc, CommentState>(
          listener: (context, state) {
            if (state.status == CommentStatus.succes) {
              Comment commentToMove = state.comment!;
              _newCommentItems.add(commentToMove);
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: DraggableScrollableSheet(
              initialChildSize:
                  0.7, // Initial height as a fraction of the screen height
              maxChildSize: 1.0, // Maximum height when fully expanded
              minChildSize: 0.5, // Minimum height when collapsed,
              snap: true,
              snapSizes: const <double>[0.6, 1.0],
              builder:
                  (BuildContext context, ScrollController scrollController) {
                //To prevent comments list overlaped by header.
                scrollController.addListener(() {
                  debugPrint('offset: ${scrollController.offset}');
                  if (scrollController.offset > 0) {
                    scrollController.jumpTo(0.0);
                  }
                });

                return Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: <Widget>[
                            _commentsHeaders(context),
                            _buildCommentsList(context, onRefresh: () {
                              return _refreshComments(context);
                            }),
                          ],
                        ),
                      ),
                      _buildCommnetsInput(context)
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Container _buildCommnetsInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: COLOR_black_ff121212.withOpacity(0.4),
          ),
        ),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimens.DIMENS_6),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.tertiary),
        child: Row(
          children: [
            SizedBox(
              width: Dimens.DIMENS_8,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.DIMENS_6),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
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
                          controller: _textEditingController,
                          decoration: InputDecoration(
                              enabled: state.status == AuthStatus.authenticated,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: Dimens.DIMENS_12),
                              hintText: LocaleKeys.message_add_comments.tr(),
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.normal),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 3,
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
                                if (_textEditingController.text.isNotEmpty) {
                                  BlocProvider.of<CommentBloc>(context).add(
                                    PostCommentEvent(
                                        postId: widget.postId,
                                        comment: _textEditingController.text),
                                  );
                                  _textEditingController.clear();
                                  FocusScope.of(context).unfocus();
                                }
                                debugPrint('plane');
                              }
                            : null,
                        icon: const FaIcon(
                          FontAwesomeIcons.paperPlane,
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
      ),
    );
  }

  SliverFillRemaining _buildCommentsList(
    BuildContext context, {
    required Future<void> Function() onRefresh,
  }) {
    return SliverFillRemaining(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _commentFromLocal(),
                BlocBuilder<CommentsPagingBloc, CommentsPagingState>(
                  builder: (context, state) {
                    if (state is CommentsPagingInitialized) {
                      return PagedListView<int, Comment>(
                        pagingController: state.controller!,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                      padding: EdgeInsets.only(
                                          top: Dimens.DIMENS_50),
                                      child: Center(
                                        child: Text(
                                          LocaleKeys.message_no_comment_yet
                                              .tr(),
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
                          return CommentItem(
                            comment: item,
                            postId: widget.postId,
                          );
                        }),
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _commentsHeaders(BuildContext context) {
    return SliverAppBar(
      title: Text(LocaleKeys.title_comments.tr()),
      floating: false,
      pinned: true,
      elevation: 0.2,
      scrolledUnderElevation: 1,
      shadowColor: COLOR_white_fff5f5f5,
      forceElevated: true,
      leading: Container(),
      leadingWidth: Dimens.DIMENS_3,
      actions: [
        IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close_rounded))
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

  BlocBuilder<CommentBloc, CommentState> _commentFromLocal() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        return ListView.builder(
          reverse: true,
          shrinkWrap: true,
          itemCount: _newCommentItems.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return CommentItem(
                comment: _newCommentItems[index], postId: widget.postId);
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

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class CommentItem extends StatelessWidget {
  final String postId;
  final Comment comment;
  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    if (context.locale.languageCode == LOCALE.id.code) {
      tago.setLocaleMessages('id', tago.IdMessages());
    } else if (context.locale.languageCode == LOCALE.en.code) {
      tago.setLocaleMessages('en', tago.EnMessages());
    }

    Size size = MediaQuery.of(context).size;
    final CommentRepository repository =
        RepositoryProvider.of<CommentRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final userUid = authRepository.currentUser?.uid;
    return BlocProvider(
      create: (context) =>
          LikeCommentCubit(RepositoryProvider.of<CommentRepository>(context)),
      child: Builder(builder: (context) {
        return FutureBuilder(
            future: repository.getVideoOwnerData(comment.uid),
            builder: (context, snapshot) {
              User? data = snapshot.data;
              if (!snapshot.hasData) {
                return Container();
              }
              return ListTile(
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
                    // FutureBuilder(
                    //     future: _checkVerified(comment.uid),
                    //     initialData: false,
                    //     builder: (_, AsyncSnapshot<bool> snapshot) {
                    //       bool isVerified = snapshot.data!;
                    //       return snapshot.hasData
                    //           ? Row(
                    //               children: [
                    //                 Text(
                    //                   '',
                    //                   style: const TextStyle(
                    //                       fontSize: 20,
                    //                       color: Colors.black,
                    //                       fontWeight: FontWeight.w500),
                    //                 ),
                    //                 isVerified
                    //                     ? Image.asset(
                    //                         'assets/images/blue_check.png',
                    //                         fit: BoxFit.cover,
                    //                         width: 15,
                    //                         height: 15,
                    //                       )
                    //                     : Container(
                    //                         height: 15,
                    //                       )
                    //               ],
                    //             )
                    //           : Container(
                    //               height: 20,
                    //             );
                    //     }),

                    GestureDetector(
                      onTap: () {
                        context.push(APP_PAGE.profile.toPath,
                            extra: ProfilePayload(
                                uid: data.id,
                                name: data.name!,
                                userName: data.userName!,
                                photoURL: data.photo!));
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
                              DateTime.parse(
                                  comment.datePublished.toDate().toString()),
                              locale: context.locale.languageCode)
                          .toString(),
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  ],
                ),
                subtitle: Column(
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
                  ],
                ),
                trailing: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (authRepository.currentUser != null) {
                          BlocProvider.of<LikeCommentCubit>(context)
                              .likeComment(
                                  postId: postId,
                                  commentId: comment.id,
                                  databaseLikeCount: comment.likes.length,
                                  stateFromDatabase:
                                      comment.likes.contains(userUid));
                        } else {
                          showAuthBottomSheetFunc(context);
                        }
                      },
                      child: BlocBuilder<LikeCommentCubit, LikeCommentState>(
                        builder: (context, state) {
                          if (state is CommentLiked) {
                            return const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            );
                          } else if (state is UnilkedComment) {
                            return const Icon(Icons.favorite_border_outlined);
                          }
                          return comment.likes.contains(userUid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(Icons.favorite_border_outlined);
                        },
                      ),
                    ),
                    BlocBuilder<LikeCommentCubit, LikeCommentState>(
                      builder: (context, state) {
                        int likes = comment.likes.length;

                        if (state is CommentLiked) {
                          likes = state.likeCount;
                        } else if (state is UnilkedComment) {
                          likes = state.likeCount;
                        }

                        return likes == 0
                            ? const SizedBox(width: 0, height: 0)
                            : Text(
                                likes.toString(),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              );
                      },
                    ),
                  ],
                ),
              );
            });
      }),
    );
  }

  void _onAvatarTap(BuildContext context, User data) {
    context.push(APP_PAGE.profile.toPath,
        extra: ProfilePayload(
            uid: data.id,
            name: data.name!,
            userName: data.userName!,
            photoURL: data.photo!));
  }
}
