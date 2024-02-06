import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comment_bloc.dart';
import 'package:personal_project/presentation/ui/comments/cubit/like_comment_cubit.dart';
import 'package:timeago/timeago.dart' as tago;

class Replies extends StatefulWidget {
  final String postId, commentId;
  final Comment comment;
  const Replies({
    super.key,
    required this.postId,
    required this.commentId,
    required this.comment,
  });

  @override
  State<Replies> createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  final TextEditingController _textEditingController = TextEditingController();
  late final PagingController<int, Comment> _pagingController;
  final List<Comment> _newReplyItems = [];
  final FocusNode _replyFocusNode = FocusNode();

  final List<DocumentSnapshot> allDocs = [];
  final int _pageSize = 10;
  @override
  void initState() {
    initPagingController(widget.postId);

    super.initState();
  }

  void initPagingController(String postId) {
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      try {
        _fetchPage(postId: postId, pageKey: pageKey);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });
  }

  Future<void> _fetchPage({required String postId, required int pageKey}) async {
    try {
      List<Comment> listComments = [];
      final newItems =
          await getListRepliesDocs(limit: _pageSize, postId: postId, commentId: widget.commentId);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items$newItems');

      for (var element in newItems) {
        listComments.add(Comment.fromSnap(element));
      }

      if (isLastPage) {
        _pagingController.appendLastPage(listComments);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(listComments, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<DocumentSnapshot>> getListRepliesDocs({
    required String postId,
    required int limit,
    required String commentId,
  }) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (allDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('datePublished', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('datePublished', descending: true)
            .startAfterDocument(allDocs.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      allDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
      // setState(() {
      //   _hasMore = false;
      // });
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (_, state) {
        if (state.status == CommentStatus.replyAdded) {
          _newReplyItems.add(state.comment!);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.label_replies.tr()),
        ),
        bottomNavigationBar: _repliesInput(context),
        body: RefreshIndicator(
          onRefresh: _refreshComments,
          child: ListView(children: [
            _repliedComment(context, comment: widget.comment, postId: widget.postId),
            _commentFromLocal(),
            PagedListView<int, Comment>(
              padding: EdgeInsets.only(left: Dimens.DIMENS_18),
              pagingController: _pagingController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              builderDelegate: PagedChildBuilderDelegate(noItemsFoundIndicatorBuilder: (_) {
                ///Because new comment is not in this paging widget
                ///if [_newCommentItems] is not empty but the paging widget
                ///is empty ,this emty state widget will removed
                return BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    return _newReplyItems.isNotEmpty
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(top: Dimens.DIMENS_50),
                            child: Center(
                              child: Text(
                                LocaleKeys.message_no_comment_yet.tr(),
                                style: Theme.of(context).textTheme.titleMedium,
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
                return _replyItem(
                  context,
                  reply: item,
                  postId: widget.postId,
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _refreshComments() {
    return Future.sync(() {
      _newReplyItems.clear();
      allDocs.clear();
      _pagingController.refresh();
    });
  }

  BlocBuilder<CommentBloc, CommentState> _commentFromLocal() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        return ListView.builder(
          padding: EdgeInsets.only(left: Dimens.DIMENS_18),
          reverse: true,
          shrinkWrap: true,
          itemCount: _newReplyItems.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return _replyItem(
              context,
              reply: _newReplyItems[index],
              postId: widget.postId,
            );
          }),
        );
      },
    );
  }

  BlocProvider<LikeCommentCubit> _replyItem(
    BuildContext context, {
    required String postId,
    required Comment reply,
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
    return BlocProvider(
      create: (context) => LikeCommentCubit(RepositoryProvider.of<CommentRepository>(context)),
      child: Builder(builder: (context) {
        return FutureBuilder(
            future: repository.getVideoOwnerData(reply.uid),
            builder: (context, snapshot) {
              User? data = snapshot.data;
              if (!snapshot.hasData) {
                return Container();
              }
              return ListTile(
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
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: Dimens.DIMENS_6,
                    ),
                    Text(
                      tago
                          .format(DateTime.parse(reply.datePublished.toDate().toString()),
                              locale: context.locale.languageCode)
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
                        reply.comment,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (authRepository.currentUser != null) {
                          BlocProvider.of<LikeCommentCubit>(context).likeReply(
                              postId: postId,
                              replyid: reply.id!,
                              commentId: widget.commentId,
                              databaseLikeCount: reply.likes.length,
                              stateFromDatabase: reply.likes.contains(userUid));
                        } else {
                          showAuthBottomSheetFunc(context);
                        }
                      },
                      child: BlocBuilder<LikeCommentCubit, LikeCommentState>(
                        builder: (context, state) {
                          if (state is ReplyLiked) {
                            return const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            );
                          } else if (state is UnilkedReply) {
                            return Icon(
                              Icons.favorite_border_outlined,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            );
                          }
                          return reply.likes.contains(userUid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                );
                        },
                      ),
                    ),
                    BlocBuilder<LikeCommentCubit, LikeCommentState>(
                      builder: (context, state) {
                        int likes = reply.likesCount;

                        if (state is ReplyLiked) {
                          likes = state.likeCount;
                        } else if (state is UnilkedReply) {
                          likes = state.likeCount;
                        }

                        return likes == 0
                            ? const Text('')
                            : Text(
                                likes.toString(),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  BlocProvider<LikeCommentCubit> _repliedComment(
    BuildContext context, {
    required String postId,
    required Comment comment,
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
    return BlocProvider(
      create: (context) => LikeCommentCubit(RepositoryProvider.of<CommentRepository>(context)),
      child: Builder(builder: (context) {
        return FutureBuilder(
            future: repository.getVideoOwnerData(comment.uid),
            builder: (context, snapshot) {
              User? data = snapshot.data;
              if (!snapshot.hasData) {
                return Container();
              }
              return ListTile(
                isThreeLine: true,
                minLeadingWidth: Dimens.DIMENS_28,
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
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: Dimens.DIMENS_6,
                    ),
                    Text(
                      tago
                          .format(DateTime.parse(comment.datePublished.toDate().toString()),
                              locale: context.locale.languageCode)
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
                      child: Text(
                        LocaleKeys.label_reply.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        _replyFocusNode.requestFocus();
                      },
                    )
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (authRepository.currentUser != null) {
                          BlocProvider.of<LikeCommentCubit>(context).likeReply(
                              postId: postId,
                              replyid: comment.id!,
                              commentId: widget.commentId,
                              databaseLikeCount: comment.likes.length,
                              stateFromDatabase: comment.likes.contains(userUid));
                        } else {
                          showAuthBottomSheetFunc(context);
                        }
                      },
                      child: BlocBuilder<LikeCommentCubit, LikeCommentState>(
                        builder: (context, state) {
                          if (state is ReplyLiked) {
                            return const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            );
                          } else if (state is UnilkedReply) {
                            return Icon(
                              Icons.favorite_border_outlined,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            );
                          }
                          return comment.likes.contains(userUid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                );
                        },
                      ),
                    ),
                    BlocBuilder<LikeCommentCubit, LikeCommentState>(
                      builder: (context, state) {
                        int likes = comment.likesCount;

                        if (state is ReplyLiked) {
                          likes = state.likeCount;
                        } else if (state is UnilkedReply) {
                          likes = state.likeCount;
                        }

                        return likes == 0
                            ? const Text('')
                            : Text(
                                likes.toString(),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
            uid: data.id, name: data.name!, userName: data.userName!, photoURL: data.photo!));
  }

  Container _repliesInput(BuildContext context) {
    return Container(
      height: 70 + MediaQuery.of(context).viewInsets.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: COLOR_black_ff121212.withOpacity(0.4),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimens.DIMENS_6),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary),
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
                              RepositoryProvider.of<AuthRepository>(context).currentUser != null;
                          if (isAuthenticated) {
                            BlocProvider.of<CommentBloc>(context).add(TapReplyForm());
                          } else {
                            showAuthBottomSheetFunc(context);
                          }
                        },
                        child: TextField(
                          focusNode: _replyFocusNode,
                          controller: _textEditingController,
                          decoration: InputDecoration(
                              enabled: state.status == AuthStatus.authenticated,
                              contentPadding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                              hintText: LocaleKeys.message_add_comments.tr(),
                              hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 3,
                          onChanged: (text) {
                            final CommentBloc commentsBloc = BlocProvider.of<CommentBloc>(context);
                            if (text.endsWith('\n')) {
                              // Handle the Enter key press

                              // You can add your custom logic here
                            }
                            if (text.isNotEmpty) {
                              commentsBloc.add(TypingReply());
                            } else {
                              commentsBloc.add(TapReplyForm());
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
                if (state.status == CommentStatus.openReplyForm ||
                    state.status == CommentStatus.typingReply) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.transparent),
                        splashRadius: Dimens.DIMENS_70,
                        onPressed: state.status == CommentStatus.typingReply &&
                                _textEditingController.text.isNotEmpty
                            ? () {
                                if (_textEditingController.text.isNotEmpty) {
                                  BlocProvider.of<CommentBloc>(context).add(
                                    PostReplyEvent(
                                        postId: widget.postId,
                                        commentId: widget.commentId,
                                        reply: _textEditingController.text),
                                  );
                                  _textEditingController.clear();
                                  FocusScope.of(context).unfocus();
                                }
                                debugPrint('plane');
                              }
                            : null,
                        icon: const Icon(
                          BootstrapIcons.send,
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
}
