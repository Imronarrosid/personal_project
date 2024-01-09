import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/following_n_followers_repository.dart';
import 'package:personal_project/domain/model/following_n_followers_data_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/followings_n_followers/bloc/following_n_followers_bloc.dart';
import 'package:personal_project/presentation/ui/profile/cubit/follow_cubit.dart';

class FollowingsNFollowers extends StatelessWidget {
  final FollowingNFollowersData data;
  const FollowingsNFollowers({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        initialIndex: data.initialIndex,
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                elevation: 1,
                scrolledUnderElevation: 0,
                pinned: true,
                shape: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 0.2),
                ),
                title: Text(data.userName),
                bottom: TabBar(indicatorSize: TabBarIndicatorSize.tab, tabs: [
                  Tab(
                    text: LocaleKeys.label_followers.tr(),
                  ),
                  Tab(
                    text: LocaleKeys.label_following.tr(),
                  ),
                ]),
              ),
            ];
          },
          body: TabBarView(children: [
            KeepAlivePage(
              child: FollowingNFollowersTab(
                uid: data.uid,
                tabFor: TabFor.followers,
              ),
            ),
            KeepAlivePage(
              child: FollowingNFollowersTab(
                uid: data.uid,
                tabFor: TabFor.following,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class FollowingNFollowersTab extends StatelessWidget {
  final String uid;
  final TabFor tabFor;
  const FollowingNFollowersTab({
    super.key,
    required this.uid,
    required this.tabFor,
  });

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return RepositoryProvider(
      create: (context) => FollowingNFollowersRepository(),
      child: BlocProvider(
        create: (context) => FollowingNFollowersBloc(
            RepositoryProvider.of<FollowingNFollowersRepository>(context))
          ..add(InitFollowingNFollowersPaging(uid: uid, tabFor: tabFor)),
        child: BlocBuilder<FollowingNFollowersBloc, FollowingNFollowersState>(
          builder: (context, state) {
            if (state.status == FollowingNFollowersStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            return PagedListView<int, String>(
                builderDelegate: PagedChildBuilderDelegate(
                  noItemsFoundIndicatorBuilder: (context) {
                    if (tabFor == TabFor.followers) {
                      return const Center(
                        child: Text('No followers'),
                      );
                    } else {
                      return const Center(
                        child: Text('No following'),
                      );
                    }
                  },
                  itemBuilder: (context, otherUserUid, index) {
                    final UserRepository repository =
                        RepositoryProvider.of<UserRepository>(context);
                    final String? logedUserUid =
                        RepositoryProvider.of<AuthRepository>(context)
                            .currentUser
                            ?.uid;

                    return BlocProvider(
                      create: (context) => FollowCubit(userRepository),
                      child: FutureBuilder(
                          future: repository.getOtherUserData(otherUserUid),
                          builder: (context, snapshot) {
                            User? user = snapshot.data;

                            if (!snapshot.hasData) {
                              return Container();
                            }
                            return ListTile(
                              tileColor: Colors.transparent,
                              onTap: () {
                                context.push(
                                  APP_PAGE.profile.toPath,
                                  extra: ProfilePayload(
                                    uid: user.id,
                                    name: user.name!,
                                    userName: user.userName!,
                                    photoURL: user.photo!,
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  user!.photo!,
                                ),
                              ),
                              title: Text(user.name!),
                              subtitle: Text(
                                user.userName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.6),
                                    ),
                              ),
                              trailing: user.id == logedUserUid
                                  ? null
                                  : _followButton(repository, user),
                            );
                          }),
                    );
                  },
                ),
                pagingController: state.controller!);
          },
        ),
      ),
    );
  }

  SizedBox _followButton(UserRepository repository, User user) {
    return SizedBox(
      width: 90,
      height: 30,
      child: FutureBuilder<bool>(
          future: repository.isFollowing(user.id),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            bool? isFollowing = snapshot.data;
            if (!snapshot.hasData) {
              return Container(
                height: Dimens.DIMENS_34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: COLOR_black_ff121212.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SizedBox(
                  width: Dimens.DIMENS_18,
                  height: Dimens.DIMENS_18,
                  child: CircularProgressIndicator(
                    color: COLOR_white_fff5f5f5,
                  ),
                ),
              );
            }
            return BlocBuilder<FollowCubit, FollowState>(
              builder: (context, state) {
                debugPrint('follow state $state');
                if (state.status == BlocStatus.following) {
                  isFollowing = true;
                } else if (state.status == BlocStatus.notFollowing) {
                  isFollowing = false;
                } else {
                  isFollowing = isFollowing;
                }

                return Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      5,
                    ),
                  ),
                  color: isFollowing!
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.onTertiary,
                  child: InkWell(
                    onTap: () {
                      final AuthRepository authRepository =
                          RepositoryProvider.of<AuthRepository>(context);
                      if (isFollowing! && authRepository.currentUser != null) {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text(LocaleKeys.message_unfollow.tr()),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: Text(LocaleKeys.label_cancel.tr()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      BlocProvider.of<FollowCubit>(context)
                                          .followButtonHandle(
                                              uid: user.id,
                                              currentUserUid: authRepository
                                                  .currentUser!.uid,
                                              stateFromDatabase: isFollowing!);
                                      context.pop();
                                    },
                                    child: Text(LocaleKeys.label_oke.tr()),
                                  )
                                ],
                              );
                            });
                      } else if (!isFollowing! &&
                          authRepository.currentUser != null) {
                        final AuthRepository authRepository =
                            RepositoryProvider.of<AuthRepository>(context);

                        BlocProvider.of<FollowCubit>(context)
                            .followButtonHandle(
                                currentUserUid: authRepository.currentUser!.uid,
                                uid: user.id,
                                stateFromDatabase: isFollowing!);
                      } else {
                        showAuthBottomSheetFunc(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: Dimens.DIMENS_34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        isFollowing!
                            ? LocaleKeys.label_following.tr()
                            : LocaleKeys.label_follow.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
