import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/comments/cubit/like_comment_cubit.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentItem extends StatelessWidget {
  final String postId;
  final Comment comment;
  const CommentItem({super.key, required this.comment, required this.postId});

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
                    context.push(APP_PAGE.profile.toPath,
                        extra: ProfilePayload(
                            uid: data.id,
                            name: data.name!,
                            userName: data.userName!,
                            photoURL: data.photo!));
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
}
