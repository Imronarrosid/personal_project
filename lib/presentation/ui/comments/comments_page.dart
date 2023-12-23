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
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
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
            if (state is ComentAddedState) {
              Comment commentToMove = state.comment;
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
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
                            SliverAppBar(
                              title: Text(LocaleKeys.title_comments.tr()),
                              floating: false,
                              pinned: true,
                              backgroundColor: Colors.white,
                              foregroundColor: COLOR_black_ff121212,
                              elevation: 0,
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
                                preferredSize: Size(
                                    MediaQuery.of(context).size.width,
                                    Dimens.DIMENS_3),
                                child: Divider(
                                  color: Colors.black,
                                  height: Dimens.DIMENS_3,
                                ),
                              ),
                            ),

                            SliverFillRemaining(
                              child: RefreshIndicator(
                                onRefresh: () {
                                  return _refreshComments(context);
                                },
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      BlocBuilder<CommentBloc, CommentState>(
                                        builder: (context, state) {
                                          return ListView.builder(
                                            reverse: true,
                                            shrinkWrap: true,
                                            itemCount: _newCommentItems.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: ((context, index) {
                                              return CommentItem(
                                                  comment:
                                                      _newCommentItems[index],
                                                  postId: widget.postId);
                                            }),
                                          );
                                        },
                                      ),
                                      BlocBuilder<CommentsPagingBloc,
                                          CommentsPagingState>(
                                        builder: (context, state) {
                                          if (state
                                              is CommentsPagingInitialized) {
                                            return PagedListView<int, Comment>(
                                              pagingController:
                                                  state.controller!,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              builderDelegate:
                                                  PagedChildBuilderDelegate(
                                                      itemBuilder: (
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

                            // Add more slivers as needed
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: COLOR_black_ff121212.withOpacity(
                                        0.4)))),
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Row(
                          children: [
                            SizedBox(
                              width: Dimens.DIMENS_8,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Dimens.DIMENS_6),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: COLOR_grey,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                    controller: _textEditingController,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: Dimens.DIMENS_8),
                                        hintText: 'Tambahkan komentar',
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide.none)),
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 3,
                                    onTap: () {
                                      final isAuthenticated =
                                          RepositoryProvider.of<AuthRepository>(
                                                      context)
                                                  .currentUser !=
                                              null;
                                      if (isAuthenticated) {
                                        BlocProvider.of<CommentBloc>(context)
                                            .add(AddComentEvent());
                                      } else {
                                        showAuthBottomSheetFunc(context);
                                      }
                                    },
                                    onChanged: (text) {
                                      if (text.endsWith('\n')) {
                                        // Handle the Enter key press

                                        print('Enter key pressed. ');
                                        // You can add your custom logic here
                                      }
                                    },
                                    onSubmitted: (_) {
                                      debugPrint('Submit');
                                    },
                                  ),
                                ),
                              ),
                            ),
                            BlocBuilder<CommentBloc, CommentState>(
                              builder: (context, state) {
                                if (state is AddComentState) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Material(
                                      child: IconButton(
                                        splashRadius: Dimens.DIMENS_70,
                                        onPressed: () {
                                          if (_textEditingController
                                              .text.isNotEmpty) {
                                            BlocProvider.of<CommentBloc>(
                                                    context)
                                                .add(
                                              PostCommentEvent(
                                                  postId: widget.postId,
                                                  comment:
                                                      _textEditingController
                                                          .text),
                                            );
                                            _textEditingController.clear();
                                            FocusScope.of(context).unfocus();
                                          }
                                          debugPrint('plane');
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.paperPlane,
                                          color: COLOR_black_ff121212,
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
                      )
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
}

class CommentItem extends StatelessWidget {
  final String postId;
  final Comment comment;
  const CommentItem({super.key, required this.comment, required this.postId});

  @override
  Widget build(BuildContext context) {
    tago.setLocaleMessages('id', tago.IdMessages());

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
                leading: CircleAvatar(
                  radius: Dimens.DIMENS_15,
                  backgroundColor: Colors.black,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: data!.photo!,
                    ),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
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

                    Text(
                      tago
                          .format(
                              DateTime.parse(
                                  comment.datePublished.toDate().toString()),
                              locale: 'id')
                          .toString(),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '@${data.userName!}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: Dimens.DIMENS_6,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.8,
                      child: Text(
                        comment.comment,
                        style: TextStyle(
                            fontSize: 16,
                            color: COLOR_black_ff121212.withOpacity(0.6)),
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
                        return Text(
                          likes.toString(),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
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
}
